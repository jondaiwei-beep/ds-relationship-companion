package com.dsapp.backend.today.api

import com.dsapp.backend.shared.api.IdempotentPost
import com.dsapp.backend.shared.api.actorId
import com.dsapp.backend.today.application.OutcomeService
import com.dsapp.backend.today.application.TaskService
import com.dsapp.backend.today.domain.Proof
import com.dsapp.backend.today.domain.TaskKind
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.time.Instant
import java.time.LocalTime
import java.util.UUID

data class CreateTaskBody(
    @field:NotBlank @field:Size(max = 120) val title: String,
    @field:Size(max = 1000) val detail: String? = null,
    val kind: TaskKind = TaskKind.recurring,
    val schedule: Map<String, Any?>? = null,
    val timesPerDay: Int = 1,
    val dueTime: LocalTime? = null,
    val dueAt: Instant? = null,
    val proof: Proof = Proof.check,
    val pointsEarn: Int = 0,
    val requiresDPresent: Boolean = false,
    val unit: String? = null,
)

data class PauseBody(val until: Instant? = null)

data class DeliverOpenBody(val note: String? = null, val proofKind: String? = null, val proofRef: String? = null)

@RestController
@RequestMapping("/v1/dynamics/{dynamicId}/tasks")
class TaskController(
    private val tasks: TaskService,
    private val outcomes: OutcomeService,
    private val post: IdempotentPost,
) {
    @GetMapping
    fun list(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam(defaultValue = "false") includeArchived: Boolean,
    ): ResponseEntity<Any> = ResponseEntity.ok(tasks.list(jwt.actorId(), dynamicId, includeArchived))

    @PostMapping
    fun create(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: CreateTaskBody,
    ): ResponseEntity<Any> = post.run(jwt, key, "create_task", "/v1/dynamics/{id}/tasks", listOf("$dynamicId"), body) {
        201 to tasks.create(
            jwt.actorId(), dynamicId,
            TaskService.NewTask(
                title = body.title, detail = body.detail, kind = body.kind,
                schedule = body.schedule ?: if (body.kind == TaskKind.recurring) mapOf("type" to "daily") else null,
                timesPerDay = body.timesPerDay, dueTime = body.dueTime, dueAt = body.dueAt,
                proof = body.proof, pointsEarn = body.pointsEarn, requiresDPresent = body.requiresDPresent, unit = body.unit,
            ),
        )
    }

    @PostMapping("/{taskId}/accept")
    fun accept(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable taskId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = post.run(jwt, key, "accept_task", "/v1/dynamics/{id}/tasks/{t}/accept", listOf("$dynamicId", "$taskId"), null) {
        200 to tasks.accept(jwt.actorId(), dynamicId, taskId)
    }

    @PostMapping("/{taskId}/archive")
    fun archive(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable taskId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = post.run(jwt, key, "archive_task", "/v1/dynamics/{id}/tasks/{t}/archive", listOf("$dynamicId", "$taskId"), null) {
        tasks.archive(jwt.actorId(), dynamicId, taskId)
        200 to mapOf("status" to "archived")
    }

    @PostMapping("/{taskId}/pause")
    fun pause(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable taskId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @RequestBody(required = false) body: PauseBody?,
    ): ResponseEntity<Any> = post.run(jwt, key, "pause_task", "/v1/dynamics/{id}/tasks/{t}/pause", listOf("$dynamicId", "$taskId"), body) {
        tasks.pause(jwt.actorId(), dynamicId, taskId, body?.until)
        200 to tasks.get(dynamicId, taskId)
    }

    @PostMapping("/{taskId}/unpause")
    fun unpause(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable taskId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = post.run(jwt, key, "unpause_task", "/v1/dynamics/{id}/tasks/{t}/unpause", listOf("$dynamicId", "$taskId"), null) {
        tasks.unpause(jwt.actorId(), dynamicId, taskId)
        200 to tasks.get(dynamicId, taskId)
    }

    /** An open task is delivered straight from the task; the occurrence is born delivered. */
    @PostMapping("/{taskId}/deliver")
    fun deliverOpen(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable taskId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @RequestBody(required = false) body: DeliverOpenBody?,
    ): ResponseEntity<Any> = post.run(jwt, key, "deliver_open", "/v1/dynamics/{id}/tasks/{t}/deliver", listOf("$dynamicId", "$taskId"), body) {
        201 to outcomes.deliverOpen(jwt.actorId(), dynamicId, taskId, body?.note, body?.proofKind, body?.proofRef)
    }
}
