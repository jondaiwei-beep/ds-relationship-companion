package com.dsapp.backend.dynamic.api

import com.dsapp.backend.dynamic.application.CreateDynamicService
import com.dsapp.backend.dynamic.application.DynamicQueryService
import com.dsapp.backend.dynamic.application.InviteService
import com.dsapp.backend.dynamic.application.LeaveBlockService
import com.dsapp.backend.timeline.application.UsQueryService
import com.dsapp.backend.timeline.application.WeeklyReflectionService
import com.dsapp.backend.dynamic.domain.RoleContext
import com.dsapp.backend.shared.api.actorId
import com.dsapp.backend.shared.idempotency.IdempotencyResponse
import com.dsapp.backend.shared.idempotency.IdempotencyService
import com.dsapp.backend.shared.idempotency.RequestHasher
import com.fasterxml.jackson.databind.ObjectMapper
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import org.springframework.http.CacheControl
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Instant
import java.util.UUID

data class CreateDynamicRequest(
    val mode: String = "COUPLE",
    @field:NotBlank val desiredOutcome: String,
    @field:NotBlank val structureLevel: String,
    @field:NotBlank val referenceTimezone: String,
    val dayBoundaryMinutes: Int = 0,
    /** Optional self-description. Grants nothing (Notion 03 §2). */
    val rolePreset: String? = null,
)

data class CreateDynamicResponse(val dynamicId: UUID, val membershipId: UUID)

data class CreateInviteResponse(
    val inviteId: UUID,
    /** Returned exactly once. Only the hash is persisted. */
    val token: String,
    val inviteUrl: String,
    val expiresAt: Instant,
)

data class ResolveInviteRequest(@field:NotBlank val token: String)

data class JoinInviteRequest(@field:NotBlank val token: String)

data class JoinInviteResponse(val membershipId: UUID)

data class LeaveBody(val reason: String? = null)

/** Blocking names the person being blocked. They are never told who did it. */
data class BlockBody(val targetUserId: UUID, val reason: String? = null)

