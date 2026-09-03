package com.dsapp.backend.shared.api

import com.dsapp.backend.shared.idempotency.IdempotencyResponse
import com.dsapp.backend.shared.idempotency.IdempotencyService
import com.dsapp.backend.shared.idempotency.RequestHasher
import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.http.CacheControl
import org.springframework.http.ResponseEntity
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Component

/**
 * Wraps a POST so a retry replays instead of re-executing. A tap on a flaky
 * connection must never deliver twice or issue two consequences.
 */
@Component
class IdempotentPost(
    private val idempotency: IdempotencyService,
    private val mapper: ObjectMapper,
) {
    fun run(
        jwt: Jwt,
        key: String?,
        command: String,
        route: String,
        pathIds: List<String>,
        payload: Any?,
        block: () -> Pair<Int, Any>,
    ): ResponseEntity<Any> {
        val body = payload?.let { mapper.writeValueAsBytes(it) } ?: ByteArray(0)
        val hash = RequestHasher.sha256(
            method = "POST",
            routeTemplate = route,
            pathIds = pathIds,
            contentType = "application/json",
            exactBody = body,
        )
        val outcome = idempotency.executeOnce(jwt.actorId(), key, command, hash) {
            val (status, result) = block()
            IdempotencyResponse(status, mapper.writeValueAsBytes(result))
        }
        val builder = ResponseEntity.status(outcome.status).cacheControl(CacheControl.noStore())
        outcome.headers.forEach { (k, v) -> builder.header(k, v) }
        return builder.body(mapper.readValue(outcome.body, Any::class.java))
    }
}
