package com.dsapp.backend.expectation.api

import com.dsapp.backend.expectation.application.CompleteOccurrenceService
import com.dsapp.backend.expectation.application.CreateExpectationService
import com.dsapp.backend.expectation.application.OccurrenceQueryService
import com.dsapp.backend.expectation.application.ReceiveOccurrenceService
import com.dsapp.backend.expectation.application.TodayQueryService
import com.dsapp.backend.response.application.AcknowledgementType
import com.dsapp.backend.response.application.AdjustmentResolution
import com.dsapp.backend.response.application.AdjustmentService
import com.dsapp.backend.response.application.AdjustmentType
import com.dsapp.backend.response.application.AttentionQueryService
import com.dsapp.backend.response.application.SendAcknowledgementService
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
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Instant
import java.util.UUID

data class CreateExpectationRequest(
    @field:NotBlank val title: String,
    val purpose: String? = null,
    val assigneeUserId: UUID,
    val dueAt: Instant? = null,
)

data class CreateExpectationResponse(val definitionId: UUID, val occurrenceId: UUID)

/**
 * [proofMediaId] is a photo the completer chose to attach. There is no
 * companion field for requiring one, deliberately: optional is the whole
 * difference between showing someone what you did and being audited.
 */
data class CompleteRequest(val note: String? = null, val proofMediaId: String? = null)

data class CompleteResponse(val completionId: UUID, val state: String)

data class ReceiveResponse(val occurrenceId: UUID, val receivedAt: Instant)

/**
 * A human response to a completion.
 *
 * `ACKNOWLEDGE` and `PRAISE` may carry no words. `REQ-ACK-001` requires basic
 * acknowledgement to be **at most two taps**, and the schema has always said
 * the same: `CHECK (type IN ('ACKNOWLEDGE','PRAISE') OR text is non-empty)`.
 * `@NotBlank` here contradicted both, so the two-tap path was impossible —
 * a person could only acknowledge by typing something.
 *
 * The comment it replaces argued that requiring text protects the response
 * invariants. It does not. Text proves only that *something* was in the field,
 * not that a human wrote it or meant to send it. Those invariants are held by
 * different things, and they are all present:
 *
 * - the send is an explicit human action, never background or automatic;
 * - `sender_user_id` is the authenticated caller, so an acknowledgement is
 *   always attributable to a person;
 * - the server stores exactly the type and text it was given and never
 *   invents wording for an empty one.
 *
 * What the UI must not do is pre-fill authored prose and let Send be read as
 * agreement to it. A suggestion has to be adopted deliberately.
 */
data class AcknowledgeRequest(
    val type: AcknowledgementType = AcknowledgementType.ACKNOWLEDGE,
    /** Required for `COMMENT` and `REVIEW`; optional for the other two. */
    val text: String = "",
)

data class AcknowledgeResponse(val acknowledgementId: UUID, val state: String)

/**
 * Ask to discuss, move, or skip.
 *
 * No role can disable these (Notion 04 §4), so the endpoint deliberately does
 * not require a particular role — any active member may ask.
 */
data class AdjustmentRequestBody(
    val type: AdjustmentType,
    val note: String? = null,
    /** Only meaningful for a reschedule. */
    val requestedAt: Instant? = null,
)

data class WithdrawResponse(val state: String)

data class AdjustmentResponse(val adjustmentId: UUID, val state: String)

data class ResolveAdjustmentBody(
    val resolution: AdjustmentResolution,
    val note: String? = null,
    val newTime: Instant? = null,
)

data class ResolveResponse(val state: String, val replacementOccurrenceId: UUID?)

