package com.dsapp.backend.shared.idempotency

import org.jooq.DSLContext
import org.jooq.Record
import org.springframework.stereotype.Repository
import java.time.OffsetDateTime
import java.util.UUID

@Repository
class IdempotencyRepository(
    private val dsl: DSLContext,
) {
    fun tryReserve(
        id: UUID,
        actorUserId: UUID,
        keyValue: String,
        commandName: String,
        requestHash: ByteArray,
    ): IdempotencyKey? =
        dsl.fetchOne(
            """
            INSERT INTO idempotency_keys (
                id,
                actor_user_id,
                key_value,
                command_name,
                request_hash,
                state
            )
            VALUES (?, ?, ?, ?, ?, 'IN_PROGRESS')
            ON CONFLICT (actor_user_id, key_value) DO NOTHING
            RETURNING
                id,
                actor_user_id,
                key_value,
                command_name,
                request_hash,
                state,
                response_status,
                response_body,
                created_at,
                completed_at
            """.trimIndent(),
            id,
            actorUserId,
            keyValue,
            commandName,
            requestHash,
        )?.toIdempotencyKey()

    fun find(
        actorUserId: UUID,
        keyValue: String,
    ): IdempotencyKey? =
        dsl.fetchOne(
            """
            SELECT
                id,
                actor_user_id,
                key_value,
                command_name,
                request_hash,
                state,
                response_status,
                response_body,
                created_at,
                completed_at
            FROM idempotency_keys
            WHERE actor_user_id = ?
              AND key_value = ?
            """.trimIndent(),
            actorUserId,
            keyValue,
        )?.toIdempotencyKey()

    fun complete(
        id: UUID,
        response: IdempotencyResponse,
    ) {
        val updated = dsl.query(
            """
            UPDATE idempotency_keys
            SET
                state = 'COMPLETED',
                response_status = ?,
                response_body = ?,
                completed_at = now()
            WHERE id = ?
              AND state = 'IN_PROGRESS'
            """.trimIndent(),
            response.status,
            response.body,
            id,
        ).execute()

        if (updated != 1) {
            throw IdempotencyPersistenceException(
                "Expected to complete one IN_PROGRESS idempotency key; updated $updated",
            )
        }
    }

    private fun Record.toIdempotencyKey(): IdempotencyKey =
        IdempotencyKey(
            id = required("id", UUID::class.java),
            actorUserId = required("actor_user_id", UUID::class.java),
            keyValue = required("key_value", String::class.java),
            commandName = required("command_name", String::class.java),
            requestHash = required("request_hash", ByteArray::class.java),
            state = IdempotencyState.valueOf(
                required("state", String::class.java),
            ),
            responseStatus = get(
                "response_status",
                Int::class.javaObjectType,
            ),
            responseBody = get(
                "response_body",
                ByteArray::class.java,
            ),
            createdAt = required(
                "created_at",
                OffsetDateTime::class.java,
            ).toInstant(),
            completedAt = get(
                "completed_at",
                OffsetDateTime::class.java,
            )?.toInstant(),
        )

    private fun <T : Any> Record.required(
        fieldName: String,
        type: Class<T>,
    ): T =
        get(fieldName, type)
            ?: throw IdempotencyPersistenceException(
                "idempotency_keys.$fieldName was unexpectedly null",
            )
}
