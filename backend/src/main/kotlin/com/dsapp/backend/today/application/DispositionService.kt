package com.dsapp.backend.today.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.Side
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import com.dsapp.backend.today.domain.Disposition
import com.dsapp.backend.today.domain.Outcome
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.time.LocalDate
import java.util.UUID

/**
 * The D axis (product/03-domain.md §Occurrence).
 *
 * 看到了 / 很好 / 算了 / 补上 / 罚 — always a person, never a job, never on a
 * timer (invariants 2, 3). `seen_at` is the receipt the s asked for
 * ("it would let you know it was received") and is separate from any
 * judgement: seeing is not deciding.
 */
@Service
class DispositionService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {
    data class NewConsequence(val templateId: UUID? = null, val title: String? = null, val detail: String? = null)

    data class Change(
        val disposition: Disposition,
        val note: String? = null,
        /** Required for `make_up`: the relationship day the thing is owed on. */
        val makeUpDay: LocalDate? = null,
        /** Required for `punished`. */
        val consequence: NewConsequence? = null,
    )

    data class Result(
        val occurrenceId: UUID, val disposition: String, val dispositionAt: Instant?,
        val consequenceId: UUID?, val makeUpOccurrenceId: UUID?, val version: Int,
    )

    /** Read receipt. Idempotent; the first look wins and stays. */
    @Transactional
    fun markSeen(actorUserId: UUID, occurrenceId: UUID, now: Instant = Instant.now()): Instant {
        authorizer.requireSide(authorizer.contextForOccurrence(actorUserId, occurrenceId), Side.D)
        return dsl.fetchOne(
            """
            UPDATE occurrences SET seen_at = COALESCE(seen_at, {1}), updated_at = now()
             WHERE id = {0} RETURNING seen_at
            """.trimIndent(),
            occurrenceId, now,
        )!!.get("seen_at", Instant::class.java)
    }

    @Transactional
    fun set(actorUserId: UUID, occurrenceId: UUID, change: Change, now: Instant = Instant.now()): Result {
        val ctx = authorizer.requireSide(authorizer.contextForOccurrence(actorUserId, occurrenceId), Side.D)
        val o = dsl.fetchOne(
            """
            SELECT o.task_id, o.day, o.outcome, o.disposition, o.consequence_id, o.version, t.title
              FROM occurrences o JOIN tasks t ON t.id = o.task_id
             WHERE o.id = {0} FOR UPDATE
            """.trimIndent(),
            occurrenceId,
        ) ?: throw NoSuchItem()
        val outcome = Outcome.valueOf(o.get("outcome", String::class.java))
        val current = Disposition.valueOf(o.get("disposition", String::class.java))
        val version = o.get("version", Int::class.java)
        val oldConsequence = o.get("consequence_id", UUID::class.java)

        // Nothing has happened yet on an open day; there is nothing to say about it.
        if (outcome == Outcome.open || outcome == Outcome.paused) throw OccurrenceNotActionable("OCCURRENCE_${outcome.name.uppercase()}")

        var consequenceId: UUID? = null
        var makeUpId: UUID? = null
        when (change.disposition) {
            Disposition.punished -> {
                val c = requireNotNull(change.consequence) { "consequence" }
                consequenceId = issueConsequence(ctx.dynamicId, actorUserId, c)
            }
            Disposition.make_up -> {
                val day = requireNotNull(change.makeUpDay) { "makeUpDay" }
                makeUpId = makeUpOccurrence(o.get("task_id", UUID::class.java), ctx.dynamicId, day, occurrenceId)
            }
            else -> Unit
        }
        // Revising away from `punished` waives what was issued; the row stays as history.
        if (oldConsequence != null && consequenceId == null) {
            dsl.query(
                "UPDATE consequences SET status = 'waived', decided_at = {1} WHERE id = {0} AND status IN ('issued', 'done_by_s')",
                oldConsequence, now,
            ).execute()
        }

        val clearing = change.disposition == Disposition.none
        dsl.query(
            """
            UPDATE occurrences
               SET disposition = {1}, disposition_at = {2}, disposition_note = {3},
                   consequence_id = {4}, make_up_day = {5},
                   seen_at = COALESCE(seen_at, {2}),
                   version = version + 1, updated_at = now()
             WHERE id = {0} AND version = {6}
            """.trimIndent(),
            occurrenceId, change.disposition.name, if (clearing) null else now,
            if (clearing) null else change.note, consequenceId,
            if (change.disposition == Disposition.make_up) change.makeUpDay else null, version,
        ).execute().also { if (it == 0) throw OccurrenceNotActionable("OCCURRENCE_CHANGED") }

        dsl.query(
            """
            INSERT INTO occurrence_history (id, occurrence_id, by_user_id, axis, from_value, to_value, note)
            VALUES ({0}, {1}, {2}, 'disposition', {3}, {4}, {5})
            """.trimIndent(),
            UUID.randomUUID(), occurrenceId, actorUserId, current.name, change.disposition.name, change.note,
        ).execute()

        events.append(
            ctx.dynamicId, actorUserId, "occurrence_disposition",
            """{"occurrence_id":"$occurrenceId","from":"${current.name}","to":"${change.disposition.name}"}""",
        )
        if (!clearing) {
            events.enqueueOutbox("occurrence", occurrenceId, "disposition_set", "disposition:$occurrenceId:${version + 1}")
        }
        return Result(occurrenceId, change.disposition.name, if (clearing) null else now, consequenceId, makeUpId, version + 1)
    }

    /** Always issued by the caller — there is no parameter for who. */
    private fun issueConsequence(dynamicId: UUID, issuedBy: UUID, c: NewConsequence): UUID {
        val fromTemplate = c.templateId?.let {
            dsl.fetchOne(
                "SELECT label, consequence FROM consequence_agreements WHERE id = {0} AND dynamic_id = {1}", it, dynamicId,
            )
        }
        val title = c.title?.takeIf { it.isNotBlank() } ?: fromTemplate?.get("label", String::class.java)
            ?: throw IllegalArgumentException("consequence.title")
        val detail = c.detail ?: fromTemplate?.get("consequence", String::class.java)
        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO consequences (id, dynamic_id, issued_by, template_id, title, detail)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5})
            """.trimIndent(),
            id, dynamicId, issuedBy, fromTemplate?.let { c.templateId }, title, detail,
        ).execute()
        return id
    }

    /** 补上: the same task, owed on another day, linked back to the one it stands in for. */
    private fun makeUpOccurrence(taskId: UUID, dynamicId: UUID, day: LocalDate, of: UUID): UUID {
        val existing = dsl.fetchOne(
            "SELECT id FROM occurrences WHERE make_up_of = {0}", of,
        )?.get("id", UUID::class.java)
        if (existing != null) {
            dsl.query("UPDATE occurrences SET day = {1}, updated_at = now() WHERE id = {0} AND outcome = 'open'", existing, day).execute()
            return existing
        }
        // Make-ups live in their own slot range so they never collide with generation.
        val slot = dsl.fetchOne(
            "SELECT COALESCE(MAX(slot), 999) + 1 AS s FROM occurrences WHERE task_id = {0} AND day = {1} AND slot >= 1000",
            taskId, day,
        )!!.get("s", Int::class.java)
        val id = UUID.randomUUID()
        dsl.query(
            "INSERT INTO occurrences (id, task_id, dynamic_id, day, slot, make_up_of) VALUES ({0}, {1}, {2}, {3}, {4}, {5})",
            id, taskId, dynamicId, day, slot, of,
        ).execute()
        return id
    }
}
