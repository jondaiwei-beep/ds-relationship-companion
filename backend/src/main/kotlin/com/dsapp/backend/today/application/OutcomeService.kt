package com.dsapp.backend.today.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.Side
import com.dsapp.backend.points.application.PointsService
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import com.dsapp.backend.today.domain.Outcome
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/**
 * The s axis (product/03-domain.md §Occurrence).
 *
 * "送到" is one tap and lands as `delivered` — or `delivered_late` when the
 * clock says so; the s does not choose late, the D reads it. The other three
 * exits (做不到 / 换个时间 / 想聊聊) are first-class outcomes, not failures.
 * Anything here can be withdrawn while the D has not yet disposed, and the
 * trail stays (invariant 5).
 */
@Service
class OutcomeService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
    private val points: PointsService,
    private val days: DynamicDays,
    private val generator: OccurrenceGenerator,
) {
    data class Change(
        val outcome: Outcome,
        val note: String? = null,
        val proofKind: String? = null,
        val proofRef: String? = null,
        val proposedTime: Instant? = null,
    )

    data class Result(val occurrenceId: UUID, val outcome: String, val outcomeAt: Instant?, val version: Int)

    @Transactional
    fun set(actorUserId: UUID, occurrenceId: UUID, change: Change, now: Instant = Instant.now()): Result {
        val ctx = authorizer.requireSide(authorizer.contextForOccurrence(actorUserId, occurrenceId), Side.S)
        val o = dsl.fetchOne(
            """
            SELECT o.outcome, o.outcome_at, o.disposition, o.due_at, o.day, o.points_credited, o.version,
                   t.points_earn, t.proof
              FROM occurrences o JOIN tasks t ON t.id = o.task_id
             WHERE o.id = {0} FOR UPDATE
            """.trimIndent(),
            occurrenceId,
        ) ?: throw NoSuchItem()
        val current = Outcome.valueOf(o.get("outcome", String::class.java))
        val disposition = o.get("disposition", String::class.java)
        val version = o.get("version", Int::class.java)

        if (current == Outcome.paused) throw OccurrenceNotActionable("OCCURRENCE_PAUSED")
        // Once the D has said something about it, the s edits history through
        // the D, not around them.
        if (disposition != "none") throw OccurrenceNotActionable("OCCURRENCE_DISPOSED")
        require(change.outcome.chosenByS || change.outcome == Outcome.open) { "outcome" }
        if (change.outcome == Outcome.new_time_requested) requireNotNull(change.proposedTime) { "proposedTime" }

        val target = when (change.outcome) {
            Outcome.delivered -> {
                val due = o.get("due_at", Instant::class.java)
                    ?: days.settings(ctx.dynamicId).rangeOf(o.get("day", java.time.LocalDate::class.java)).endInclusive
                if (now.isAfter(due)) Outcome.delivered_late else Outcome.delivered
            }
            else -> change.outcome
        }
        if (target == current) return Result(occurrenceId, current.name, o.get("outcome_at", Instant::class.java), version)

        val withdrawing = target == Outcome.open
        dsl.query(
            """
            UPDATE occurrences
               SET outcome = {1}, outcome_at = {2}, outcome_note = {3}, proof_kind = {4}, proof_ref = {5},
                   proposed_time = {6}, version = version + 1, updated_at = now()
             WHERE id = {0} AND version = {7}
            """.trimIndent(),
            occurrenceId, target.name, if (withdrawing) null else now,
            if (withdrawing) null else change.note, if (withdrawing) null else change.proofKind,
            if (withdrawing) null else change.proofRef, if (withdrawing) null else change.proposedTime,
            version,
        ).execute().also { if (it == 0) throw OccurrenceNotActionable("OCCURRENCE_CHANGED") }
        history(occurrenceId, actorUserId, current.name, target.name, change.note)

        // Points ride along with delivery, once, when the task carries any.
        val earn = o.get("points_earn", Int::class.java)
        val credited = o.get("points_credited", Boolean::class.java)
        if (target.isDelivered && earn > 0 && !credited) {
            points.creditTaskEarn(ctx.dynamicId, actorUserId, occurrenceId, earn)
            dsl.query("UPDATE occurrences SET points_credited = true WHERE id = {0}", occurrenceId).execute()
        } else if (withdrawing && credited) {
            points.reverseTaskEarn(ctx.dynamicId, actorUserId, occurrenceId)
            dsl.query("UPDATE occurrences SET points_credited = false WHERE id = {0}", occurrenceId).execute()
        }

        events.append(
            ctx.dynamicId, actorUserId, "occurrence_outcome",
            """{"occurrence_id":"$occurrenceId","from":"${current.name}","to":"${target.name}"}""",
        )
        if (!withdrawing) {
            val eventType = if (target.isDelivered) "occurrence_delivered" else "occurrence_flagged"
            events.enqueueOutbox("occurrence", occurrenceId, eventType, "outcome:$occurrenceId:${version + 1}")
        }
        return Result(occurrenceId, target.name, if (withdrawing) null else now, version + 1)
    }

    /**
     * An `open` task has no schedule; the s delivers it whenever, and that
     * creates the occurrence — today, next free slot.
     */
    @Transactional
    fun deliverOpen(actorUserId: UUID, dynamicId: UUID, taskId: UUID, note: String?, proofKind: String?, proofRef: String?): Result {
        val ctx = authorizer.requireSide(authorizer.contextForDynamic(actorUserId, dynamicId), Side.S)
        val t = dsl.fetchOne(
            "SELECT points_earn FROM tasks WHERE id = {0} AND dynamic_id = {1} AND kind = 'open' AND status = 'active'",
            taskId, dynamicId,
        ) ?: throw TaskNotActionable("TASK_NOT_OPEN")
        val now = Instant.now()
        val day = days.today(dynamicId, now)
        val slot = dsl.fetchOne(
            "SELECT COALESCE(MAX(slot), -1) + 1 AS s FROM occurrences WHERE task_id = {0} AND day = {1}", taskId, day,
        )!!.get("s", Int::class.java)
        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO occurrences (id, task_id, dynamic_id, day, slot, outcome, outcome_at, outcome_note, proof_kind, proof_ref)
            VALUES ({0}, {1}, {2}, {3}, {4}, 'delivered', {5}, {6}, {7}, {8})
            """.trimIndent(),
            id, taskId, dynamicId, day, slot, now, note, proofKind, proofRef,
        ).execute()
        history(id, actorUserId, "open", "delivered", note)
        val earn = t.get("points_earn", Int::class.java)
        if (earn > 0) {
            points.creditTaskEarn(ctx.dynamicId, actorUserId, id, earn)
            dsl.query("UPDATE occurrences SET points_credited = true WHERE id = {0}", id).execute()
        }
        events.append(dynamicId, actorUserId, "occurrence_outcome", """{"occurrence_id":"$id","from":"open","to":"delivered"}""")
        events.enqueueOutbox("occurrence", id, "occurrence_delivered", "outcome:$id:1")
        return Result(id, "delivered", now, 1)
    }

    private fun history(occurrenceId: UUID, by: UUID, from: String, to: String, note: String?) {
        dsl.query(
            """
            INSERT INTO occurrence_history (id, occurrence_id, by_user_id, axis, from_value, to_value, note)
            VALUES ({0}, {1}, {2}, 'outcome', {3}, {4}, {5})
            """.trimIndent(),
            UUID.randomUUID(), occurrenceId, by, from, to, note,
        ).execute()
    }

    private val Outcome.isDelivered: Boolean get() = this == Outcome.delivered || this == Outcome.delivered_late
}
