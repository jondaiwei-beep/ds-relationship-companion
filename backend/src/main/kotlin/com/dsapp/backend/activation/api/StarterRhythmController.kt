package com.dsapp.backend.activation.api

import com.dsapp.backend.activation.application.StarterRhythmService
import com.dsapp.backend.shared.api.actorId
import com.dsapp.backend.shared.idempotency.IdempotencyResponse
import com.dsapp.backend.shared.idempotency.IdempotencyService
import com.dsapp.backend.shared.idempotency.RequestHasher
import com.fasterxml.jackson.databind.ObjectMapper
import jakarta.validation.Valid
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
import java.util.UUID

data class StartRhythmBody(
    val assigneeUserId: UUID,
    val ritualTitle: String? = null,
    val expectationTitle: String? = null,
    /** Opt-in only — the first day must not arrive already full (Notion 05 §4). */
    val includeSecondExpectation: Boolean = false,
)

/** Starter Rhythm — Journey A3. */
@RestController
@RequestMapping("/v1")
class StarterRhythmController(
    private val starter: StarterRhythmService,
    private val idempotency: IdempotencyService,
    private val mapper: ObjectMapper,
) {

    /** What we would suggest. Writes nothing. */
    @GetMapping("/dynamics/{dynamicId}/starter-rhythm")
    fun propose(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
    ): ResponseEntity<Any> = ResponseEntity.ok()
        .cacheControl(CacheControl.noStore())
        .body(starter.propose(jwt.actorId(), dynamicId))

    /** "Start this rhythm." */
    @PostMapping("/dynamics/{dynamicId}/starter-rhythm")
    fun start(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: StartRhythmBody,
    ): ResponseEntity<Any> {
        val raw = mapper.writeValueAsBytes(body)
        val hash = RequestHasher.sha256(
            "POST", "/v1/dynamics/{id}/starter-rhythm",
            listOf(dynamicId.toString()), "application/json", raw,
        )
        val outcome = idempotency.executeOnce(jwt.actorId(), key, "start_rhythm", hash) {
            val started = starter.start(
                actorUserId = jwt.actorId(),
                dynamicId = dynamicId,
                assigneeUserId = body.assigneeUserId,
                ritualTitle = body.ritualTitle,
                expectationTitle = body.expectationTitle,
                includeSecondExpectation = body.includeSecondExpectation,
            )
            IdempotencyResponse(201, mapper.writeValueAsBytes(started))
        }
        val b = ResponseEntity.status(outcome.status).cacheControl(CacheControl.noStore())
        outcome.headers.forEach { (k, v) -> b.header(k, v) }
        return b.body(mapper.readValue(outcome.body, Any::class.java))
    }
}
