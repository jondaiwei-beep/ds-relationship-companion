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
/** cost = null means "D 决定": no fixed price, set at approval. */
data class RewardBody(@field:NotBlank val title: String, val detail: String? = null, val cost: Int? = null)
data class RequestRedemptionBody(val note: String? = null)
data class DecideRedemptionBody(val approve: Boolean, val note: String? = null, val costOverride: Int? = null)
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
    /** Let chance pick WHICH agreed consequence. Never whether. */
    val byChance: Boolean = false,
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
                // Days that happened. Never resets, so there is no cliff.
                "daysTogether" to points.daysTogether(me, dynamicId),
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

    /** s asks for a reward. No ledger movement — only checked, not spent. */
    @PostMapping("/rewards/{rewardId}/request")
    fun requestRedemption(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable rewardId: UUID,
        @Valid @RequestBody(required = false) body: RequestRedemptionBody?,
    ): ResponseEntity<Map<String, Any>> {
        val id = points.request(jwt.actorId(), dynamicId, rewardId, body?.note)
        return ResponseEntity.status(201).body(mapOf("id" to id))
    }

    @GetMapping("/redemptions")
    fun redemptions(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam(required = false) status: String?,
    ): ResponseEntity<Map<String, Any>> = ResponseEntity.ok(
        mapOf(
            "redemptions" to points.redemptions(jwt.actorId(), dynamicId, status).map {
                mapOf(
                    "id" to it.id,
                    "rewardId" to it.rewardId,
                    "rewardTitle" to it.rewardTitle,
                    "subjectUserId" to it.subjectUserId,
                    "status" to it.status,
                    "note" to it.note,
                    "decidedBy" to it.decidedBy,
                    "decidedAt" to it.decidedAt,
                    "createdAt" to it.createdAt,
                )
            },
        ),
    )

    /** D decides: approve (writes one ledger row) or deny (writes nothing). */
    @PostMapping("/redemptions/{redemptionId}/decide")
    fun decideRedemption(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable redemptionId: UUID,
        @Valid @RequestBody body: DecideRedemptionBody,
    ): ResponseEntity<Map<String, Any>> {
        val id = points.decide(
            jwt.actorId(), dynamicId, redemptionId, body.approve, body.note, body.costOverride,
        )
        return ResponseEntity.ok(mapOf("id" to id))
    }

    @PostMapping("/redemptions/{redemptionId}/fulfill")
    fun fulfillRedemption(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable redemptionId: UUID,
    ): ResponseEntity<Void> {
        points.fulfill(jwt.actorId(), dynamicId, redemptionId)
        return ResponseEntity.noContent().build()
    }

    /** 分 tab "规则可见": which active tasks pay, and how much. */
    @GetMapping("/points/rules")
    fun pointsRules(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
    ): ResponseEntity<Map<String, Any>> = ResponseEntity.ok(
        mapOf(
            "rules" to points.pointsRules(jwt.actorId(), dynamicId).map {
                mapOf("taskId" to it.taskId, "title" to it.title, "pointsEarn" to it.pointsEarn)
            },
        ),
    )

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

    /**
     * History for the older agreed-consequence path (`consequence_agreements`
     * / `consequence_events` — invoked directly, not disposition-driven).
     *
     * Renamed off `/consequences` in Phase 3: that path now belongs to the
     * domain-doc Consequence lifecycle (today/api/ConsequenceController —
     * issued/done_by_s/confirmed/waived, created only via a D's `punished`
     * disposition). This older feature is unrelated and still functions
     * through the service layer; only its HTTP route moved.
     */
    @GetMapping("/agreement-consequences")
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

    @PostMapping("/agreement-consequences")
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
            byChance = body.byChance,
        )
        return ResponseEntity.status(201).body(mapOf("id" to id))
    }
}
