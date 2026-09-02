package com.dsapp.backend.points.api

import com.dsapp.backend.points.application.PointsService
import com.dsapp.backend.shared.api.actorId
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

data class AdjustPointsBody(val subjectUserId: UUID, val amount: Int, val note: String? = null)
data class GiftBody(val subjectUserId: UUID)
data class RewardBody(@field:NotBlank val title: String, val detail: String? = null, val cost: Int)
data class AgreementBody(
    @field:NotBlank val label: String,
    @field:NotBlank val consequence: String,
    val pointCost: Int = 0,
)

/**
 * Issuing or waiving an agreed consequence.
 *
 * There is no `issuedBy` field, deliberately. The issuer is always the
 * authenticated caller, so a client cannot claim a consequence came from
 * someone else — and no request shape exists that would let a background job
 * post one.
 */
data class ConsequenceBody(
    val subjectUserId: UUID,
    val agreementId: UUID? = null,
    val occurrenceId: UUID? = null,
    val waived: Boolean = false,
    val note: String? = null,
)

@RestController
@RequestMapping("/v1/dynamics/{dynamicId}")
class PointsController(private val points: PointsService) {

    @GetMapping("/points")
    fun summary(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam(required = false) subjectUserId: UUID?,
    ): ResponseEntity<Map<String, Any?>> {
        val me = jwt.actorId()
        val subject = subjectUserId ?: me
        val entries = points.recent(me, dynamicId)
        return ResponseEntity.ok(
            mapOf(
                "balance" to points.balanceOf(dynamicId, subject),
                "entries" to entries.map {
                    mapOf(
                        "id" to it.id,
                        "amount" to it.amount,
                        "reason" to it.reason,
                        "note" to it.note,
                        "createdAt" to it.createdAt,
                    )
                },
            ),
        )
    }

    @PostMapping("/points")
    fun adjust(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @Valid @RequestBody body: AdjustPointsBody,
    ): ResponseEntity<Map<String, Any>> {
        // Null when a deduction had nothing to take: not an error, just a
        // balance that was already at zero and stays there.
        val id = points.adjust(
            jwt.actorId(), dynamicId, body.subjectUserId, body.amount, body.note,
        )
        return ResponseEntity.status(201).body(mapOf("id" to (id ?: "")))
    }

    @GetMapping("/rewards")
    fun rewards(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam(required = false) subjectUserId: UUID?,
    ): ResponseEntity<Map<String, Any>> {
        val me = jwt.actorId()
        val rows = points.rewards(me, dynamicId, subjectUserId ?: me)
        return ResponseEntity.ok(
            mapOf(
                "rewards" to rows.map {
                    mapOf(
                        "id" to it.id,
                        "title" to it.title,
                        "detail" to it.detail,
                        "cost" to it.cost,
                        "affordable" to it.affordable,
                    )
                },
            ),
        )
    }

    @PostMapping("/rewards")
    fun addReward(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @Valid @RequestBody body: RewardBody,
    ): ResponseEntity<Map<String, Any>> {
        val id = points.addReward(jwt.actorId(), dynamicId, body.title, body.detail, body.cost)
        return ResponseEntity.status(201).body(mapOf("id" to id))
    }

    @DeleteMapping("/rewards/{rewardId}")
    fun retireReward(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable rewardId: UUID,
    ): ResponseEntity<Void> {
        points.retireReward(jwt.actorId(), dynamicId, rewardId)
        return ResponseEntity.noContent().build()
    }

    /** Given outright by the other member. No cost, no balance check. */
    @PostMapping("/rewards/{rewardId}/gift")
    fun gift(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable rewardId: UUID,
        @Valid @RequestBody body: GiftBody,
    ): ResponseEntity<Map<String, Any>> {
        val id = points.gift(jwt.actorId(), dynamicId, rewardId, body.subjectUserId)
        return ResponseEntity.status(201).body(mapOf("id" to id))
    }

    @PostMapping("/rewards/{rewardId}/redeem")
    fun redeem(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable rewardId: UUID,
    ): ResponseEntity<Map<String, Any>> {
        val id = points.redeem(jwt.actorId(), dynamicId, rewardId)
        return ResponseEntity.status(201).body(mapOf("id" to id))
    }

    @GetMapping("/agreements")
    fun agreements(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
    ): ResponseEntity<Map<String, Any>> = ResponseEntity.ok(
        mapOf(
            "agreements" to points.agreements(jwt.actorId(), dynamicId).map {
                mapOf(
                    "id" to it.id,
                    "label" to it.label,
                    "consequence" to it.consequence,
                    "pointCost" to it.pointCost,
                )
            },
        ),
    )

    @PostMapping("/agreements")
    fun addAgreement(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @Valid @RequestBody body: AgreementBody,
    ): ResponseEntity<Map<String, Any>> {
        val id = points.addAgreement(
            jwt.actorId(), dynamicId, body.label, body.consequence, body.pointCost,
        )
        return ResponseEntity.status(201).body(mapOf("id" to id))
    }

    @DeleteMapping("/agreements/{agreementId}")
    fun endAgreement(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable agreementId: UUID,
    ): ResponseEntity<Void> {
        points.endAgreement(jwt.actorId(), dynamicId, agreementId)
        return ResponseEntity.noContent().build()
    }

    @GetMapping("/consequences")
    fun history(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
    ): ResponseEntity<Map<String, Any>> = ResponseEntity.ok(
        mapOf(
            "events" to points.consequenceHistory(jwt.actorId(), dynamicId).map {
                mapOf(
                    "id" to it.id,
                    "outcome" to it.outcome,
                    "consequence" to it.consequence,
                    "issuedByUserId" to it.issuedByUserId,
                    "note" to it.note,
                    "createdAt" to it.createdAt,
                )
            },
        ),
    )

    @PostMapping("/consequences")
    fun issue(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @Valid @RequestBody body: ConsequenceBody,
    ): ResponseEntity<Map<String, Any>> {
        val id = points.issueConsequence(
            actorUserId = jwt.actorId(),
            dynamicId = dynamicId,
            subjectUserId = body.subjectUserId,
            agreementId = body.agreementId,
            occurrenceId = body.occurrenceId,
            waived = body.waived,
            note = body.note,
        )
        return ResponseEntity.status(201).body(mapOf("id" to id))
    }
}
