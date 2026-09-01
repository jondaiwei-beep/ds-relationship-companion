package com.dsapp.backend.boundary.api

import com.dsapp.backend.boundary.application.BoundaryService
import com.dsapp.backend.shared.api.actorId
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Pattern
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Instant
import java.util.UUID

data class BoundaryBody(
    @field:NotBlank val label: String,
    @field:Pattern(regexp = "OFF|ASK|CURIOUS", message = "stance")
    val stance: String,
    val note: String? = null,
)

/**
 * `mine` is computed by the server rather than left to the client to work out
 * from `userId`. Deciding "is this row editable" client-side from a members
 * list is exactly the comparison that previously showed a person their own
 * name as their partner's, and here the same mistake would offer someone an
 * edit control over a limit that is not theirs.
 */
data class BoundaryView(
    val id: UUID,
    val label: String,
    val stance: String,
    val note: String?,
    val mine: Boolean,
    val updatedAt: Instant,
)

@RestController
@RequestMapping("/v1/dynamics/{dynamicId}/boundaries")
class BoundaryController(private val boundaries: BoundaryService) {

    /** Both lists. Each member sees what the other has said is off the table. */
    @GetMapping
    fun list(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
    ): ResponseEntity<Map<String, Any>> {
        val rows = boundaries.list(jwt.actorId(), dynamicId).map {
            BoundaryView(it.id, it.label, it.stance.name, it.note, it.mine, it.updatedAt)
        }
        return ResponseEntity.ok(mapOf("boundaries" to rows))
    }

    /** Writes only to the caller's own list; the actor is never taken from the body. */
    @PostMapping
    fun add(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @Valid @RequestBody body: BoundaryBody,
    ): ResponseEntity<Map<String, Any>> {
        val id = boundaries.add(
            actorUserId = jwt.actorId(),
            dynamicId = dynamicId,
            label = body.label,
            stance = BoundaryService.Stance.valueOf(body.stance),
            note = body.note,
        )
        return ResponseEntity.status(201).body(mapOf("id" to id))
    }

    @DeleteMapping("/{boundaryId}")
    fun remove(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable boundaryId: UUID,
    ): ResponseEntity<Void> {
        boundaries.remove(jwt.actorId(), dynamicId, boundaryId)
        return ResponseEntity.noContent().build()
    }
}
