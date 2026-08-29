package com.dsapp.backend.shared.idempotency

import org.springframework.stereotype.Service
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.TransactionDefinition
import org.springframework.transaction.TransactionStatus
import org.springframework.transaction.support.TransactionTemplate
import java.security.MessageDigest
import java.util.UUID

@Service
class IdempotencyService(
    transactionManager: PlatformTransactionManager,
    private val repository: IdempotencyRepository,
) {
    private val transactionTemplate =
        TransactionTemplate(transactionManager).apply {
            propagationBehavior =
                TransactionDefinition.PROPAGATION_REQUIRES_NEW
            isolationLevel =
                TransactionDefinition.ISOLATION_READ_COMMITTED
        }

    fun executeOnce(
        actorUserId: UUID,
        keyValue: String?,
        commandName: String,
        requestHash: ByteArray,
        command: (IdempotencyKey) -> IdempotencyResponse,
    ): IdempotencyOutcome {
        val validatedKey = validateKey(keyValue)

        require(commandName.isNotBlank()) {
            "commandName must not be blank"
        }

        if (requestHash.size != SHA_256_BYTES) {
            throw InvalidRequestHashException()
        }

        val stableRequestHash = requestHash.copyOf()

        return transactionTemplate.execute {
            executeInTransaction(
                transaction = it,
                actorUserId = actorUserId,
                keyValue = validatedKey,
                commandName = commandName,
                requestHash = stableRequestHash,
                command = command,
            )
        } ?: throw IdempotencyPersistenceException(
            "The idempotency transaction returned no outcome",
        )
    }

    private fun executeInTransaction(
        transaction: TransactionStatus,
        actorUserId: UUID,
        keyValue: String,
        commandName: String,
        requestHash: ByteArray,
        command: (IdempotencyKey) -> IdempotencyResponse,
    ): IdempotencyOutcome {
        val reservation = repository.tryReserve(
            id = UUID.randomUUID(),
            actorUserId = actorUserId,
            keyValue = keyValue,
            commandName = commandName,
            requestHash = requestHash,
        )

        if (reservation == null) {
            return replay(
                actorUserId = actorUserId,
                keyValue = keyValue,
                commandName = commandName,
                requestHash = requestHash,
            )
        }

        val savepoint = transaction.createSavepoint()

        val response = try {
            command(reservation)
        } catch (rejection: DeterministicBusinessRejection) {
            rollbackAndRelease(transaction, savepoint)
            repository.complete(reservation.id, rejection.response)

            return IdempotencyOutcome.Executed(
                status = rejection.response.status,
                body = rejection.response.body.copyOf(),
            )
        }

        when (response.status) {
            in 400..499 -> {
                rollbackAndRelease(transaction, savepoint)
            }

            in 500..599 -> {
                throw UnexpectedCommandResponseException(response.status)
            }

            else -> {
                transaction.releaseSavepoint(savepoint)
            }
        }

        repository.complete(reservation.id, response)

        return IdempotencyOutcome.Executed(
            status = response.status,
            body = response.body.copyOf(),
        )
    }

    private fun replay(
        actorUserId: UUID,
        keyValue: String,
        commandName: String,
        requestHash: ByteArray,
    ): IdempotencyOutcome {
        val existing = repository.find(actorUserId, keyValue)
            ?: throw IdempotencyPersistenceException(
                "The conflicting idempotency key disappeared before it could be read",
            )

        if (
            existing.commandName != commandName ||
            !MessageDigest.isEqual(existing.requestHash, requestHash)
        ) {
            throw IdempotencyKeyReusedException()
        }

        if (existing.state != IdempotencyState.COMPLETED) {
            throw IdempotencyPersistenceException(
                "A committed idempotency key was unexpectedly ${existing.state}",
            )
        }

        val status = existing.responseStatus
            ?: throw IdempotencyPersistenceException(
                "A completed idempotency key has no response status",
            )

        return IdempotencyOutcome.Replayed(
            status = status,
            body = existing.responseBody?.copyOf() ?: ByteArray(0),
        )
    }

    private fun rollbackAndRelease(
        transaction: TransactionStatus,
        savepoint: Any,
    ) {
        transaction.rollbackToSavepoint(savepoint)
        transaction.releaseSavepoint(savepoint)
    }

    private fun validateKey(keyValue: String?): String {
        if (keyValue == null) {
            throw MissingIdempotencyKeyException()
        }

        if (keyValue.isBlank()) {
            throw InvalidIdempotencyKeyException(
                "Idempotency-Key must not be blank",
            )
        }

        if (keyValue.length > MAX_KEY_LENGTH) {
            throw InvalidIdempotencyKeyException(
                "Idempotency-Key must not exceed $MAX_KEY_LENGTH characters",
            )
        }

        return keyValue
    }

    private companion object {
        const val SHA_256_BYTES = 32
        const val MAX_KEY_LENGTH = 255
    }
}
