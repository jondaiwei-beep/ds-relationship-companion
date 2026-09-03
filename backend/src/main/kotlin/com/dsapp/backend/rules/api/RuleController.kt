package com.dsapp.backend.rules.api

import com.dsapp.backend.rules.application.RuleService
import com.dsapp.backend.shared.api.IdempotentPost
import com.dsapp.backend.shared.api.actorId
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

data class CreateRuleBody(
    @field:NotBlank @field:Size(max = 120) val title: String,
    @field:Size(max = 2000) val body: String? = null,
    val group: String = "other",
)

data class EditRuleBody(
    @field:Size(max = 120) val title: String? = null,
    @field:Size(max = 2000) val body: String? = null,
    val group: String? = null,
    val position: Int? = null,
)

private fun RuleService.RuleView.toMap() = mapOf(
    "id" to id, "title" to title, "body" to body, "group" to group,
    "createdBy" to createdBy, "status" to status, "position" to position,
    "createdAt" to createdAt, "updatedAt" to updatedAt,
)

@RestController
@RequestMapping("/v1/dynamics/{dynamicId}/rules")
class RuleController(private val rules: RuleService, private val post: IdempotentPost) {

    @GetMapping
    fun list(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam(defaultValue = "false") includeArchived: Boolean,
    ): ResponseEntity<Any> = ResponseEntity.ok(
        mapOf("rules" to rules.list(jwt.actorId(), dynamicId, includeArchived).map { it.toMap() }),
    )

    @PostMapping
    fun create(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: CreateRuleBody,
    ): ResponseEntity<Any> = post.run(jwt, key, "create_rule", "/v1/dynamics/{id}/rules", listOf("$dynamicId"), body) {
        201 to rules.create(jwt.actorId(), dynamicId, RuleService.NewRule(body.title, body.body, body.group)).toMap()
    }

    @PatchMapping("/{ruleId}")
    fun update(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable ruleId: UUID,
        @Valid @RequestBody body: EditRuleBody,
    ): ResponseEntity<Any> = ResponseEntity.ok(
        rules.update(jwt.actorId(), dynamicId, ruleId, RuleService.RuleEdit(body.title, body.body, body.group, body.position)).toMap(),
    )

    @PostMapping("/{ruleId}/archive")
    fun archive(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable ruleId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = post.run(jwt, key, "archive_rule", "/v1/dynamics/{id}/rules/{r}/archive", listOf("$dynamicId", "$ruleId"), null) {
        rules.archive(jwt.actorId(), dynamicId, ruleId)
        200 to mapOf("status" to "archived")
    }

    @PostMapping("/{ruleId}/accept")
    fun accept(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable ruleId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = post.run(jwt, key, "accept_rule", "/v1/dynamics/{id}/rules/{r}/accept", listOf("$dynamicId", "$ruleId"), null) {
        200 to rules.accept(jwt.actorId(), dynamicId, ruleId).toMap()
    }
}
