package com.dsapp.backend.expectation.application

import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/**
 * Moves overdue occurrences to NEEDS_REVIEW — and nowhere worse.
 *
 * Invariant: This is the single place in the system where "the time
 * passed and nothing happened" is handled, so it is the single place where a
 * punishment could creep in. It cannot:
 *
 * - The ONLY destination is NEEDS_REVIEW. There is no missed, failed, or
 *   overdue-penalty state, and none may ever be added here.
 * - An occurrence with an OPEN adjustment is left alone. Someone who said
 *   "I can't do this right now" and is waiting for an answer must not then be
 *   marked as having let the time run out.
 * - Paused dynamics are skipped entirely: nothing goes overdue while paused.
 * - No outbox entry is queued. Being nudged about lateness is precisely the
 *   nagging this product refuses to do; NEEDS_REVIEW simply appears in the
 *   direction-giving side's Attention as something to look at together.
 */
@Service
class OverdueSweeper(
    private val dsl: DSLContext,
    private val events: RelationshipEventWriter,
) {
    private val log = LoggerFactory.getLogger(OverdueSweeper::class.java)

    /** @return how many occurrences were moved. */
    @Transactional
    fun sweep(now: Instant = Instant.now()): Int {
        val moved = dsl.fetch(
            """
            UPDATE occurrences o
               SET state = 'NEEDS_REVIEW', version = o.version + 1, updated_at = now()
              FROM dynamics d
             WHERE d.id = o.dynamic_id
               AND d.state = 'ACTIVE'
               -- Only work that was genuinely left hanging.
               AND o.state IN ('SCHEDULED', 'ACTIVE')
               AND o.due_at IS NOT NULL
               AND o.due_at < {0}
               -- Never override someone who has asked for an adjustment and is
               -- waiting for an answer.
               AND NOT EXISTS (
                     SELECT 1 FROM adjustment_requests a
                      WHERE a.occurrence_id = o.id AND a.status = 'OPEN'
                   )
            RETURNING o.id, o.dynamic_id
            """.trimIndent(),
            now,
        )

        for (row in moved) {
            // Recorded as history so Attention can surface it, but the actor is
            // NULL: nobody did this, time simply passed.
            events.append(
                dynamicId = row.get("dynamic_id", UUID::class.java),
                actorUserId = null,
                eventType = "occurrence_needs_review",
                objectRef = """{"occurrence_id":"${row.get("id", UUID::class.java)}"}""",
            )
            // Deliberately NO outbox enqueue — see the class comment.
        }

        if (moved.isNotEmpty()) log.info("{} occurrence(s) moved to NEEDS_REVIEW", moved.size)
        return moved.size
    }
}
