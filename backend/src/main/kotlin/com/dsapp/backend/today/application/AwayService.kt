package com.dsapp.backend.today.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.Side
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/**
 * D「我不在」— the one-key away toggle (product/03-domain.md §Task「暂停」,
 * D-26). Sets [dynamics.d_away_until] and, for every active task that
 * `requires_d_present`, pauses it the same way a per-task pause would
 * (`paused_until` + sweep today's open occurrences to `paused` — no debt,
 * invariant 6). `back` clears the flag and unpauses only the tasks this
 * command itself paused: a task the D paused by hand, separately, with a
 * different `paused_until`, is left alone.
 */
@Service
class AwayService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
    private val days: DynamicDays,
) {
    @Transactional
    fun away(actorUserId: UUID, dynamicId: UUID, until: Instant): Instant {
        authorizer.requireSide(authorizer.contextForDynamic(actorUserId, dynamicId), Side.D)
        dsl.query("UPDATE dynamics SET d_away_until = {1}, version = version + 1 WHERE id = {0}", dynamicId, until).execute()

        val today = days.today(dynamicId)
        val taskIds = dsl.fetch(
            """UPDATE tasks SET paused_until = {2}, updated_at = now()
                WHERE dynamic_id = {0} AND status = 'active' AND requires_d_present RETURNING id""",
            dynamicId, until, until,
        ).map { it.get("id", UUID::class.java) }

        for (taskId in taskIds) {
            sweep(taskId, actorUserId, from = "open", to = "paused", day = today)
        }
        events.append(dynamicId, actorUserId, "dynamic_d_away", """{"until":"$until","tasks":${taskIds.size}}""")
        return until
    }

    @Transactional
    fun back(actorUserId: UUID, dynamicId: UUID) {
        authorizer.requireSide(authorizer.contextForDynamic(actorUserId, dynamicId), Side.D)
        val until = dsl.fetchOne("SELECT d_away_until FROM dynamics WHERE id = {0}", dynamicId)
            ?.get("d_away_until", Instant::class.java) ?: return

        dsl.query("UPDATE dynamics SET d_away_until = NULL, version = version + 1 WHERE id = {0}", dynamicId).execute()

        val today = days.today(dynamicId)
        // Only the tasks this away-window paused — a hand-set per-task pause
        // (a different paused_until) survives coming back.
        val taskIds = dsl.fetch(
            """UPDATE tasks SET paused_until = NULL, updated_at = now()
                WHERE dynamic_id = {0} AND status = 'active' AND requires_d_present AND paused_until = {1} RETURNING id""",
            dynamicId, until,
        ).map { it.get("id", UUID::class.java) }

        for (taskId in taskIds) {
            sweep(taskId, actorUserId, from = "paused", to = "open", day = today)
        }
        events.append(dynamicId, actorUserId, "dynamic_d_back", """{"tasks":${taskIds.size}}""")
    }

    private fun sweep(taskId: UUID, by: UUID, from: String, to: String, day: java.time.LocalDate) {
        val ids = dsl.fetch(
            """UPDATE occurrences SET outcome = {3}, outcome_at = now(), version = version + 1, updated_at = now()
                WHERE task_id = {0} AND day >= {1} AND outcome = {2} RETURNING id""",
            taskId, day, from, to,
        ).map { it.get("id", UUID::class.java) }
        for (id in ids) dsl.query(
            "INSERT INTO occurrence_history (id, occurrence_id, by_user_id, axis, from_value, to_value) VALUES ({0}, {1}, {2}, 'outcome', {3}, {4})",
            UUID.randomUUID(), id, by, from, to,
        ).execute()
    }
}
