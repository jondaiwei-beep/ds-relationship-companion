package com.dsapp.backend.response.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/**
 * Attention — Journey C (Notion 02 §4).
 *
 * Answers the direction-giving side's only question: "what actually needs my
 * human response right now?"
 *
 * Ordering is fixed by the journey, not by recency:
 *   1. Need to Discuss / shared support context
 *   2. Waiting for Acknowledgement
 *   3. Needs Review
 *   4. everything else
 *
 * Core Beta has no Proposal inbox (Notion 02 §4).
 */
@Service
class AttentionQueryService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
) {
    data class AttentionItem(
        val occurrenceId: UUID,
        val title: String,
        val state: String,
        /** Who acted, so the response is addressed to a person, not a task. */
        val actorDisplayName: String?,
        val occurredAt: Instant?,
        val priority: Int,
    )

    data class Attention(
        val items: List<AttentionItem>,
        val needsResponseCount: Int,
        val needsReviewCount: Int,
    )

    @Transactional(readOnly = true)
    fun forDynamic(actorUserId: UUID, dynamicId: UUID): Attention {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))

        val rows = dsl.fetch(
            """
            SELECT o.id, o.state, d.title,
                   c.completed_at,
                   cu.display_name AS actor_name,
                   CASE o.state
                       WHEN 'NEED_TO_DISCUSS' THEN 1
                       WHEN 'RESCHEDULE_REQUESTED' THEN 1
                       WHEN 'EXCUSE_REQUESTED' THEN 1
                       WHEN 'WAITING_ACK' THEN 2
                       WHEN 'NEEDS_REVIEW' THEN 3
                       ELSE 4
                   END AS priority
              FROM occurrences o
              JOIN expectation_definitions d ON d.id = o.definition_id
              LEFT JOIN occurrence_completions c ON c.occurrence_id = o.id
              LEFT JOIN users cu ON cu.id = c.actor_user_id
             WHERE o.dynamic_id = {0}
               AND o.state IN ('NEED_TO_DISCUSS','RESCHEDULE_REQUESTED',
                               'EXCUSE_REQUESTED','WAITING_ACK','NEEDS_REVIEW')
             ORDER BY priority, c.completed_at NULLS LAST
            """.trimIndent(),
            dynamicId,
        )

        val items = rows.map {
            AttentionItem(
                occurrenceId = it.get("id", UUID::class.java),
                title = it.get("title", String::class.java),
                state = it.get("state", String::class.java),
                actorDisplayName = it.get("actor_name", String::class.java),
                occurredAt = it.get("completed_at", Instant::class.java),
                priority = it.get("priority", Int::class.java),
            )
        }

        return Attention(
            items = items,
            // Everything a person still owes an answer to, not just
            // completions. A partner asking to discuss, or for a new time, or
            // saying they cannot — those are the most urgent things on this
            // screen (the server sorts them first), and they were in no count
            // at all. A badge reading "1" while two things waited is worse
            // than no badge.
            needsResponseCount = items.count {
                it.state in setOf(
                    "NEED_TO_DISCUSS", "RESCHEDULE_REQUESTED", "EXCUSE_REQUESTED",
                    "WAITING_ACK",
                )
            },
            needsReviewCount = items.count { it.state == "NEEDS_REVIEW" },
        )
    }
}
