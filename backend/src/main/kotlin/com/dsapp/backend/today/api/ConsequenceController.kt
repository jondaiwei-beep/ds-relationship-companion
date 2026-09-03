package com.dsapp.backend.today.api

import com.dsapp.backend.shared.api.IdempotentPost
import com.dsapp.backend.shared.api.actorId
import com.dsapp.backend.today.application.ConsequenceLifecycleService
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

private fun ConsequenceLifecycleService.ConsequenceView.toMap() = mapOf(
    "id" to id, "dynamicId" to dynamicId, "issuedBy" to issuedBy, "title" to title, "detail" to detail,
    "status" to status, "issuedAt" to issuedAt, "doneAt" to doneAt, "decidedAt" to decidedAt,
)

/**
 * Consequence lifecycle (product/03-domain.md §Consequence). Creating one
 * happens through disposition `punished` (today/application/DispositionService);
 * this controller only advances what was already issued.
 */
@RestController
class ConsequenceController(private val lifecycle: ConsequenceLifecycleService, private val post: IdempotentPost) {

    @GetMapping("/v1/dynamics/{dynamicId}/consequences")
    fun list(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam(required = false) status: String?,
    ): ResponseEntity<Any> = ResponseEntity.ok(
        mapOf("consequences" to lifecycle.list(jwt.actorId(), dynamicId, status).map { it.toMap() }),
    )

    @PostMapping("/v1/consequences/{consequenceId}/done")
    fun done(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable consequenceId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = post.run(jwt, key, "consequence_done", "/v1/consequences/{c}/done", listOf("$consequenceId"), null) {
        200 to lifecycle.done(jwt.actorId(), consequenceId).toMap()
    }

    @PostMapping("/v1/consequences/{consequenceId}/confirm")
    fun confirm(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable consequenceId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = post.run(jwt, key, "consequence_confirm", "/v1/consequences/{c}/confirm", listOf("$consequenceId"), null) {
        200 to lifecycle.confirm(jwt.actorId(), consequenceId).toMap()
    }

    @PostMapping("/v1/consequences/{consequenceId}/waive")
    fun waive(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable consequenceId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = post.run(jwt, key, "consequence_waive", "/v1/consequences/{c}/waive", listOf("$consequenceId"), null) {
        200 to lifecycle.waive(jwt.actorId(), consequenceId).toMap()
    }
}
