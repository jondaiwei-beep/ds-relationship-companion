package com.dsapp.backend.explore.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.explore.domain.ExploreCatalog
import com.dsapp.backend.today.application.NoSuchItem
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

/**
 * 两人比对 (PreferenceCompare) — product/04-explore.md §1.
 *
 * The privacy rule, re-derived from 04-explore.md: "只有两人都答过的条目才
 * 互见" — an item where only one member has answered is not shown to the
 * other AT ALL, not even to signal that an answer exists. Once both have
 * answered:
 *   - 都想要 (want ∩ want)
 *   - 一个想要、一个可以 (want + ok, either combination) — the trailing note
 *     under Idea Cards says "which side wanted is fine to show" for this
 *     bucket specifically, so its DTO may name the side.
 *   - 有人想聊 (either side answered `talk`) — sorts as its own bucket
 *     regardless of the other side's answer, EXCEPT when either side said
 *     `no`: "不要" always wins (04-explore.md's closing invariant: "no" is
 *     the safety-relevant one and must never be diluted into "someone wants
 *     to talk instead").
 *   - 不要 (either side answered `no`) — "『不要』永远不归属到人 …
 *     不显示是谁选的": the DTO for this bucket carries no member id, no
 *     side, no per-member breakdown of any kind.
 *
 * A solo dynamic (partner hasn't joined, or has left) cannot leak a "mutual"
 * bucket that was never actually mutual — compare() returns all four buckets
 * empty with `partnerAnswered = false`.
 */
