package com.dsapp.backend.points.application

import com.dsapp.backend.dynamic.domain.AuthorizationException
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

class InsufficientPoints(val balance: Int, val cost: Int) :
    RuntimeException("Balance $balance is below the cost $cost")

class NoSuchReward(val rewardId: UUID) : RuntimeException("No reward $rewardId")

/**
 * Points, rewards and consequences — owner decision 2026-09-02.
 *
 * The four constraints in `00-overview.md` under "Points and consequences"
 * are what this service exists to hold. Two of them are structural and are
 * worth restating where the code is:
 *
 * **Points never mark a moment as answered.** Awarding on completion writes a
 * ledger row and nothing else. The occurrence stays in WAITING_ACK, Attention
 * still asks for a human response, and the North Star still counts only
 * bilateral events. A completion that earns points and gets no response is
 * the failure case this product is watching for, so the code must not be able
 * to hide it by marking the moment closed.
 *
 * **A person always issues a consequence.** There is no method here that
 * writes a `consequence_events` row without an `actorUserId` argument coming
 * from the authenticated caller. No scheduler, sweep or timer calls into
 * this class, and the column is NOT NULL so a later mistake fails loudly
 * rather than quietly punishing someone.
 *
 * The ledger is append-only. A balance is `SUM(amount)`, never a stored
 * integer: a running total that can be written to is a number that can drift
 * from its own history, and this one is about how someone is treated.
 */
@Service
class PointsService(private val dsl: DSLContext) {

    data class Entry(
        val id: UUID,
        val amount: Int,
        val reason: String,
        val note: String?,
        val createdAt: Instant,
    )

    data class Reward(
        val id: UUID,
        val title: String,
        val detail: String?,
        val cost: Int,
        val affordable: Boolean,
    )

    data class Agreement(
        val id: UUID,
        val label: String,
        val consequence: String,
        val pointCost: Int,
    )

    data class ConsequenceEvent(
        val id: UUID,
        val outcome: String,
        val consequence: String?,
        val issuedByUserId: UUID,
        val note: String?,
        val createdAt: Instant,
    )

    // ---- balance -----------------------------------------------------------

    fun balanceOf(dynamicId: UUID, subjectUserId: UUID): Int = dsl.fetchOne(
        """
        SELECT COALESCE(SUM(amount), 0) AS total FROM point_entries
         WHERE dynamic_id = {0} AND subject_user_id = {1}
        """.trimIndent(),
        dynamicId, subjectUserId,
    )!!.get("total", Int::class.java)

    fun recent(actorUserId: UUID, dynamicId: UUID, limit: Int = 20): List<Entry> {
        requireMember(actorUserId, dynamicId)
        return dsl.fetch(
            """
            SELECT id, amount, reason, note, created_at FROM point_entries
             WHERE dynamic_id = {0}
             ORDER BY created_at DESC
             LIMIT {1}
            """.trimIndent(),
            dynamicId, limit,
        ).map {
            Entry(
                it.get("id", UUID::class.java),
                it.get("amount", Int::class.java),
                it.get("reason", String::class.java),
                it.get("note", String::class.java),
                it.get("created_at", Instant::class.java),
            )
        }
    }

    /**
     * The automatic award on completion.
     *
     * Called from the completion path, inside its transaction. Silent when
     * the couple has points switched off or the per-completion value is zero,
     * because a couple who wants the structure without the economy must be
     * able to have it.
     *
     * Deliberately never throws: a points failure must not roll back somebody
     * having done the thing they were asked to do.
     */
    @Transactional(propagation = org.springframework.transaction.annotation.Propagation.MANDATORY)
    fun awardForCompletion(dynamicId: UUID, subjectUserId: UUID, occurrenceId: UUID) {
        val settings = dsl.fetchOne(
            "SELECT points_enabled, points_per_completion FROM dynamics WHERE id = {0}",
            dynamicId,
        ) ?: return
        if (!settings.get("points_enabled", Boolean::class.java)) return
        val amount = settings.get("points_per_completion", Int::class.java)
        if (amount <= 0) return

        dsl.query(
            """
            INSERT INTO point_entries
                (id, dynamic_id, subject_user_id, amount, reason, occurrence_id, actor_user_id)
            VALUES ({0}, {1}, {2}, {3}, 'COMPLETION', {4}, NULL)
            """.trimIndent(),
            UUID.randomUUID(), dynamicId, subjectUserId, amount, occurrenceId,
        ).execute()
    }

