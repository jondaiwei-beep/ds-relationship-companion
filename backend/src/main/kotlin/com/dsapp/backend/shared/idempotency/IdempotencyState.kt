package com.dsapp.backend.shared.idempotency

import java.time.Instant
import java.util.UUID

enum class IdempotencyState {
    IN_PROGRESS,
    COMPLETED,
}

data class IdempotencyKey(
    val id: UUID,
    val actorUserId: UUID,
    val keyValue: String,
    val commandName: String,
    val requestHash: ByteArray,
    val state: IdempotencyState,
    val responseStatus: Int?,
    val responseBody: ByteArray?,
    val createdAt: Instant,
    val completedAt: Instant?,
)

data class IdempotencyResponse(
    val status: Int,
    val body: ByteArray,
) {
    init {
        require(status in 100..599)
    }
}

sealed interface IdempotencyOutcome {
    val status: Int
    val body: ByteArray
    val headers: Map<String, String>

    data class Executed(
        override val status: Int,
        override val body: ByteArray,
    ) : IdempotencyOutcome {
        override val headers: Map<String, String> = emptyMap()
    }

    data class Replayed(
        override val status: Int,
        override val body: ByteArray,
    ) : IdempotencyOutcome {
        override val headers: Map<String, String> =
            mapOf(IdempotencyOutcome.REPLAYED_HEADER to "true")
    }

    companion object {
        const val REPLAYED_HEADER = "Idempotency-Replayed"
    }
}