@RestController
@RequestMapping("/v1")
class OccurrenceController(
    private val createExpectation: CreateExpectationService,
    private val complete: CompleteOccurrenceService,
    private val receive: ReceiveOccurrenceService,
    private val acknowledge: SendAcknowledgementService,
    private val adjustments: AdjustmentService,
    private val query: OccurrenceQueryService,
    private val attention: AttentionQueryService,
    private val today: TodayQueryService,
    private val idempotency: IdempotencyService,
    private val mapper: ObjectMapper,
) {

    @PostMapping("/dynamics/{dynamicId}/expectations")
    fun createExpectation(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: CreateExpectationRequest,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "create_expectation",
        "/v1/dynamics/{id}/expectations", listOf(dynamicId.toString()), body,
    ) {
        val c = createExpectation.create(
            actorUserId = jwt.actorId(),
            dynamicId = dynamicId,
            title = body.title,
            purpose = body.purpose,
            assigneeUserId = body.assigneeUserId,
            dueAt = body.dueAt,
        )
        201 to CreateExpectationResponse(c.definitionId, c.occurrenceId)
    }

    /** Authoritative current state — the client never infers it (Notion 03 §8). */
    @GetMapping("/occurrences/{occurrenceId}")
    fun get(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable occurrenceId: UUID,
    ): ResponseEntity<Any> = ResponseEntity.ok()
        .cacheControl(CacheControl.noStore())
        .body(query.get(jwt.actorId(), occurrenceId))

    /** Today — what is expected of this person today (Journey B). */
    @GetMapping("/dynamics/{dynamicId}/today")
    fun todayFor(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
    ): ResponseEntity<Any> = ResponseEntity.ok()
        .cacheControl(CacheControl.noStore())
        .body(today.forDynamic(jwt.actorId(), dynamicId))

    /** Attention — what needs this person's human response (Journey C). */
    @GetMapping("/dynamics/{dynamicId}/attention")
    fun attentionFor(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
    ): ResponseEntity<Any> = ResponseEntity.ok()
        .cacheControl(CacheControl.noStore())
        .body(attention.forDynamic(jwt.actorId(), dynamicId))

    /** "Received." The first bilateral event: they have seen what was given. */
    @PostMapping("/occurrences/{occurrenceId}/receive")
    fun receiveOccurrence(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable occurrenceId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "receive_occurrence",
        "/v1/occurrences/{id}/receive", listOf(occurrenceId.toString()), null,
    ) {
        val at = receive.receive(jwt.actorId(), occurrenceId)
        200 to ReceiveResponse(occurrenceId, at)
    }

    @PostMapping("/occurrences/{occurrenceId}/complete")
    fun completeOccurrence(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable occurrenceId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @RequestBody(required = false) body: CompleteRequest?,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "complete_occurrence",
        "/v1/occurrences/{id}/complete", listOf(occurrenceId.toString()), body,
    ) { idem ->
        val id = complete.complete(
            jwt.actorId(), occurrenceId, body?.note, idem,
            proofMediaId = body?.proofMediaId,
        )
        // WAITING_ACK, never ACKNOWLEDGED: completing is not being seen.
        201 to CompleteResponse(id, "WAITING_ACK")
    }

    @PostMapping("/occurrences/{occurrenceId}/acknowledgements")
    fun sendAcknowledgement(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable occurrenceId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: AcknowledgeRequest,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "send_acknowledgement",
        "/v1/occurrences/{id}/acknowledgements", listOf(occurrenceId.toString()), body,
    ) { idem ->
        val id = acknowledge.send(jwt.actorId(), occurrenceId, body.type, body.text, idem)
        201 to AcknowledgeResponse(id, "ACKNOWLEDGED")
    }

    /** Journey D: adjustment is the normal path, not a confession. */
    @PostMapping("/occurrences/{occurrenceId}/adjustments")
    fun requestAdjustment(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable occurrenceId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: AdjustmentRequestBody,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "request_adjustment",
        "/v1/occurrences/{id}/adjustments", listOf(occurrenceId.toString()), body,
    ) { idem ->
        val r = adjustments.request(
            jwt.actorId(), occurrenceId, body.type, body.note, body.requestedAt, idem,
        )
        201 to AdjustmentResponse(r.adjustmentId, r.occurrenceState)
    }

    /** The partner answers: Continue / Adjust / Reschedule / Excuse / Cancel. */
    @PostMapping("/occurrences/{occurrenceId}/adjustments/resolve")
    fun resolveAdjustment(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable occurrenceId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: ResolveAdjustmentBody,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "resolve_adjustment",
        "/v1/occurrences/{id}/adjustments/resolve", listOf(occurrenceId.toString()), body,
    ) { idem ->
        val r = adjustments.resolve(
            jwt.actorId(), occurrenceId, body.resolution, body.note, body.newTime, idem,
        )
        200 to ResolveResponse(r.occurrenceState, r.replacementOccurrenceId)
    }

    /**
     * Take your own request back.
     *
     * Separate from `/resolve` because it is a different act by a different
     * person: resolve is how the other person answers, withdraw is the asker
     * deciding they no longer need to ask. Folding it into the resolution
     * vocabulary would make taking back your own request look like one of the
     * answers available to someone else.
     */
    @PostMapping("/occurrences/{occurrenceId}/adjustments/withdraw")
    fun withdrawAdjustment(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable occurrenceId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "withdraw_adjustment",
        "/v1/occurrences/{id}/adjustments/withdraw", listOf(occurrenceId.toString()), null,
    ) {
        val r = adjustments.withdraw(jwt.actorId(), occurrenceId)
        200 to WithdrawResponse(r.occurrenceState)
    }

    private fun runOnce(
        jwt: Jwt,
        key: String?,
        command: String,
        route: String,
        pathIds: List<String>,
        payload: Any?,
        block: (UUID) -> Pair<Int, Any>,
    ): ResponseEntity<Any> {
        val raw = payload?.let { mapper.writeValueAsBytes(it) } ?: ByteArray(0)
        val hash = RequestHasher.sha256("POST", route, pathIds, "application/json", raw)
        val outcome = idempotency.executeOnce(jwt.actorId(), key, command, hash) { idemKey ->
            val (status, respBody) = block(idemKey.id)
            IdempotencyResponse(status, mapper.writeValueAsBytes(respBody))
        }
        val b = ResponseEntity.status(outcome.status).cacheControl(CacheControl.noStore())
        outcome.headers.forEach { (k, v) -> b.header(k, v) }
        return b.body(mapper.readValue(outcome.body, Any::class.java))
    }
}