@Service
class PreferenceService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val catalog: ExploreCatalog,
) {
    val answers = listOf("want", "ok", "no", "talk")

    data class ItemView(
        val id: String,
        val group: String,
        val titleZh: String,
        val titleEn: String,
        val detailZh: String?,
        val detailEn: String?,
        val custom: Boolean,
        /** The caller's own answer only — never the partner's. */
        val myAnswer: String?,
    )

    data class WantAndOk(val itemId: String, val title: String, val wantSide: String)
    data class TitledItem(val itemId: String, val title: String)

    data class CompareResult(
        val partnerAnswered: Boolean,
        val bothWant: List<TitledItem>,
        val wantAndOk: List<WantAndOk>,
        val someoneTalks: List<TitledItem>,
        val notDoing: List<TitledItem>,
    )

    /** All system + custom items, each annotated with only the caller's own answer. */
    @Transactional(readOnly = true)
    fun items(actorUserId: UUID, dynamicId: UUID): List<ItemView> {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        val custom = customItems(dynamicId)
        val mine = myAnswers(dynamicId, actorUserId)
        val system = catalog.items.map {
            ItemView(it.id, it.group, it.titleZh, it.titleEn, it.detailZh, it.detailEn, custom = false, myAnswer = mine[it.id])
        }
        val customViews = custom.map {
            ItemView(it.id.toString(), it.group, it.title, it.title, it.detail, it.detail, custom = true, myAnswer = mine[it.id.toString()])
        }
        return system + customViews
    }

    /** Upsert the caller's answer. `itemId` resolves against the system catalog or this dynamic's custom items. */
    @Transactional
    fun answer(actorUserId: UUID, dynamicId: UUID, itemId: String, answer: String): ItemView {
        authorizer.requireActive(authorizer.contextForDynamic(actorUserId, dynamicId))
        require(answer in answers) { "answer" }
        val (title, group, detail) = resolveItem(dynamicId, itemId) ?: throw NoSuchItem()

        dsl.query(
            """
            INSERT INTO preference_answers (id, dynamic_id, item_id, member_user_id, answer)
            VALUES ({0}, {1}, {2}, {3}, {4})
            ON CONFLICT (dynamic_id, item_id, member_user_id)
            DO UPDATE SET answer = EXCLUDED.answer, updated_at = now()
            """.trimIndent(),
            UUID.randomUUID(), dynamicId, itemId, actorUserId, answer,
        ).execute()
        val isCustom = runCatching { UUID.fromString(itemId) }.isSuccess && customItems(dynamicId).any { it.id.toString() == itemId }
        return ItemView(itemId, group, title, title, detail, detail, custom = isCustom, myAnswer = answer)
    }

    /** Any active member may add a custom item to compare on (03-domain.md: 探索作答 D:✓ s:✓). */
    @Transactional
    fun addCustom(actorUserId: UUID, dynamicId: UUID, group: String, title: String, detail: String?): ItemView {
        authorizer.requireActive(authorizer.contextForDynamic(actorUserId, dynamicId))
        val t = title.trim()
        require(t.isNotEmpty() && t.length <= 120) { "title" }
        require(detail == null || detail.length <= 2000) { "detail" }
        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO preference_items_custom (id, dynamic_id, "group", title, detail, created_by)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5})
            """.trimIndent(),
            id, dynamicId, group.trim().ifEmpty { "other" }, t, detail?.trim()?.takeIf { it.isNotEmpty() }, actorUserId,
        ).execute()
        return ItemView(id.toString(), group, t, t, detail, detail, custom = true, myAnswer = null)
    }

    /** The privacy-critical bucketed comparison. */
    @Transactional(readOnly = true)
    fun compare(actorUserId: UUID, dynamicId: UUID): CompareResult {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        val members = activeMembers(dynamicId)
        if (members.size < 2) {
            return CompareResult(partnerAnswered = false, emptyList(), emptyList(), emptyList(), emptyList())
        }
        val (m1, m2) = members
        val titles = itemTitles(dynamicId)

        data class Row(val itemId: String, val a1: String?, val a2: String?)
        val rows = dsl.fetch(
            """
            SELECT item_id,
                   MAX(answer) FILTER (WHERE member_user_id = {1}) AS a1,
                   MAX(answer) FILTER (WHERE member_user_id = {2}) AS a2
              FROM preference_answers
             WHERE dynamic_id = {0} AND member_user_id IN ({1}, {2})
             GROUP BY item_id
            """.trimIndent(),
            dynamicId, m1, m2,
        ).map { Row(it.get("item_id", String::class.java), it.get("a1", String::class.java), it.get("a2", String::class.java)) }
            .filter { it.a1 != null && it.a2 != null } // 只有两人都答过的条目才互见

        val bothWant = mutableListOf<TitledItem>()
        val wantAndOk = mutableListOf<WantAndOk>()
        val someoneTalks = mutableListOf<TitledItem>()
        val notDoing = mutableListOf<TitledItem>()

        for (r in rows) {
            val title = titles[r.itemId] ?: r.itemId
            val ti = TitledItem(r.itemId, title)
            when {
                r.a1 == "no" || r.a2 == "no" -> notDoing.add(ti) // 不要永远优先，永不归属到人
                r.a1 == "talk" || r.a2 == "talk" -> someoneTalks.add(ti)
                r.a1 == "want" && r.a2 == "want" -> bothWant.add(ti)
                (r.a1 == "want" && r.a2 == "ok") || (r.a1 == "ok" && r.a2 == "want") -> {
                    val wantSide = if (r.a1 == "want") sideOf(dynamicId, m1) else sideOf(dynamicId, m2)
                    wantAndOk.add(WantAndOk(r.itemId, title, wantSide))
                }
                else -> Unit // ok+ok etc: not a bucket the spec asks for
            }
        }
        return CompareResult(partnerAnswered = true, bothWant, wantAndOk, someoneTalks, notDoing)
    }

    // ---- internals ---------------------------------------------------------

    /** Items where BOTH active members answered `no` — used by IdeaCardService to filter cards. */
    fun notDoingItemIds(actorUserId: UUID, dynamicId: UUID): Set<String> =
        compare(actorUserId, dynamicId).notDoing.map { it.itemId }.toSet()

    /** `talk` items — cards related to these sort first. */
    fun talkItemIds(actorUserId: UUID, dynamicId: UUID): Set<String> =
        compare(actorUserId, dynamicId).someoneTalks.map { it.itemId }.toSet()

    private fun resolveItem(dynamicId: UUID, itemId: String): Triple<String, String, String?>? {
        catalog.itemById(itemId)?.let { return Triple(it.titleZh, it.group, it.detailZh) }
        val uuid = runCatching { UUID.fromString(itemId) }.getOrNull() ?: return null
        val row = dsl.fetchOne(
            "SELECT title, \"group\", detail FROM preference_items_custom WHERE id = {0} AND dynamic_id = {1}",
            uuid, dynamicId,
        ) ?: return null
        return Triple(row.get("title", String::class.java), row.get("group", String::class.java), row.get("detail", String::class.java))
    }

    private fun customItems(dynamicId: UUID) = dsl.fetch(
        "SELECT id, \"group\", title, detail FROM preference_items_custom WHERE dynamic_id = {0} ORDER BY created_at", dynamicId,
    ).map {
        object {
            val id: UUID = it.get("id", UUID::class.java)
            val group: String = it.get("group", String::class.java)
            val title: String = it.get("title", String::class.java)
            val detail: String? = it.get("detail", String::class.java)
        }
    }

    private fun itemTitles(dynamicId: UUID): Map<String, String> {
        val system = catalog.items.associate { it.id to it.titleZh }
        val custom = customItems(dynamicId).associate { it.id.toString() to it.title }
        return system + custom
    }

    private fun myAnswers(dynamicId: UUID, actorUserId: UUID): Map<String, String> = dsl.fetch(
        "SELECT item_id, answer FROM preference_answers WHERE dynamic_id = {0} AND member_user_id = {1}",
        dynamicId, actorUserId,
    ).associate { it.get("item_id", String::class.java) to it.get("answer", String::class.java) }

    /** Active members, stable order (joined_at). Exactly the two sides when both are present. */
    private fun activeMembers(dynamicId: UUID): List<UUID> = dsl.fetch(
        "SELECT user_id FROM memberships WHERE dynamic_id = {0} AND access_state = 'ACTIVE' ORDER BY joined_at",
        dynamicId,
    ).map { it.get("user_id", UUID::class.java) }

    private fun sideOf(dynamicId: UUID, userId: UUID): String = dsl.fetchOne(
        "SELECT side FROM memberships WHERE dynamic_id = {0} AND user_id = {1}", dynamicId, userId,
    )!!.get("side", String::class.java)
}
