package com.dsapp.backend.dynamic.api

import com.dsapp.backend.dynamic.application.CreateDynamicService
import com.dsapp.backend.dynamic.application.DynamicQueryService
import com.dsapp.backend.dynamic.application.InviteService
import com.dsapp.backend.dynamic.application.LeaveBlockService
import com.dsapp.backend.dynamic.domain.RoleContext
import com.dsapp.backend.shared.api.actorId
import com.dsapp.backend.shared.idempotency.IdempotencyResponse
import com.dsapp.backend.shared.idempotency.IdempotencyService
import com.dsapp.backend.shared.idempotency.RequestHasher
import com.fasterxml.jackson.databind.ObjectMapper
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Pattern
import org.springframework.http.CacheControl
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Instant
import java.util.UUID

data class CreateDynamicRequest(
    @field:Pattern(regexp = "SOLO|COUPLE", message = "mode")
    val mode: String = "COUPLE",

    /**
     * Checked here because it decides behaviour, not just what is stored.
     *
     * `StarterRhythmService` parses this back into [DesiredOutcome] and falls
     * back to CLOSER when it cannot — so an unrecognised value did not fail,
     * it quietly gave someone the wrong starter rhythm. Lowercase did the same
     * thing. The column has no CHECK, so the boundary is the only place this
     * can be caught.
     */
    @field:Pattern(
        regexp = "CLOSER|STRUCTURE|SERVICE|ACCOUNTABILITY|EXPLORE",
        message = "desiredOutcome",
    )
    val desiredOutcome: String,

    /** Light / Steady / Defined, per the approved SCR-08 candidate. */
    @field:Pattern(regexp = "LIGHT|STEADY|DEFINED", message = "structureLevel")
    val structureLevel: String,

    @field:NotBlank val referenceTimezone: String,
    /** Minutes after local midnight the relationship day turns over. Default 04:00 (D-04). */
    val dayBoundaryMinutes: Int = 240,

    /**
     * Which side the creator takes. Derived from the preset when the client
     * did not say: a SUBMISSIVE creator delivers, everyone else disposes.
     */
    @field:Pattern(regexp = "D|S", message = "side")
    val side: String? = null,

    /**
     * Whether the couple is apart (REQ-ACT-002).
     *
     * Defaulted rather than required: an older client that does not send it
     * must keep working, and "Together" is the answer the wizard shows
     * selected.
     */
    val longDistance: Boolean = false,

    /**
     * Optional self-description. Grants nothing (Notion 03 §2), and a couple
     * that does not want to name it must never be blocked — hence nullable.
     */
    @field:Pattern(
        regexp = "DOMINANT|SUBMISSIVE|SWITCH|CUSTOM",
        message = "rolePreset",
    )
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

data class UpdateDynamicSettingsRequest(
    val timezone: String? = null,
    val dayBoundaryMinutes: Int? = null,
    val honorificForD: String? = null,
    val honorificForS: String? = null,
    val safeword: String? = null,
)

data class LeaveBody(val reason: String? = null)

/** Blocking names the person being blocked. They are never told who did it. */
data class BlockBody(val targetUserId: UUID, val reason: String? = null)

@RestController
@RequestMapping("/v1")
class DynamicController(
    private val createDynamic: CreateDynamicService,
    private val invites: InviteService,
    private val dynamics: DynamicQueryService,
    private val leaveBlock: LeaveBlockService,
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
            longDistance = body.longDistance,
            side = body.side ?: if (body.rolePreset == "SUBMISSIVE") "S" else "D",
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

    /** Settings — timezone, day boundary, honorifics, safeword. Either side may edit (pre-launch decision). */
    @PutMapping("/dynamics/{dynamicId}/settings")
    fun updateSettings(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestBody body: UpdateDynamicSettingsRequest,
    ): ResponseEntity<Any> = ResponseEntity.ok()
        .cacheControl(CacheControl.noStore())
        .body(
            dynamics.updateSettings(
                actorUserId = jwt.actorId(),
                dynamicId = dynamicId,
                timezone = body.timezone,
                dayBoundaryMinutes = body.dayBoundaryMinutes,
                honorificForD = body.honorificForD,
                honorificForS = body.honorificForS,
                safeword = body.safeword,
            ),
        )

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
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "resume_dynamic", "/v1/dynamics/{id}/resume",
        listOf(dynamicId.toString()), null,
    ) {
        dynamics.resume(jwt.actorId(), dynamicId)
        200 to mapOf("state" to "ACTIVE")
    }

    /**
     * Leave — Journey F. No partner approval, ever.
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
    /**
     * Withdraw a live invitation.
     *
     * Scoped to the Dynamic in the path, so a caller cannot revoke by
     * guessing an invite id belonging to somewhere they are not a member.
     */
    @PostMapping("/dynamics/{dynamicId}/invites/{inviteId}/revoke")
    fun revokeInvite(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable inviteId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "revoke_invite", "/v1/dynamics/{id}/invites/{inviteId}/revoke",
        listOf(dynamicId.toString(), inviteId.toString()), null,
    ) {
        invites.revoke(jwt.actorId(), dynamicId, inviteId)
        200 to mapOf("state" to "REVOKED")
    }

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
