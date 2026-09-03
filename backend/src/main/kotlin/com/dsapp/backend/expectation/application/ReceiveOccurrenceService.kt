package com.dsapp.backend.expectation.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.RoleContext
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/**
 * "Received." The receiving person says they have seen what was given.
 *
 * This is the first bilateral event of the loop, and the one a shared to-do
 * list does not have: a task app knows a row exists; a dynamic knows the other
 * person has read it. It is deliberately explicit — a tap, not a read receipt
 * — because being told "I have seen this, Sir" is itself part of the
 * exchange, and an automatic receipt would be the system speaking for them.
 *
 * Idempotent: receiving twice is one receipt. Only the assignee may receive,
 * and only while the occurrence is still open.
 */
@Service
class ReceiveOccurrenceService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {
    @Transactional
    fun receive(actorUserId: UUID, occurrenceId: UUID): Instant {
        val ctx = authorizer.requireMutate(
            authorizer.contextForOccurrence(actorUserId, occurrenceId),
            RoleContext.PARTNER,
        )
        val now = Instant.now()
        val moved = dsl.fetchOne(
            """
            UPDATE occurrences
               SET received_at = {1}, updated_at = now()
             WHERE id = {0} AND received_at IS NULL
               AND state IN ('ACTIVE','NEEDS_REVIEW')
            RETURNING received_at
            """.trimIndent(),
            occurrenceId, now,
        )
        if (moved == null) {
            // Already received, or no longer open: report what stands.
            return dsl.fetchOne(
                "SELECT received_at FROM occurrences WHERE id = {0}", occurrenceId,
            )?.get("received_at", Instant::class.java) ?: now
        }
        events.append(
            dynamicId = ctx.dynamicId,
            actorUserId = actorUserId,
            eventType = "direction_received",
            objectRef = """{"occurrence_id":"$occurrenceId"}""",
        )
        events.enqueueOutbox(
            aggregateType = "occurrence",
            aggregateId = occurrenceId,
            eventType = "direction_received",
            dedupeKey = "received:$occurrenceId",
        )
        return now
    }
}
