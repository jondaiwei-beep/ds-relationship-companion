package com.dsapp.backend.explore.api

import com.dsapp.backend.explore.application.IdeaCardService
import com.dsapp.backend.explore.application.PreferenceService
import com.dsapp.backend.explore.application.StarterPackService
import com.dsapp.backend.explore.domain.ExploreCatalog
import com.dsapp.backend.shared.api.IdempotentPost
import com.dsapp.backend.shared.api.actorId
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

data class AnswerItemBody(@field:NotBlank val answer: String)

data class AddCustomItemBody(
    @field:NotBlank @field:Size(max = 60) val group: String,
    @field:NotBlank @field:Size(max = 120) val title: String,
    @field:Size(max = 2000) val detail: String? = null,
)

data class ActCardBody(@field:NotBlank val action: String)

data class ApplyPackBody(
    val tasks: List<StarterPackService.DraftTask> = emptyList(),
    val rules: List<StarterPackService.DraftRule> = emptyList(),
    val rewards: List<StarterPackService.DraftReward> = emptyList(),
)

private fun PreferenceService.ItemView.toMap() = mapOf(
    "id" to id, "group" to group, "titleZh" to titleZh, "titleEn" to titleEn,
    "detailZh" to detailZh, "detailEn" to detailEn, "custom" to custom, "myAnswer" to myAnswer,
)

private fun PreferenceService.CompareResult.toMap() = mapOf(
    "partnerAnswered" to partnerAnswered,
    "bothWant" to bothWant.map { mapOf("itemId" to it.itemId, "title" to it.title) },
    "wantAndOk" to wantAndOk.map { mapOf("itemId" to it.itemId, "title" to it.title, "wantSide" to it.wantSide) },
    "someoneTalks" to someoneTalks.map { mapOf("itemId" to it.itemId, "title" to it.title) },
    "notDoing" to notDoing.map { mapOf("itemId" to it.itemId, "title" to it.title) },
)

private fun IdeaCardService.CardView.toMap() = mapOf(
    "id" to card.id, "audience" to card.audience, "titleZh" to card.titleZh, "titleEn" to card.titleEn,
    "howZh" to card.howZh, "howEn" to card.howEn, "needsZh" to card.needsZh, "needsEn" to card.needsEn,
    "intensity" to card.intensity, "tags" to card.tags, "relatedItemIds" to card.relatedItemIds,
    "state" to state,
)

private fun IdeaCardService.ActResult.toMap() = mapOf(
    "taskId" to taskId, "ruleId" to ruleId, "noteId" to noteId, "state" to state,
)

private fun com.dsapp.backend.explore.domain.StarterPackDef.toMap() = mapOf(
    "id" to id, "titleZh" to titleZh, "titleEn" to titleEn,
    "tasks" to tasks, "rules" to rules, "rewards" to rewards,
)

private fun StarterPackService.ApplyResult.toMap() = mapOf(
    "taskIds" to taskIds, "ruleIds" to ruleIds, "rewardIds" to rewardIds,
)

@RestController
@RequestMapping("/v1/dynamics/{dynamicId}/explore")
class ExploreController(
    private val preferences: PreferenceService,
    private val cards: IdeaCardService,
    private val packs: StarterPackService,
    private val post: IdempotentPost,
) {
    @GetMapping("/items")
    fun items(@AuthenticationPrincipal jwt: Jwt, @PathVariable dynamicId: UUID): ResponseEntity<Any> =
        ResponseEntity.ok(mapOf("items" to preferences.items(jwt.actorId(), dynamicId).map { it.toMap() }))

    @PutMapping("/items/{itemId}/answer")
    fun answer(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable itemId: String,
        @Valid @RequestBody body: AnswerItemBody,
    ): ResponseEntity<Any> =
        ResponseEntity.ok(preferences.answer(jwt.actorId(), dynamicId, itemId, body.answer).toMap())

    @PostMapping("/items")
    fun addCustom(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: AddCustomItemBody,
    ): ResponseEntity<Any> = post.run(jwt, key, "add_custom_preference_item", "/v1/dynamics/{id}/explore/items", listOf("$dynamicId"), body) {
        201 to preferences.addCustom(jwt.actorId(), dynamicId, body.group, body.title, body.detail).toMap()
    }

    @GetMapping("/compare")
    fun compare(@AuthenticationPrincipal jwt: Jwt, @PathVariable dynamicId: UUID): ResponseEntity<Any> =
        ResponseEntity.ok(preferences.compare(jwt.actorId(), dynamicId).toMap())

    @GetMapping("/cards")
    fun listCards(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestParam(required = false) audience: String?,
    ): ResponseEntity<Any> =
        ResponseEntity.ok(mapOf("cards" to cards.cards(jwt.actorId(), dynamicId, audience).map { it.toMap() }))

    @PostMapping("/cards/draw")
    fun draw(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
    ): ResponseEntity<Any> = post.run(jwt, key, "draw_idea_card", "/v1/dynamics/{id}/explore/cards/draw", listOf("$dynamicId"), null) {
        200 to cards.draw(jwt.actorId(), dynamicId).toMap()
    }

    @PostMapping("/cards/{cardId}/act")
    fun act(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable cardId: String,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: ActCardBody,
    ): ResponseEntity<Any> = post.run(jwt, key, "act_idea_card", "/v1/dynamics/{id}/explore/cards/{c}/act", listOf("$dynamicId", cardId), body) {
        200 to cards.act(jwt.actorId(), dynamicId, cardId, body.action).toMap()
    }

    @PostMapping("/packs/{packId}/apply")
    fun applyPack(
        @AuthenticationPrincipal jwt: Jwt,
        @PathVariable dynamicId: UUID,
        @PathVariable packId: String,
        @RequestHeader("Idempotency-Key", required = false) key: String?,
        @Valid @RequestBody body: ApplyPackBody,
    ): ResponseEntity<Any> = post.run(jwt, key, "apply_starter_pack", "/v1/dynamics/{id}/explore/packs/{p}/apply", listOf("$dynamicId", packId), body) {
        201 to packs.apply(jwt.actorId(), dynamicId, packId, StarterPackService.ApplyDraft(body.tasks, body.rules, body.rewards)).toMap()
    }
}

@RestController
@RequestMapping("/v1/explore/packs")
class StarterPackListController(private val packs: StarterPackService) {
    @GetMapping
    fun list(@AuthenticationPrincipal jwt: Jwt): ResponseEntity<Any> =
        ResponseEntity.ok(mapOf("packs" to packs.packs().map { it.toMap() }))
}
