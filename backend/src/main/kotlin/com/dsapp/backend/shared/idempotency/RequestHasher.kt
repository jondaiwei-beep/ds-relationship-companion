package com.dsapp.backend.shared.idempotency

import java.nio.ByteBuffer
import java.nio.charset.StandardCharsets
import java.security.MessageDigest
import java.util.Locale

object RequestHasher {
    private val DOMAIN_SEPARATOR =
        "dsapp-idempotency-request-v1"
            .toByteArray(StandardCharsets.UTF_8)

    fun sha256(
        method: String,
        routeTemplate: String,
        pathIds: List<String>,
        contentType: String?,
        exactBody: ByteArray,
    ): ByteArray {
        require(method.isNotBlank()) {
            "method must not be blank"
        }

        require(routeTemplate.isNotBlank()) {
            "routeTemplate must not be blank"
        }

        val digest = MessageDigest.getInstance("SHA-256")

        digest.updateLengthPrefixed(DOMAIN_SEPARATOR)
        digest.updateLengthPrefixed(
            method
                .uppercase(Locale.ROOT)
                .toByteArray(StandardCharsets.UTF_8),
        )
        digest.updateLengthPrefixed(
            routeTemplate.toByteArray(StandardCharsets.UTF_8),
        )

        digest.updateInt(pathIds.size)
        pathIds.forEach {
            digest.updateLengthPrefixed(
                it.toByteArray(StandardCharsets.UTF_8),
            )
        }

        if (contentType == null) {
            digest.update(0.toByte())
        } else {
            digest.update(1.toByte())
            digest.updateLengthPrefixed(
                contentType.toByteArray(StandardCharsets.UTF_8),
            )
        }

        digest.updateLengthPrefixed(exactBody)

        return digest.digest()
    }

    private fun MessageDigest.updateLengthPrefixed(
        value: ByteArray,
    ) {
        updateInt(value.size)
        update(value)
    }

    private fun MessageDigest.updateInt(value: Int) {
        update(
            ByteBuffer
                .allocate(Int.SIZE_BYTES)
                .putInt(value)
                .array(),
        )
    }
}
