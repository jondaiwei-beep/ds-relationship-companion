package com.dsapp.backend.shared.idempotency

import com.fasterxml.jackson.core.JsonProcessingException
import com.fasterxml.jackson.databind.ObjectMapper
import org.jooq.DSLContext
import org.springframework.http.InvalidMediaTypeException
import org.springframework.http.MediaType
import org.springframework.stereotype.Service
import java.util.UUID

data class CompleteOccurrenceCommand(
    val actorUserId: UUID,
    val occurrenceId: UUID,
    val idempotencyKey: String?,
    val contentType: String?,
    val exactRequestBody: ByteArray,
)

data class CompleteOccurrenceRequestBody(
    val note: String? = null,
)

@Service
class CompleteOccurrenceCommandHandler(
    private val idempotencyService: IdempotencyService,
    private val dsl: DSLContext,
    private val objectMapper: ObjectMapper,
) {
    fun handle(
        command: CompleteOccurrenceCommand,
    ): IdempotencyOutcome {
        val requestHash = RequestHasher.sha256(
            method = "POST",
            routeTemplate = ROUTE_TEMPLATE,
            pathIds = listOf(command.occurrenceId.toString()),
            contentType = command.contentType,
            exactBody = command.exactRequestBody,
        )

        return idempotencyService.executeOnce(
            actorUserId = command.actorUserId,
            keyValue = command.idempotencyKey,
            commandName = COMMAND_NAME,
            requestHash = requestHash,
        ) { idempotencyKey ->
            val request = parseRequest(command)
            complete(
                command = command,
                request = request,
                idempotencyId = idempotencyKey.id,
            )
        }
    }

    private fun complete(
        command: CompleteOccurrenceCommand,
        request: CompleteOccurrenceRequestBody,
        idempotencyId: UUID,
    ): IdempotencyResponse {
        val updated = dsl.query(
            """
            UPDATE occurrences AS o
            SET
                state = 'WAITING_ACK',
                version = o.version + 1,
                updated_at = now()
            WHERE o.id = ?
              AND o.state IN ('SCHEDULED', 'ACTIVE')
              AND EXISTS (
                  SELECT 1
                  FROM memberships AS m
                  WHERE m.dynamic_id = o.dynamic_id
                    AND m.user_id = ?
                    AND m.access_state = 'ACTIVE'
              )
            """.trimIndent(),
            command.occurrenceId,
            command.actorUserId,
        ).execute()

        if (updated != 1) {
            rejectUnavailableOccurrence(command)
        }

        val completionId = UUID.randomUUID()

        val inserted = dsl.query(
            """
            INSERT INTO occurrence_completions (
                id,
                occurrence_id,
                actor_user_id,
                note,
                idempotency_id
            )
            VALUES (?, ?, ?, ?, ?)
            """.trimIndent(),
            completionId,
            command.occurrenceId,
            command.actorUserId,
            request.note,
            idempotencyId,
        ).execute()

        if (inserted != 1) {
            throw IdempotencyPersistenceException(
                "Expected to insert one occurrence completion; inserted $inserted",
            )
        }

        return IdempotencyResponse(
            status = 201,
            body = objectMapper.writeValueAsBytes(
                linkedMapOf(
                    "completionId" to completionId,
                    "occurrenceId" to command.occurrenceId,
                    "state" to "WAITING_ACK",
                ),
            ),
        )
    }

    private fun parseRequest(
        command: CompleteOccurrenceCommand,
    ): CompleteOccurrenceRequestBody {
        val rawContentType = command.contentType
            ?: reject(415, "UNSUPPORTED_MEDIA_TYPE")

        val mediaType = try {
            MediaType.parseMediaType(rawContentType)
        } catch (_: InvalidMediaTypeException) {
            reject(415, "UNSUPPORTED_MEDIA_TYPE")
        }

        if (!MediaType.APPLICATION_JSON.isCompatibleWith(mediaType)) {
            reject(415, "UNSUPPORTED_MEDIA_TYPE")
        }

        return try {
            objectMapper.readValue(
                command.exactRequestBody,
                CompleteOccurrenceRequestBody::class.java,
            )
        } catch (_: JsonProcessingException) {
            reject(400, "INVALID_REQUEST_BODY")
        }
    }

    private fun rejectUnavailableOccurrence(
        command: CompleteOccurrenceCommand,
    ): Nothing {
        val state = dsl.fetchOne(
            """
            SELECT o.state
            FROM occurrences AS o
            WHERE o.id = ?
              AND EXISTS (
                  SELECT 1
                  FROM memberships AS m
                  WHERE m.dynamic_id = o.dynamic_id
                    AND m.user_id = ?
                    AND m.access_state = 'ACTIVE'
              )
            """.trimIndent(),
            command.occurrenceId,
            command.actorUserId,
        )?.get("state", String::class.java)

        if (state == null) {
            reject(404, "OCCURRENCE_NOT_FOUND")
        }

        reject(409, "OCCURRENCE_NOT_COMPLETABLE")
    }

    private fun reject(
        status: Int,
        code: String,
    ): Nothing {
        throw DeterministicBusinessRejection(
            IdempotencyResponse(
                status = status,
                body = objectMapper.writeValueAsBytes(
                    linkedMapOf("code" to code),
                ),
            ),
        )
    }

    private companion object {
        const val COMMAND_NAME = "complete occurrence"
        const val ROUTE_TEMPLATE =
            "/api/v1/occurrences/{occurrenceId}/complete"
    }
}
