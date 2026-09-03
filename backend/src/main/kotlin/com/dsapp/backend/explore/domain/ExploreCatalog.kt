package com.dsapp.backend.explore.domain

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import org.springframework.core.io.ClassPathResource
import org.springframework.stereotype.Component

/**
 * The static explore content (product/04-explore.md) — a题库 of
 * PreferenceItems, a deck of IdeaCards, and 7 StarterPacks. Loaded once at
 * startup from the JSON files under src/main/resources/explore/; the same
 * content for everyone, so it lives in memory rather than a table
 * (dynamic-scoped custom preference items are the only part of Explore that
 * is actually a table — see V20__explore.sql).
 */
data class PreferenceItemDef(
    val id: String,
    val group: String,
    val titleZh: String,
    val titleEn: String,
    val detailZh: String? = null,
    val detailEn: String? = null,
)

data class IdeaCardDef(
    val id: String,
    /** for_d | for_s | for_both */
    val audience: String,
    val titleZh: String,
    val titleEn: String,
    val howZh: List<String> = emptyList(),
    val howEn: List<String> = emptyList(),
    val needsZh: List<String> = emptyList(),
    val needsEn: List<String> = emptyList(),
    val intensity: Int = 1,
    val tags: List<String> = emptyList(),
    val relatedItemIds: List<String> = emptyList(),
)

data class StarterPackTaskDef(
    val titleZh: String,
    val titleEn: String,
    /** recurring | checkin (04-explore.md §3) */
    val kind: String = "checkin",
    val schedule: Map<String, Any?>? = null,
    val dueTime: String? = null,
    val proof: String = "check",
    val pointsEarn: Int = 0,
)

data class StarterPackRuleDef(
    val titleZh: String,
    val titleEn: String,
    val bodyZh: String? = null,
    val bodyEn: String? = null,
    val group: String = "other",
)

data class StarterPackRewardDef(
    val titleZh: String,
    val titleEn: String,
    val cost: Int? = null,
)

data class StarterPackDef(
    val id: String,
    val titleZh: String,
    val titleEn: String,
    val tasks: List<StarterPackTaskDef>,
    val rules: List<StarterPackRuleDef>,
    val rewards: List<StarterPackRewardDef>,
)

@Component
class ExploreCatalog(mapper: ObjectMapper) {

    /** A Jackson mapper reading snake_case JSON keys into camelCase Kotlin properties. */
    private val json: ObjectMapper = mapper.copy()
        .setPropertyNamingStrategy(com.fasterxml.jackson.databind.PropertyNamingStrategies.SNAKE_CASE)

    val items: List<PreferenceItemDef> = load("classpath:explore/preference_items.json")
    val cards: List<IdeaCardDef> = load("classpath:explore/idea_cards.json")
    val packs: List<StarterPackDef> = load("classpath:explore/starter_packs.json")

    private val itemsById = items.associateBy { it.id }
    private val packsById = packs.associateBy { it.id }
    private val cardsById = cards.associateBy { it.id }

    fun itemById(id: String): PreferenceItemDef? = itemsById[id]
    fun packById(id: String): StarterPackDef? = packsById[id]
    fun cardById(id: String): IdeaCardDef? = cardsById[id]

    private inline fun <reified T> load(location: String): List<T> {
        val resource = ClassPathResource(location.removePrefix("classpath:"))
        return json.readValue(resource.inputStream)
    }
}
