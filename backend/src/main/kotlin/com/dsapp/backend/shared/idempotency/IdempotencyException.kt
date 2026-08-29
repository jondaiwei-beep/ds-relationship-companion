package com.dsapp.backend.shared.idempotency

sealed class IdempotencyException(
    val httpStatus: Int,
    val errorCode: String,
    message: String,
    cause: Throwable? = null,
) : RuntimeException(message, cause)

class MissingIdempotencyKeyException : IdempotencyException(
    httpStatus = 400,
    errorCode = "IDEMPOTENCY_KEY_REQUIRED",
    message = "Idempotency-Key is required",
)

class InvalidIdempotencyKeyException(
    message: String,
) : IdempotencyException(
    httpStatus = 400,
    errorCode = "INVALID_IDEMPOTENCY_KEY",
    message = message,
)

class InvalidRequestHashException : IdempotencyException(
    httpStatus = 500,
    errorCode = "INVALID_IDEMPOTENCY_REQUEST_HASH",
    message = "The idempotency request hash must contain exactly 32 bytes",
)

class IdempotencyKeyReusedException : IdempotencyException(
    httpStatus = 422,
    errorCode = "IDEMPOTENCY_KEY_REUSED",
    message = "The Idempotency-Key was already used for a different request",
)

class DeterministicBusinessRejection(
    val response: IdempotencyResponse,
) : IdempotencyException(
    httpStatus = response.status,
    errorCode = "DETERMINISTIC_BUSINESS_REJECTION",
    message = "The command was deterministically rejected with status ${response.status}",
) {
    init {
        require(response.status in 400..499)
    }
}

class IdempotencyPersistenceException(
    message: String,
) : IdempotencyException(
    httpStatus = 500,
    errorCode = "IDEMPOTENCY_PERSISTENCE_FAILURE",
    message = message,
)

class UnexpectedCommandResponseException(
    status: Int,
) : IdempotencyException(
    httpStatus = 500,
    errorCode = "UNEXPECTED_COMMAND_RESPONSE",
    message = "The command returned an unexpected $status response",
)
