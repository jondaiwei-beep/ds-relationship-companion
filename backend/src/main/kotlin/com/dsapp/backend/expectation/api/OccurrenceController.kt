package com.dsapp.backend.expectation.api

import com.dsapp.backend.expectation.application.CompleteOccurrenceService
import com.dsapp.backend.expectation.application.CheckInService
import com.dsapp.backend.expectation.application.CheckInVisibility
import com.dsapp.backend.expectation.application.CreateExpectationService
import com.dsapp.backend.expectation.application.OccurrenceQueryService
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

data class CompleteRequest(val note: String? = null)

data class CompleteResponse(val completionId: UUID, val state: String)

/**
 * An acknowledgement REQUIRES text written by the human sender.
 *
 * Red line #1/#2: the system may suggest wording in the UI, but the API will
 * not accept an empty body — nothing may be auto-generated on the user's behalf.
 */
data class AcknowledgeRequest(
    val type: AcknowledgementType = AcknowledgementType.ACKNOWLEDGE,
    @field:NotBlank val text: String,
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

data class AdjustmentResponse(val adjustmentId: UUID, val state: String)

data class ResolveAdjustmentBody(
    val resolution: AdjustmentResolution,
    val note: String? = null,
    val newTime: Instant? = null,
)

data class ResolveResponse(val state: String, val replacementOccurrenceId: UUID?)

/** Visibility is explicit — there is no shared-by-default (Notion 04 §3). */
data class CreateCheckInBody(
    val mood: String? = null,
    val energy: String? = null,
    val need: String? = null,
    val note: String? = null,
    val visibility: CheckInVisibility = CheckInVisibility.PRIVATE,
)

@RestController
@RequestMapping("/v1")
class OccurrenceController(
    private val createExpectation: CreateExpectationService,
    private val complete: CompleteOccurrenceService,
    private val acknowledge: SendAcknowledgementService,
    private val adjustments: AdjustmentService,
    private val query: OccurrenceQueryService,
    private val attention: AttentionQueryService,
    private val today: TodayQueryService,
    private val checkIns: CheckInService,
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

    /** Recent check-ins the viewer may see. Private ones are filtered in SQL. */
    @GetMapping("/dynamics/{dynamicId}/check-ins")
    fun checkInsFor(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
    ): ResponseEntity<Any> = ResponseEntity.ok()
        .cacheControl(CacheControl.noStore())
        .body(mapOf("items" to checkIns.recentFor(jwt.actorId(), dynamicId)))

    /** Share context: "I can continue, but gently." */
    @PostMapping("/dynamics/{dynamicId}/check-ins")
    fun createCheckIn(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: CreateCheckInBody,
    ): ResponseEntity<Any> = runOnce(
        jwt, key, "create_check_in", "/v1/dynamics/{id}/check-ins",
        listOf(dynamicId.toString()), body,
    ) {
        val id = checkIns.create(
            jwt.actorId(), dynamicId, body.mood, body.energy, body.need, body.note, body.visibility,
        )
        201 to mapOf("checkInId" to id)
    }

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
        val id = complete.complete(jwt.actorId(), occurrenceId, body?.note, idem)
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
