package com.dsapp.backend.expectation.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/**
 * Today — Journey B (Notion 02 §3).
 *
 * Answers the receiving side's question: "what is actually expected of me
 * today?" — and it must be answerable in about ten seconds (Notion 01 §11).
 *
 * Journey B fixes the order:
 *   1. important context / partner state
 *   2. 1–3 important expectations
 *   3. ritual
 *   4. recent partner response
 *   5. check-in
 *   6. later / optional
 *
 * M1 covers (2) and (4); ritual and check-in arrive with Milestone 2.
 */
@Service
class TodayQueryService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
) {
    data class TodayItem(
        val occurrenceId: UUID,
        val title: String,
        val purpose: String?,
        val state: String,
        val dueAt: Instant?,
        /** Who set this expectation — it comes from a person, not the app. */
        val fromDisplayName: String?,
    )

    data class RecentResponse(
        val occurrenceId: UUID,
        val title: String,
        val type: String,
        val text: String,
        val sentAt: Instant,
        val senderDisplayName: String?,
    )

    data class Today(
        /**
         * My role in THIS dynamic — Notion 03 §1: role belongs to Membership,
         * never to User, so it is answered per dynamic and never cached
         * against the person.
         */
        val roleContext: String,
        /**
         * How many things are waiting on MY human response right now.
         *
         * Today is one tab with two faces (Notion 02 §3): the receiving side
         * sees what is expected of them, the direction-giving side sees what
         * needs answering. Which face to show follows from this count, not
         * from a role label — direction-giving is recorded per expectation
         * (`creator_user_id`), so the same person can be on both sides of the
         * same dynamic. The server states the count; the client never derives
         * it.
         */
        val needsMyResponseCount: Int,
        /** What still needs action from me. Capped: Today is not a backlog. */
        val expectations: List<TodayItem>,
        /** What I finished that a real person has not yet responded to. */
        val awaitingResponse: List<TodayItem>,
        /** The most recent human response — presence, even when apart. */
        val recentResponse: RecentResponse?,
    )

    @Transactional(readOnly = true)
    fun forDynamic(actorUserId: UUID, dynamicId: UUID): Today {
        val ctx = authorizer.requireRead(
            authorizer.contextForDynamic(actorUserId, dynamicId),
        )

        val rows = dsl.fetch(
            """
            SELECT o.id, o.state, o.due_at, d.title, d.purpose,
                   cu.display_name AS from_name
              FROM occurrences o
              JOIN expectation_definitions d ON d.id = o.definition_id
              LEFT JOIN users cu ON cu.id = d.creator_user_id
             WHERE o.dynamic_id = {0}
               AND d.assignee_user_id = {1}
               AND o.state IN ('ACTIVE','WAITING_ACK','NEED_TO_DISCUSS',
                               'RESCHEDULE_REQUESTED','EXCUSE_REQUESTED','NEEDS_REVIEW')
             ORDER BY o.due_at NULLS LAST, o.created_at
            """.trimIndent(),
            dynamicId, actorUserId,
        ).map {
            TodayItem(
                occurrenceId = it.get("id", UUID::class.java),
                title = it.get("title", String::class.java),
                purpose = it.get("purpose", String::class.java),
                state = it.get("state", String::class.java),
                dueAt = it.get("due_at", Instant::class.java),
                fromDisplayName = it.get("from_name", String::class.java),
            )
        }

        // Notion 02 §3 asks for 1–3 important expectations, not everything.
        // Today is a focus surface; a long list defeats the ten-second goal.
        val needsAction = rows.filter { it.state != "WAITING_ACK" }.take(3)
        val waiting = rows.filter { it.state == "WAITING_ACK" }

        val recent = dsl.fetchOne(
            """
            SELECT o.id, d.title, a.type, a.text, a.sent_at, su.display_name
              FROM acknowledgements a
              JOIN occurrences o ON o.id = a.occurrence_id
              JOIN expectation_definitions d ON d.id = o.definition_id
              LEFT JOIN users su ON su.id = a.sender_user_id
             WHERE o.dynamic_id = {0} AND d.assignee_user_id = {1}
             ORDER BY a.sent_at DESC
             LIMIT 1
            """.trimIndent(),
            dynamicId, actorUserId,
        )?.let {
            RecentResponse(
                occurrenceId = it.get("id", UUID::class.java),
                title = it.get("title", String::class.java),
                type = it.get("type", String::class.java),
                text = it.get("text", String::class.java),
                sentAt = it.get("sent_at", Instant::class.java),
                senderDisplayName = it.get("display_name", String::class.java),
            )
        }

        // Counted here rather than inferred client-side: business state has
        // exactly one authority.
        val needsMyResponse = dsl.fetchOne(
            """
            SELECT count(*) AS n
              FROM occurrences o
              JOIN expectation_definitions d ON d.id = o.definition_id
             WHERE o.dynamic_id = {0}
               AND d.creator_user_id = {1}
               AND d.assignee_user_id <> {1}
               AND o.state IN ('WAITING_ACK','NEED_TO_DISCUSS',
                               'RESCHEDULE_REQUESTED','EXCUSE_REQUESTED',
                               'NEEDS_REVIEW')
            """.trimIndent(),
            dynamicId, actorUserId,
        )!!.get("n", Int::class.java)

        return Today(
            roleContext = ctx.role.name,
            needsMyResponseCount = needsMyResponse,
            expectations = needsAction,
            awaitingResponse = waiting,
            recentResponse = recent,
        )
    }
}
