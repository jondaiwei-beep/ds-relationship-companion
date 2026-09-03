package com.dsapp.backend.expectation.application

import com.dsapp.backend.points.application.PointsService
import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.RoleContext
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

class OccurrenceNotCompletable(val occurrenceId: UUID) :
    RuntimeException("Occurrence $occurrenceId is not in ACTIVE state")

/**
 * `ACTIVE -> WAITING_ACK`, recording a Completion.
 *
 * Invariant — this service writes completion state and the
 * OCCURRENCE_COMPLETED event ONLY. It has no access to the acknowledgements
 * table and must never gain one: a Completion is not an Acknowledgement, and
 * finishing a task must never auto-produce partner praise.
 *
 * Points (owner decision 2026-09-02) are awarded here and are NOT an exception
 * to that. A ledger row is not a response: the occurrence still moves to
 * WAITING_ACK, Attention still asks a human to answer, and the North Star
 * still counts only bilateral events. Points ride alongside the wait; they do
 * not end it. If awarding points ever marks something answered, the invariant
 * has been broken through a side door.
 */
@Service
class CompleteOccurrenceService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
    private val points: PointsService,
) {

    @Transactional
    fun complete(
        actorUserId: UUID,
        occurrenceId: UUID,
        note: String?,
        idempotencyId: UUID,
        /**
         * A photo the completer chose to attach.
         *
         * Never demanded. Obedience makes proof a field on a punishment and
         * Kneel gives verification its own sub-tab; both frame it as the
         * other person checking up. Here it rides along with the completion
         * as something offered, which is why there is no parameter — and no
         * column — for requiring one.
         */
        proofMediaId: String? = null,
    ): UUID {
        // Preliminary authorization: good errors. The guarded UPDATE below is
        // the concurrency-safe decision.
        val ctx = authorizer.requireMutate(
            authorizer.contextForOccurrence(actorUserId, occurrenceId),
            RoleContext.PARTNER,
        )

        // Guarded conditional transition: only a row still in ACTIVE flips.
        // Two concurrent completes -> exactly one updates a row.
        val moved = dsl.fetchOne(
            """
            UPDATE occurrences
               SET state = 'WAITING_ACK', version = version + 1, updated_at = now()
             WHERE id = {0} AND state = 'ACTIVE'
            RETURNING id
            """.trimIndent(),
            occurrenceId,
        )
        if (moved == null) throw OccurrenceNotCompletable(occurrenceId)

        val completionId = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO occurrence_completions
                (id, occurrence_id, actor_user_id, note, idempotency_id, proof_media_id)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5})
            """.trimIndent(),
            completionId, occurrenceId, actorUserId, note, idempotencyId,
            proofMediaId?.trim()?.takeIf { it.isNotEmpty() },
        ).execute()

        events.append(
            dynamicId = ctx.dynamicId,
            actorUserId = actorUserId,
            eventType = "completion_submitted",
            objectRef = """{"occurrence_id":"$occurrenceId","completion_id":"$completionId"}""",
        )
        // Neutral wording only — never praise (Notion 04 §5).
        events.enqueueOutbox(
            aggregateType = "occurrence",
            aggregateId = occurrenceId,
            eventType = "completion_submitted",
            dedupeKey = "completion:$completionId",
        )

        // Same transaction: a completion that was recorded must not leave the
        // ledger behind, and a ledger write must not survive a rolled-back
        // completion. Silent when the couple has points off.
        points.awardForCompletion(ctx.dynamicId, actorUserId, occurrenceId)

        return completionId
    }
}
