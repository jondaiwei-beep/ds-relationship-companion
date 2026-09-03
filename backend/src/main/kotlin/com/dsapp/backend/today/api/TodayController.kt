package com.dsapp.backend.today.api

import com.dsapp.backend.shared.api.IdempotentPost
import com.dsapp.backend.shared.api.actorId
import com.dsapp.backend.today.application.DNoteService
import com.dsapp.backend.today.application.DispositionService
import com.dsapp.backend.today.application.OutcomeService
import com.dsapp.backend.today.application.TodayQueryService
import com.dsapp.backend.today.domain.Disposition
import com.dsapp.backend.today.domain.Outcome
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import org.springframework.http.CacheControl
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.math.BigDecimal
import java.time.Instant
import java.time.LocalDate
import java.util.UUID

data class OutcomeBody(
    val outcome: Outcome,
    @field:Size(max = 1000) val note: String? = null,
    val proofKind: String? = null,
    val proofRef: String? = null,
    val proposedTime: Instant? = null,
    val value: BigDecimal? = null,
)

data class ConsequenceBody(val templateId: UUID? = null, val title: String? = null, val detail: String? = null)

data class DispositionBody(
    val disposition: Disposition,
    @field:Size(max = 1000) val note: String? = null,
    val makeUpDay: LocalDate? = null,
    val consequence: ConsequenceBody? = null,
)

data class DNoteBody(@field:NotBlank @field:Size(max = 1000) val body: String, val remindAt: Instant? = null)

@RestController
class TodayController(
    private val today: TodayQueryService,
    private val outcomes: OutcomeService,
    private val dispositions: DispositionService,
    private val dNotes: DNoteService,
    private val post: IdempotentPost,
) {
    @GetMapping("/v1/dynamics/{dynamicId}/today")
    fun today(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam(required = false) day: LocalDate?,
    ): ResponseEntity<Any> = ResponseEntity.ok().cacheControl(CacheControl.noStore())
        .body(today.today(jwt.actorId(), dynamicId, day))

    @GetMapping("/v1/dynamics/{dynamicId}/needs-me")
    fun needsMe(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam(defaultValue = "50") limit: Int,
    ): ResponseEntity<Any> = ResponseEntity.ok().cacheControl(CacheControl.noStore())
        .body(today.needsMe(jwt.actorId(), dynamicId, limit.coerceIn(1, 200)))

    @GetMapping("/v1/occurrences/{occurrenceId}")
    fun occurrence(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable occurrenceId: UUID,
    ): ResponseEntity<Any> = ResponseEntity.ok().cacheControl(CacheControl.noStore())
        .body(today.occurrence(jwt.actorId(), occurrenceId))

    /** s axis: 送到 / 做不到 / 换个时间 / 想聊聊, or `open` to take it back. */
    @PostMapping("/v1/occurrences/{occurrenceId}/outcome")
    fun outcome(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable occurrenceId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: OutcomeBody,
    ): ResponseEntity<Any> = post.run(jwt, key, "set_outcome", "/v1/occurrences/{id}/outcome", listOf("$occurrenceId"), body) {
        200 to outcomes.set(
            jwt.actorId(), occurrenceId,
            OutcomeService.Change(body.outcome, body.note, body.proofKind, body.proofRef, body.proposedTime, body.value),
        )
    }

    /** D axis: 看到了 / 很好 / 算了 / 补上 / 罚. */
    @PostMapping("/v1/occurrences/{occurrenceId}/disposition")
    fun disposition(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable occurrenceId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: DispositionBody,
    ): ResponseEntity<Any> = post.run(jwt, key, "set_disposition", "/v1/occurrences/{id}/disposition", listOf("$occurrenceId"), body) {
        200 to dispositions.set(
            jwt.actorId(), occurrenceId,
            DispositionService.Change(
                body.disposition, body.note, body.makeUpDay,
                body.consequence?.let { DispositionService.NewConsequence(it.templateId, it.title, it.detail) },
            ),
        )
    }

    /** Receipt: the D opened it. Not idempotency-keyed; the first look sticks. */
    @PostMapping("/v1/occurrences/{occurrenceId}/seen")
    fun seen(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable occurrenceId: UUID,
    ): ResponseEntity<Any> = ResponseEntity.ok().cacheControl(CacheControl.noStore())
        .body(mapOf("seenAt" to dispositions.markSeen(jwt.actorId(), occurrenceId)))

    // ---- D notes -----------------------------------------------------------

    @GetMapping("/v1/dynamics/{dynamicId}/d-notes")
    fun dNotes(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam(defaultValue = "false") includeDone: Boolean,
    ): ResponseEntity<Any> = ResponseEntity.ok().cacheControl(CacheControl.noStore())
        .body(dNotes.list(jwt.actorId(), dynamicId, includeDone))

    @PostMapping("/v1/dynamics/{dynamicId}/d-notes")
    fun createDNote(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: DNoteBody,
    ): ResponseEntity<Any> = post.run(jwt, key, "create_d_note", "/v1/dynamics/{id}/d-notes", listOf("$dynamicId"), body) {
        201 to dNotes.create(jwt.actorId(), dynamicId, body.body, body.remindAt)
    }

    @PostMapping("/v1/d-notes/{noteId}/done")
    fun doneDNote(@AuthenticationPrincipal jwt: Jwt, @PathVariable noteId: UUID): ResponseEntity<Any> =
        ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(dNotes.done(jwt.actorId(), noteId))

    @DeleteMapping("/v1/d-notes/{noteId}")
    fun deleteDNote(@AuthenticationPrincipal jwt: Jwt, @PathVariable noteId: UUID): ResponseEntity<Void> {
        dNotes.delete(jwt.actorId(), noteId)
        return ResponseEntity.noContent().build()
    }
}
