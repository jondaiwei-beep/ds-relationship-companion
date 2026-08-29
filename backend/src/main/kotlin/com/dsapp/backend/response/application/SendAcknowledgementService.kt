package com.dsapp.backend.response.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.RoleContext
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import com.dsapp.backend.identity.domain.ApiException
import org.springframework.http.HttpStatus
import java.util.UUID

enum class AcknowledgementType { ACKNOWLEDGE, PRAISE, COMMENT, REVIEW }

class OccurrenceNotAcknowledgeable(val occurrenceId: UUID) :
    RuntimeException("Occurrence $occurrenceId is not in WAITING_ACK state")

/**
 * `WAITING_ACK -> ACKNOWLEDGED`, recording a human Acknowledgement.
 *
 * PRODUCT RED LINE #1 & #2 — this is the ONLY code path in the system that may
 * insert into `acknowledgements`. It requires an authenticated human actor and
 * an explicit send. No scheduler, event consumer, or completion handler may
 * reach it. "Automation prepares; the partner responds."
 */
@Service
class SendAcknowledgementService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {

    @Transactional
    fun send(
        actorUserId: UUID,
        occurrenceId: UUID,
        type: AcknowledgementType,
        text: String,
        idempotencyId: UUID,
    ): UUID {
        // `ACKNOWLEDGE` and `PRAISE` are the two-tap path and may carry no
        // words; `COMMENT` and `REVIEW` are words by definition. The database
        // enforces this too, but reaching it means a constraint violation and
        // a 500 where the caller should get a 400 naming the field.
        if (type == AcknowledgementType.COMMENT || type == AcknowledgementType.REVIEW) {
            if (text.isBlank()) {
                throw ApiException(HttpStatus.BAD_REQUEST, "TEXT_REQUIRED")
            }
        }

        val ctx = authorizer.requireMutate(
            authorizer.contextForOccurrence(actorUserId, occurrenceId),
            RoleContext.CREATOR,
        )

        // Guarded transition: only WAITING_ACK advances. A completion must
        // already exist, so an Acknowledgement can never precede a Completion.
        val moved = dsl.fetchOne(
            """
            UPDATE occurrences
               SET state = 'ACKNOWLEDGED', version = version + 1, updated_at = now()
             WHERE id = {0} AND state = 'WAITING_ACK'
            RETURNING id
            """.trimIndent(),
            occurrenceId,
        )
        if (moved == null) throw OccurrenceNotAcknowledgeable(occurrenceId)

        val ackId = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO acknowledgements (id, occurrence_id, sender_user_id, type, text, idempotency_id)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5})
            """.trimIndent(),
            ackId, occurrenceId, actorUserId, type.name, text, idempotencyId,
        ).execute()

        events.append(
            dynamicId = ctx.dynamicId,
            actorUserId = actorUserId,
            eventType = "acknowledgement_sent",
            objectRef = """{"occurrence_id":"$occurrenceId","acknowledgement_id":"$ackId"}""",
        )
        events.enqueueOutbox(
            aggregateType = "occurrence",
            aggregateId = occurrenceId,
            eventType = "acknowledgement_sent",
            dedupeKey = "acknowledgement:$ackId",
        )
        return ackId
    }
}