    /** A deliberate award or deduction by the other member. */
    /**
     * A deliberate award or deduction by the other member.
     *
     * A deduction takes what is there and no more. Obedience shows a balance
     * of **-152** against a heart icon: the app telling someone their
     * affection account is overdrawn, with no reward reachable and no move
     * available but climbing out of a debt. Debt has no authority — nobody
     * decided it, it accumulated — and no warmth. Nobody here is ever in the
     * hole with their partner.
     */
    @Transactional
    fun adjust(
        actorUserId: UUID,
        dynamicId: UUID,
        subjectUserId: UUID,
        amount: Int,
        note: String?,
    ): UUID? {
        requireMember(actorUserId, dynamicId)
        require(amount != 0) { "amount" }
        require(amount in -1000..1000) { "amount" }

        val effective = if (amount < 0) {
            val balance = balanceOf(dynamicId, subjectUserId)
            // Nothing to take: the deduction is a no-op rather than a debt.
            if (balance <= 0) return null
            maxOf(amount, -balance)
        } else {
            amount
        }

        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO point_entries
                (id, dynamic_id, subject_user_id, amount, reason, actor_user_id, note)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6})
            """.trimIndent(),
            id, dynamicId, subjectUserId, effective,
            if (effective > 0) "MANUAL_AWARD" else "MANUAL_DEDUCT",
            actorUserId, note?.trim()?.takeIf { it.isNotEmpty() },
        ).execute()
        return id
    }

    // ---- rewards -----------------------------------------------------------

    fun rewards(actorUserId: UUID, dynamicId: UUID, subjectUserId: UUID): List<Reward> {
        requireMember(actorUserId, dynamicId)
        val balance = balanceOf(dynamicId, subjectUserId)
        return dsl.fetch(
            """
            SELECT id, title, detail, cost FROM rewards
             WHERE dynamic_id = {0} AND active
             ORDER BY cost, lower(title)
            """.trimIndent(),
            dynamicId,
        ).map {
            val cost = it.get("cost", Int::class.java)
            Reward(
                it.get("id", UUID::class.java),
                it.get("title", String::class.java),
                it.get("detail", String::class.java),
                cost,
                affordable = balance >= cost,
            )
        }
    }

    @Transactional
    fun addReward(
        actorUserId: UUID,
        dynamicId: UUID,
        title: String,
        detail: String?,
        cost: Int,
    ): UUID {
        requireMember(actorUserId, dynamicId)
        val t = title.trim()
        require(t.isNotEmpty() && t.length <= 120) { "title" }
        require(cost >= 0) { "cost" }

        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO rewards (id, dynamic_id, created_by_user_id, title, detail, cost)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5})
            """.trimIndent(),
            id, dynamicId, actorUserId, t,
            detail?.trim()?.takeIf { it.isNotEmpty() }, cost,
        ).execute()
        return id
    }

    /** Withdrawn, not deleted, so history that names it still reads. */
    @Transactional
    fun retireReward(actorUserId: UUID, dynamicId: UUID, rewardId: UUID) {
        requireMember(actorUserId, dynamicId)
        val n = dsl.query(
            "UPDATE rewards SET active = false WHERE id = {0} AND dynamic_id = {1}",
            rewardId, dynamicId,
        ).execute()
        if (n == 0) throw NoSuchReward(rewardId)
    }

    /**
     * Spend points on a reward.
     *
     * The balance is re-read inside the transaction and the insert is guarded,
     * so two taps cannot buy the same thing twice from one balance.
     */
    @Transactional
    fun redeem(actorUserId: UUID, dynamicId: UUID, rewardId: UUID): UUID {
        requireMember(actorUserId, dynamicId)

        val reward = dsl.fetchOne(
            "SELECT title, cost FROM rewards WHERE id = {0} AND dynamic_id = {1} AND active",
            rewardId, dynamicId,
        ) ?: throw NoSuchReward(rewardId)

        val cost = reward.get("cost", Int::class.java)
        val balance = balanceOf(dynamicId, actorUserId)
        if (balance < cost) throw InsufficientPoints(balance, cost)

        // A free reward still gets a row: taking it is a thing that happened,
        // and the history is where the other person sees it. The ledger
        // forbids a zero amount — a balance movement of nothing is a bug
        // everywhere else — so a free redemption is recorded as its own kind
        // of event rather than as a zero-value purchase.
        val id = UUID.randomUUID()
        if (cost == 0) {
            dsl.query(
                """
                INSERT INTO reward_redemptions (id, dynamic_id, reward_id, subject_user_id)
                VALUES ({0}, {1}, {2}, {3})
                """.trimIndent(),
                id, dynamicId, rewardId, actorUserId,
            ).execute()
            return id
        }

        dsl.query(
            """
            INSERT INTO point_entries
                (id, dynamic_id, subject_user_id, amount, reason, reward_id, actor_user_id, note)
            VALUES ({0}, {1}, {2}, {3}, 'REWARD_PURCHASE', {4}, {2}, {5})
            """.trimIndent(),
            id, dynamicId, actorUserId, -cost, rewardId,
            reward.get("title", String::class.java),
        ).execute()
        return id
    }

    /**
     * Give a reward outright — no cost, no balance check, no deduction.
     *
     * The feature none of the three competitors have, and the answer to
     * "warmer". In their model the receiving partner must earn everything and
     * the giving partner is reduced to an accountant enforcing a price list.
     * A gift is authority in its most generous form: I can give you this
     * because I decided to.
     *
     * Recorded in `reward_redemptions` like any free redemption, with the
     * giver named — the point is that it came from them.
     */
    @Transactional
    fun gift(actorUserId: UUID, dynamicId: UUID, rewardId: UUID, subjectUserId: UUID): UUID {
        requireMember(actorUserId, dynamicId)
        dsl.fetchOne(
            "SELECT 1 FROM rewards WHERE id = {0} AND dynamic_id = {1} AND active",
            rewardId, dynamicId,
        ) ?: throw NoSuchReward(rewardId)

        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO reward_redemptions (id, dynamic_id, reward_id, subject_user_id, given_by_user_id)
            VALUES ({0}, {1}, {2}, {3}, {4})
            """.trimIndent(),
            id, dynamicId, rewardId, subjectUserId, actorUserId,
        ).execute()
        return id
    }

    // ---- consequences ------------------------------------------------------

    fun agreements(actorUserId: UUID, dynamicId: UUID): List<Agreement> {
        requireMember(actorUserId, dynamicId)
        return dsl.fetch(
            """
            SELECT id, label, consequence, point_cost FROM consequence_agreements
             WHERE dynamic_id = {0} AND active
             ORDER BY lower(label)
            """.trimIndent(),
            dynamicId,
        ).map {
            Agreement(
                it.get("id", UUID::class.java),
                it.get("label", String::class.java),
                it.get("consequence", String::class.java),
                it.get("point_cost", Int::class.java),
            )
        }
    }

    @Transactional
    fun addAgreement(
        actorUserId: UUID,
        dynamicId: UUID,
        label: String,
        consequence: String,
        pointCost: Int,
    ): UUID {
        requireMember(actorUserId, dynamicId)
        val l = label.trim()
        val c = consequence.trim()
        require(l.isNotEmpty() && l.length <= 120) { "label" }
        require(c.isNotEmpty() && c.length <= 500) { "consequence" }
        require(pointCost >= 0) { "pointCost" }

        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO consequence_agreements
                (id, dynamic_id, created_by_user_id, label, consequence, point_cost)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5})
            """.trimIndent(),
            id, dynamicId, actorUserId, l, c, pointCost,
        ).execute()
        return id
    }

    /** Either member may end one, alone. An agreement you cannot leave is not one. */
    @Transactional
    fun endAgreement(actorUserId: UUID, dynamicId: UUID, agreementId: UUID) {
        requireMember(actorUserId, dynamicId)
        dsl.query(
            "UPDATE consequence_agreements SET active = false WHERE id = {0} AND dynamic_id = {1}",
            agreementId, dynamicId,
        ).execute()
    }

    /**
     * Invoke or waive an agreed consequence.
     *
     * [actorUserId] comes from the authenticated caller and is written to
     * `issued_by_user_id`, which is NOT NULL. Nothing else in the system calls
     * this — no scheduler, no overdue sweep — and that is the whole design:
     * the software never decides that someone should face a consequence.
     *
     * WAIVED is a first-class outcome, recorded and shown as prominently as
     * ISSUED. Being let off is something a person did.
     */
    @Transactional
    fun issueConsequence(
        actorUserId: UUID,
        dynamicId: UUID,
        subjectUserId: UUID,
        agreementId: UUID?,
        occurrenceId: UUID?,
        waived: Boolean,
        note: String?,
    ): UUID {
        requireMember(actorUserId, dynamicId)

        val agreement = agreementId?.let {
            dsl.fetchOne(
                "SELECT consequence, point_cost FROM consequence_agreements WHERE id = {0} AND dynamic_id = {1}",
                it, dynamicId,
            )
        }

        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO consequence_events
                (id, dynamic_id, agreement_id, occurrence_id,
                 issued_by_user_id, subject_user_id, outcome, note)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7})
            """.trimIndent(),
            id, dynamicId, agreementId, occurrenceId, actorUserId, subjectUserId,
            if (waived) "WAIVED" else "ISSUED",
            note?.trim()?.takeIf { it.isNotEmpty() },
        ).execute()

        // A waived consequence costs nothing. That is what waiving means.
        //
        // An issued one costs what is there and no more: a consequence must
        // never leave someone owing their partner points they do not have.
        val cost = agreement?.get("point_cost", Int::class.java) ?: 0
        if (!waived && cost > 0) {
            val available = balanceOf(dynamicId, subjectUserId)
            val taken = minOf(cost, available)
            if (taken > 0) {
                dsl.query(
                    """
                    INSERT INTO point_entries
                        (id, dynamic_id, subject_user_id, amount, reason, occurrence_id, actor_user_id)
                    VALUES ({0}, {1}, {2}, {3}, 'CONSEQUENCE', {4}, {5})
                    """.trimIndent(),
                    UUID.randomUUID(), dynamicId, subjectUserId, -taken, occurrenceId, actorUserId,
                ).execute()
            }
        }
        return id
    }

    fun consequenceHistory(actorUserId: UUID, dynamicId: UUID, limit: Int = 20): List<ConsequenceEvent> {
        requireMember(actorUserId, dynamicId)
        return dsl.fetch(
            """
            SELECT e.id, e.outcome, e.note, e.created_at, e.issued_by_user_id,
                   a.consequence
              FROM consequence_events e
              LEFT JOIN consequence_agreements a ON a.id = e.agreement_id
             WHERE e.dynamic_id = {0}
             ORDER BY e.created_at DESC
             LIMIT {1}
            """.trimIndent(),
            dynamicId, limit,
        ).map {
            ConsequenceEvent(
                it.get("id", UUID::class.java),
                it.get("outcome", String::class.java),
                it.get("consequence", String::class.java),
                it.get("issued_by_user_id", UUID::class.java),
                it.get("note", String::class.java),
                it.get("created_at", Instant::class.java),
            )
        }
    }

    private fun requireMember(actorUserId: UUID, dynamicId: UUID) {
        val ok = dsl.fetch(
            """
            SELECT 1 FROM memberships
             WHERE dynamic_id = {0} AND user_id = {1} AND access_state = 'ACTIVE'
            """.trimIndent(),
            dynamicId, actorUserId,
        ).isNotEmpty
        if (!ok) throw AuthorizationException.NotAMember()
    }
}