@RestController
@RequestMapping("/v1")
class DynamicController(
    private val createDynamic: CreateDynamicService,
    private val invites: InviteService,
    private val dynamics: DynamicQueryService,
    private val us: UsQueryService,
    private val leaveBlock: LeaveBlockService,
    private val weekly: WeeklyReflectionService,
    private val idempotency: IdempotencyService,
    private val mapper: ObjectMapper,
) {

    @PostMapping("/dynamics")
    fun create(
        @AuthenticationPrincipal jwt: Jwt,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: CreateDynamicRequest,
    ): ResponseEntity<Any> = runOnce(jwt, key, "create_dynamic", "/v1/dynamics", emptyList(), body) {
        val c = createDynamic.create(
            actorUserId = jwt.actorId(),
            mode = body.mode,
            desiredOutcome = body.desiredOutcome,
            rolePreset = body.rolePreset,
            structureLevel = body.structureLevel,
            referenceTimezone = body.referenceTimezone,
            dayBoundaryMinutes = body.dayBoundaryMinutes,
        )
        201 to CreateDynamicResponse(c.dynamicId, c.membershipId)
    }

    @PostMapping("/dynamics/{dynamicId}/invites")
    fun createInvite(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = runOnce(jwt, key, "create_invite", "/v1/dynamics/{id}/invites", listOf(dynamicId.toString()), null) {
        val i = invites.create(jwt.actorId(), dynamicId, RoleContext.PARTNER)
        201 to CreateInviteResponse(
            inviteId = i.inviteId,
            token = i.token,
            inviteUrl = "/invite/${i.token}",
            expiresAt = i.expiresAt,
        )
    }

    /** Dynamic — what rhythm we are currently running (Journey, Notion 02 §10). */
    /** Which dynamics am I in? The client's entry point after signing in. */
    @GetMapping("/dynamics")
    fun mine(@AuthenticationPrincipal jwt: Jwt): ResponseEntity<Any> =
        ResponseEntity.ok()
            .cacheControl(CacheControl.noStore())
            .body(dynamics.forUser(jwt.actorId()))

    @GetMapping("/dynamics/{dynamicId}")
    fun detail(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
    ): ResponseEntity<Any> = ResponseEntity.ok()
        .cacheControl(CacheControl.noStore())
        .body(dynamics.detail(jwt.actorId(), dynamicId))

    /** Us — what recently happened between us (Notion 02 §8). */
    @GetMapping("/dynamics/{dynamicId}/us")
    fun usFor(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
    ): ResponseEntity<Any> = ResponseEntity.ok()
        .cacheControl(CacheControl.noStore())
        .body(us.forDynamic(jwt.actorId(), dynamicId))

    /** D7 Weekly Reflection — deliberately light (Notion 02 §8). */
    @GetMapping("/dynamics/{dynamicId}/weekly")
    fun weeklyFor(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
    ): ResponseEntity<Any> = ResponseEntity.ok()
        .cacheControl(CacheControl.noStore())
        .body(weekly.forDynamic(jwt.actorId(), dynamicId))

    /** Pause — inviolable agency: either member may pause (Notion 04 §4). */
    @PostMapping("/dynamics/{dynamicId}/pause")
    fun pause(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "pause_dynamic", "/v1/dynamics/{id}/pause",
        listOf(dynamicId.toString()), null,
    ) {
        dynamics.pause(jwt.actorId(), dynamicId)
        200 to mapOf("state" to "PAUSED")
    }

    @PostMapping("/dynamics/{dynamicId}/resume")
    fun resume(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        /** Journey E: come back to a lighter structure, not the same load. */
        @RequestParam(defaultValue = "false") lighter: Boolean,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "resume_dynamic", "/v1/dynamics/{id}/resume",
        listOf(dynamicId.toString(), lighter.toString()), null,
    ) {
        dynamics.resume(jwt.actorId(), dynamicId, lighter = lighter)
        200 to mapOf("state" to "ACTIVE")
    }

    /**
     * Leave — Journey F. No partner approval, ever (red line #4).
     */
    @PostMapping("/dynamics/{dynamicId}/leave")
    fun leave(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @RequestBody(required = false) body: LeaveBody?,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "leave_dynamic", "/v1/dynamics/{id}/leave",
        listOf(dynamicId.toString()), body,
    ) {
        leaveBlock.leave(jwt.actorId(), dynamicId, body?.reason)
        200 to mapOf("accessState" to "LEFT")
    }

    /**
     * Block — the safety action. Immediate, mutual in effect, and silent.
     */
    @PostMapping("/dynamics/{dynamicId}/block")
    fun block(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: BlockBody,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "block_member", "/v1/dynamics/{id}/block",
        listOf(dynamicId.toString()), body,
    ) {
        leaveBlock.block(jwt.actorId(), dynamicId, body.targetUserId, body.reason)
        200 to mapOf("accessState" to "BLOCKED")
    }

    /** Anonymous. Never 404s — every terminal state is explicit (Notion 02 §A4). */
    @PostMapping("/invites/resolve")
    fun resolve(@Valid @RequestBody body: ResolveInviteRequest): ResponseEntity<Any> =
        ResponseEntity.ok()
            .cacheControl(CacheControl.noStore())
            .body(invites.resolve(body.token))

    @PostMapping("/invites/join")
    fun join(
        @AuthenticationPrincipal jwt: Jwt,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: JoinInviteRequest,
    ): ResponseEntity<Any> = runOnce(jwt, key, "join_invite", "/v1/invites/join", emptyList(), body) {
        201 to JoinInviteResponse(invites.join(jwt.actorId(), body.token))
    }

    /** Wraps a command so a retry replays instead of re-executing (Notion 03 §6). */
    private fun runOnce(
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
            val (status, body) = block()
            IdempotencyResponse(status, mapper.writeValueAsBytes(body))
        }
        val builder = ResponseEntity.status(outcome.status).cacheControl(CacheControl.noStore())
        outcome.headers.forEach { (k, v) -> builder.header(k, v) }
        return builder.body(mapper.readValue(outcome.body, Any::class.java))
    }
}
