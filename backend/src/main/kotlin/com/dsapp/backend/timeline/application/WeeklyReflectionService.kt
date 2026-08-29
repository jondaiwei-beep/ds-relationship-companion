package com.dsapp.backend.timeline.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/** What the couple decided to do about the coming week. */
enum class WeeklyAction { KEEP, ADJUST, PAUSE }

/**
 * D7 Weekly Reflection — Notion 02 §8, 01 §6.
 *
 * Core Beta keeps this **very light**: which moments were genuinely answered
 * by a real person this week, and one decision — Keep / Adjust / Pause.
 *
 * Explicitly NOT built (Notion 03 §3): no performance score, no completion
 * rate, no streak, no WeeklyReflectionSnapshot product object. Everything here
 * is computed from real domain events at read time.
 */
@Service
class WeeklyReflectionService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
) {
    data class Moment(
        val title: String?,
        val text: String?,
        val fromDisplayName: String?,
        val occurredAt: Instant,
    )

    data class Reflection(
        /** Days this week on which BOTH people acted. */
        val connectedDays: Int,
        /** Completions a real person answered. The heart of the week. */
        val answeredMoments: List<Moment>,
        /** Adjustments the couple worked through together. */
        val adjustmentsResolved: Int,
        /** True once the couple has enough history for this to mean anything. */
        val hasEnoughHistory: Boolean,
    )

    @Transactional(readOnly = true)
    fun forDynamic(actorUserId: UUID, dynamicId: UUID): Reflection {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))

        // Human acknowledgements only. A completion nobody answered is not a
        // connected moment — that distinction is the entire point of the
        // product (Notion 01 §5).
        val answered = dsl.fetch(
            """
            SELECT d.title, a.text, u.display_name, a.sent_at
              FROM acknowledgements a
              JOIN occurrences o ON o.id = a.occurrence_id
              JOIN expectation_definitions d ON d.id = o.definition_id
              LEFT JOIN users u ON u.id = a.sender_user_id
             WHERE o.dynamic_id = {0}
               AND a.sent_at > now() - interval '7 days'
             ORDER BY a.sent_at DESC
             LIMIT 5
            """.trimIndent(),
            dynamicId,
        ).map {
            Moment(
                title = it.get("title", String::class.java),
                text = it.get("text", String::class.java),
                fromDisplayName = it.get("display_name", String::class.java),
                occurredAt = it.get("sent_at", Instant::class.java),
            )
        }

        // A connected day needs TWO different people to have acted.
        val connected = dsl.fetchOne(
            """
            SELECT count(*) AS n FROM (
                SELECT date_trunc('day', e.occurred_at) AS d
                  FROM relationship_events e
                 WHERE e.dynamic_id = {0}
                   AND e.actor_user_id IS NOT NULL
                   AND e.occurred_at > now() - interval '7 days'
                 GROUP BY 1
                HAVING count(DISTINCT e.actor_user_id) >= 2
            ) x
            """.trimIndent(),
            dynamicId,
        )!!.get("n", Int::class.java)

        val adjustments = dsl.fetchOne(
            """
            SELECT count(*) AS n FROM adjustment_requests a
              JOIN occurrences o ON o.id = a.occurrence_id
             WHERE o.dynamic_id = {0} AND a.status = 'RESOLVED'
               AND a.resolved_at > now() - interval '7 days'
            """.trimIndent(),
            dynamicId,
        )!!.get("n", Int::class.java)

        // Showing a reflection on day two would invite a judgement about a
        // week that has not happened yet.
        val age = dsl.fetchOne(
            "SELECT (now() - created_at) > interval '6 days' AS old FROM dynamics WHERE id = {0}",
            dynamicId,
        )!!.get("old", Boolean::class.java)

        return Reflection(
            connectedDays = connected,
            answeredMoments = answered,
            adjustmentsResolved = adjustments,
            hasEnoughHistory = age,
        )
    }
}
