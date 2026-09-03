package com.dsapp.backend.today.api

import com.dsapp.backend.shared.api.IdempotentPost
import com.dsapp.backend.shared.api.actorId
import com.dsapp.backend.today.application.AwayService
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Instant
import java.util.UUID

data class AwayBody(val until: Instant)

/** D「我不在」— product/03-domain.md, D-26. */
@RestController
@RequestMapping("/v1/dynamics/{dynamicId}")
class AwayController(private val away: AwayService, private val post: IdempotentPost) {

    @PostMapping("/away")
    fun away(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @RequestBody body: AwayBody,
    ): ResponseEntity<Any> = post.run(jwt, key, "d_away", "/v1/dynamics/{id}/away", listOf("$dynamicId"), body) {
        200 to mapOf("dAwayUntil" to away.away(jwt.actorId(), dynamicId, body.until))
    }

    @PostMapping("/back")
    fun back(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = post.run(jwt, key, "d_back", "/v1/dynamics/{id}/back", listOf("$dynamicId"), null) {
        away.back(jwt.actorId(), dynamicId)
        200 to mapOf("dAwayUntil" to null)
    }
}
