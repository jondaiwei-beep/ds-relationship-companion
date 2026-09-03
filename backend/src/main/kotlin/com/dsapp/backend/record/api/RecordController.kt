package com.dsapp.backend.record.api

import com.dsapp.backend.record.application.DayCommentService
import com.dsapp.backend.record.application.PrivateNoteService
import com.dsapp.backend.record.application.RecordQueryService
import com.dsapp.backend.shared.api.IdempotentPost
import com.dsapp.backend.shared.api.actorId
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import org.springframework.http.CacheControl
import org.springframework.http.ContentDisposition
import org.springframework.http.HttpHeaders
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.time.LocalDate
import java.time.YearMonth
import java.util.UUID

data class DayCommentBody(val day: LocalDate, @field:NotBlank @field:Size(max = 2000) val body: String)

data class PrivateNoteBody(val day: LocalDate, @field:Size(max = 5000) val body: String)

/** 记录 (product/02-surfaces.md Tab 3): calendar, day timeline, comments, private notes, facts. */
@RestController
class RecordController(
    private val query: RecordQueryService,
    private val comments: DayCommentService,
    private val privateNotes: PrivateNoteService,
    private val post: IdempotentPost,
) {
    @GetMapping("/v1/dynamics/{dynamicId}/record/month")
    fun month(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam month: String,
    ): ResponseEntity<Any> = ResponseEntity.ok().cacheControl(CacheControl.noStore())
        .body(query.month(jwt.actorId(), dynamicId, YearMonth.parse(month)))

    @GetMapping("/v1/dynamics/{dynamicId}/record/day")
    fun day(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam day: LocalDate,
    ): ResponseEntity<Any> = ResponseEntity.ok().cacheControl(CacheControl.noStore())
        .body(query.day(jwt.actorId(), dynamicId, day))

    @GetMapping("/v1/dynamics/{dynamicId}/record/facts")
    fun facts(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam from: LocalDate,
        @RequestParam to: LocalDate,
    ): ResponseEntity<Any> = ResponseEntity.ok().cacheControl(CacheControl.noStore())
        .body(query.facts(jwt.actorId(), dynamicId, from, to))

    @GetMapping("/v1/dynamics/{dynamicId}/record/summary")
    fun summary(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
    ): ResponseEntity<Any> = ResponseEntity.ok().cacheControl(CacheControl.noStore())
        .body(query.summary(jwt.actorId(), dynamicId))

    @PostMapping("/v1/dynamics/{dynamicId}/record/comments")
    fun addComment(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: DayCommentBody,
    ): ResponseEntity<Any> = post.run(jwt, key, "add_day_comment", "/v1/dynamics/{id}/record/comments", listOf("$dynamicId"), body) {
        201 to comments.add(jwt.actorId(), dynamicId, body.day, body.body)
    }

    @DeleteMapping("/v1/day-comments/{commentId}")
    fun deleteComment(@AuthenticationPrincipal jwt: Jwt, @PathVariable commentId: UUID): ResponseEntity<Void> {
        comments.delete(jwt.actorId(), commentId)
        return ResponseEntity.noContent().build()
    }

    @PutMapping("/v1/dynamics/{dynamicId}/record/private-note")
    fun putPrivateNote(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @Valid @RequestBody body: PrivateNoteBody,
    ): ResponseEntity<Any> = ResponseEntity.ok().cacheControl(CacheControl.noStore())
        .body(mapOf("body" to privateNotes.upsert(jwt.actorId(), dynamicId, body.day, body.body)))

    /** kind=measure curve for one task (product/06-build-order.md Phase 5). */
    @GetMapping("/v1/dynamics/{dynamicId}/record/series")
    fun series(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam taskId: UUID,
        @RequestParam from: LocalDate,
        @RequestParam to: LocalDate,
    ): ResponseEntity<Any> = ResponseEntity.ok().cacheControl(CacheControl.noStore())
        .body(query.series(jwt.actorId(), dynamicId, taskId, from, to))

    /** The record, packaged for taking elsewhere. Either side may export. */
    @GetMapping("/v1/dynamics/{dynamicId}/record/export")
    fun export(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam from: LocalDate,
        @RequestParam to: LocalDate,
        @RequestParam(defaultValue = "json") format: String,
    ): ResponseEntity<Any> {
        val view = query.export(jwt.actorId(), dynamicId, from, to)
        return if (format == "csv") {
            val csv = toCsv(view)
            ResponseEntity.ok()
                .cacheControl(CacheControl.noStore())
                .header(HttpHeaders.CONTENT_TYPE, "text/csv;charset=UTF-8")
                .header(
                    HttpHeaders.CONTENT_DISPOSITION,
                    ContentDisposition.attachment().filename("record-$from-$to.csv").build().toString(),
                )
                .body(csv)
        } else {
            ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(view)
        }
    }

    private fun toCsv(view: RecordQueryService.ExportView): String {
        val sb = StringBuilder("day,task_title,kind,outcome,outcome_at,disposition,value,unit,note\n")
        for (d in view.days) {
            for (o in d.occurrences) {
                sb.append(csvCell(d.day.toString())).append(',')
                    .append(csvCell(o.taskTitle)).append(',')
                    .append(csvCell(o.kind)).append(',')
                    .append(csvCell(o.outcome)).append(',')
                    .append(csvCell(o.outcomeAt?.toString() ?: "")).append(',')
                    .append(csvCell(o.disposition)).append(',')
                    .append(csvCell(o.value?.toPlainString() ?: "")).append(',')
                    .append(csvCell(o.unit ?: "")).append(',')
                    .append(csvCell(o.note ?: "")).append('\n')
            }
        }
        return sb.toString()
    }

    private fun csvCell(raw: String): String =
        if (raw.any { it == ',' || it == '"' || it == '\n' || it == '\r' }) "\"${raw.replace("\"", "\"\"")}\"" else raw
}
