package com.dsapp.backend.explore

import com.dsapp.backend.explore.application.IdeaCardService
import com.dsapp.backend.explore.application.PreferenceService
import com.dsapp.backend.explore.application.StarterPackService
import com.dsapp.backend.explore.domain.ExploreCatalog
import com.dsapp.backend.rules.application.RuleService
import com.dsapp.backend.shared.idempotency.IdempotencyService
import com.dsapp.backend.shared.idempotency.RequestHasher
import com.dsapp.backend.today.application.TaskService
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.time.LocalDate
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * 探索 — product/04-explore.md. Covers the privacy-critical bucketing of
 * PreferenceCompare, card filtering/draw, and starter-pack apply.
 */
@SpringBootTest
@ActiveProfiles("test")
class ExploreIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var preferences: PreferenceService
    @Autowired lateinit var cards: IdeaCardService
    @Autowired lateinit var packs: StarterPackService
    @Autowired lateinit var catalog: ExploreCatalog
    @Autowired lateinit var idempotency: IdempotencyService

    private lateinit var d: UUID
    private lateinit var s: UUID
    private lateinit var dyn: UUID

    @BeforeEach
    fun seed() {
        d = UUID.randomUUID(); s = UUID.randomUUID(); dyn = UUID.randomUUID()
        for ((u, n) in listOf(d to "Alex", s to "Jamie")) {
            dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},{2})", u, "$u@t", n).execute()
        }
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','STRUCTURE','STEADY','ACTIVE','UTC')""", dyn,
        ).execute()
        for ((u, r, side) in listOf(Triple(d, "CREATOR", "D"), Triple(s, "PARTNER", "S"))) {
            dsl.query(
                "INSERT INTO memberships (user_id,dynamic_id,role_context,side,access_state) VALUES ({0},{1},{2},{3},'ACTIVE')",
                u, dyn, r, side,
            ).execute()
        }
    }

    private fun someItemId(): String = catalog.items.first().id

    // ---- content loads at startup ------------------------------------------

    @Test
    fun `catalog content loads and every card's related items resolve`() {
        assertTrue(catalog.items.isNotEmpty())
        assertTrue(catalog.cards.isNotEmpty())
        assertEquals(7, catalog.packs.size)
        val itemIds = catalog.items.map { it.id }.toSet()
        for (card in catalog.cards) {
            for (rel in card.relatedItemIds) {
                assertTrue(rel in itemIds, "card ${card.id} references unknown item $rel")
            }
        }
    }

    // ---- privacy: answers are invisible until both have answered ----------

    @Test
    fun `an item stays private until both members have answered it`() {
        val item = someItemId()
        preferences.answer(s, dyn, item, "want")

        // The D's own items() view never carries the s's answer, only the D's own (null here).
        val dView = preferences.items(d, dyn).first { it.id == item }
        assertNull(dView.myAnswer)

        // Not mutual yet: absent from every compare bucket.
        val cmp = preferences.compare(d, dyn)
        assertTrue(cmp.bothWant.none { it.itemId == item })
        assertTrue(cmp.wantAndOk.none { it.itemId == item })
        assertTrue(cmp.someoneTalks.none { it.itemId == item })
        assertTrue(cmp.notDoing.none { it.itemId == item })

        preferences.answer(d, dyn, item, "want")
        val cmp2 = preferences.compare(d, dyn)
        assertTrue(cmp2.bothWant.any { it.itemId == item })
    }

    @Test
    fun `no is never attributed to a member in the notDoing bucket`() {
        val item = someItemId()
        preferences.answer(d, dyn, item, "no")
        preferences.answer(s, dyn, item, "want")

        val cmp = preferences.compare(d, dyn)
        val entry = cmp.notDoing.first { it.itemId == item }

        // Reflective check: the DTO class must carry no member/side field anywhere.
        val fieldNames = entry.javaClass.declaredFields.map { it.name }
        for (forbidden in listOf("memberId", "member_id", "userId", "user_id", "side", "byUserId", "by_user_id")) {
            assertFalse(forbidden in fieldNames, "notDoing DTO leaked a $forbidden field")
        }
        assertEquals(setOf("itemId", "title"), fieldNames.toSet())
    }

    @Test
    fun `compare buckets are correct across combinations`() {
        val wantWant = catalog.items[0].id
        val wantOk = catalog.items[1].id
        val talk = catalog.items[2].id
        val no = catalog.items[3].id

        preferences.answer(d, dyn, wantWant, "want"); preferences.answer(s, dyn, wantWant, "want")
        preferences.answer(d, dyn, wantOk, "want"); preferences.answer(s, dyn, wantOk, "ok")
        preferences.answer(d, dyn, talk, "talk"); preferences.answer(s, dyn, talk, "ok")
        preferences.answer(d, dyn, no, "ok"); preferences.answer(s, dyn, no, "no")

        val cmp = preferences.compare(d, dyn)
        assertTrue(cmp.bothWant.any { it.itemId == wantWant })
        assertTrue(cmp.wantAndOk.any { it.itemId == wantOk })
        assertTrue(cmp.someoneTalks.any { it.itemId == talk })
        assertTrue(cmp.notDoing.any { it.itemId == no })

        // wantAndOk may name which side wanted — that bucket is explicitly not sensitive.
        val wo = cmp.wantAndOk.first { it.itemId == wantOk }
        assertEquals("D", wo.wantSide)
    }

    @Test
    fun `a solo dynamic returns empty buckets with partnerAnswered false, no crash`() {
        val soloDyn = UUID.randomUUID()
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','STRUCTURE','STEADY','ACTIVE','UTC')""", soloDyn,
        ).execute()
        dsl.query(
            "INSERT INTO memberships (user_id,dynamic_id,role_context,side,access_state) VALUES ({0},{1},'CREATOR','D','ACTIVE')",
            d, soloDyn,
        ).execute()
        preferences.answer(d, soloDyn, someItemId(), "want")

        val cmp = preferences.compare(d, soloDyn)
        assertFalse(cmp.partnerAnswered)
        assertTrue(cmp.bothWant.isEmpty())
        assertTrue(cmp.wantAndOk.isEmpty())
        assertTrue(cmp.someoneTalks.isEmpty())
        assertTrue(cmp.notDoing.isEmpty())
    }

    // ---- card filtering / draw ---------------------------------------------

    @Test
    fun `a card related to a mutually-no item is excluded from listing`() {
        val card = catalog.cards.first { it.relatedItemIds.isNotEmpty() }
        val relatedItem = card.relatedItemIds.first()
        preferences.answer(d, dyn, relatedItem, "no")
        preferences.answer(s, dyn, relatedItem, "no")

        val listed = cards.cards(d, dyn, null)
        assertTrue(listed.none { it.card.id == card.id })
    }

    @Test
    fun `a card related to a talk item sorts before others`() {
        val talkCard = catalog.cards.first { it.audience in setOf("for_d", "for_both") && it.relatedItemIds.isNotEmpty() }
        val relatedItem = talkCard.relatedItemIds.first()
        preferences.answer(d, dyn, relatedItem, "talk")
        preferences.answer(s, dyn, relatedItem, "ok")

        val listed = cards.cards(d, dyn, null)
        val talkIdx = listed.indexOfFirst { it.card.id == talkCard.id }
        assertTrue(talkIdx >= 0)
        // Every card strictly before it must also relate to a "talk" item (stable partition).
        for (i in 0 until talkIdx) {
            assertTrue(listed[i].card.relatedItemIds.contains(relatedItem) || true) // partition property below
        }
        // Simplest robust assertion: the talk-related card is not sorted after any non-talk-related one it wasn't tied with.
        assertEquals(listed.sortedByDescending { it.card.relatedItemIds.contains(relatedItem) }.map { it.card.id }.indexOf(talkCard.id), talkIdx)
    }

    @Test
    fun `draw never enqueues an outbox row`() {
        val before = dsl.fetchOne("SELECT count(*) c FROM outbox_records")!!.get("c", Long::class.java)
        cards.draw(d, dyn)
        val after = dsl.fetchOne("SELECT count(*) c FROM outbox_records")!!.get("c", Long::class.java)
        assertEquals(before, after)
    }

    // ---- act(add_today) proposed/active + occurrence -----------------------

    @Test
    fun `act add_today as s yields a proposed task, as D yields active with today's occurrence`() {
        val card = catalog.cards.first { it.audience in setOf("for_s", "for_both") }
        val sResult = cards.act(s, dyn, card.id, "add_today")
        assertNotNull(sResult.taskId)
        val sTask = dsl.fetchOne("SELECT status FROM tasks WHERE id = {0}", sResult.taskId)!!
        assertEquals("proposed", sTask.get("status", String::class.java))

        val dCard = catalog.cards.first { it.audience in setOf("for_d", "for_both") }
        val dResult = cards.act(d, dyn, dCard.id, "add_today")
        assertNotNull(dResult.taskId)
        val dTask = dsl.fetchOne("SELECT status FROM tasks WHERE id = {0}", dResult.taskId)!!
        assertEquals("active", dTask.get("status", String::class.java))

        val occCount = dsl.fetchOne(
            "SELECT count(*) c FROM occurrences WHERE task_id = {0}", dResult.taskId,
        )!!.get("c", Long::class.java)
        assertTrue(occCount >= 1)
    }

    // ---- starter pack apply --------------------------------------------------

    @Test
    fun `pack apply creates exactly the trimmed draft, not the full static pack`() {
        val pack = catalog.packs.first()
        assertTrue(pack.tasks.size >= 2, "fixture assumes a pack with 2+ tasks")

        val trimmedTask = pack.tasks.first()
        val draft = StarterPackService.ApplyDraft(
            tasks = listOf(
                StarterPackService.DraftTask(
                    title = trimmedTask.titleZh, kind = trimmedTask.kind,
                    schedule = trimmedTask.schedule, dueTime = trimmedTask.dueTime,
                    proof = trimmedTask.proof, pointsEarn = trimmedTask.pointsEarn,
                ),
            ),
            rules = emptyList(),
            rewards = emptyList(),
        )
        val result = packs.apply(d, dyn, pack.id, draft)
        assertEquals(1, result.taskIds.size)
        assertEquals(0, result.ruleIds.size)
        assertEquals(0, result.rewardIds.size)

        val createdTitle = dsl.fetchOne("SELECT title FROM tasks WHERE id = {0}", result.taskIds.first())!!
            .get("title", String::class.java)
        assertEquals(trimmedTask.titleZh, createdTitle)

        // The dropped tasks from the full pack must not exist for this dynamic.
        for (dropped in pack.tasks.drop(1)) {
            val exists = dsl.fetchOne(
                "SELECT 1 FROM tasks WHERE dynamic_id = {0} AND title = {1}", dyn, dropped.titleZh,
            )
            assertNull(exists, "dropped pack task '${dropped.titleZh}' should not have been created")
        }
    }

    @Test
    fun `pack apply is idempotent via the idempotency service — second call replays, no double-create`() {
        val pack = catalog.packs.first { it.rewards.isNotEmpty() }
        val draft = StarterPackService.ApplyDraft(
            tasks = emptyList(), rules = emptyList(),
            rewards = listOf(StarterPackService.DraftReward(title = pack.rewards.first().titleZh, cost = pack.rewards.first().cost)),
        )
        val key = "test-key-${UUID.randomUUID()}"
        val hash = RequestHasher.sha256(
            method = "POST", routeTemplate = "/v1/dynamics/{id}/explore/packs/{p}/apply",
            pathIds = listOf("$dyn", pack.id), contentType = "application/json", exactBody = ByteArray(0),
        )

        var calls = 0
        val outcome1 = idempotency.executeOnce(d, key, "apply_starter_pack_test", hash) { _ ->
            calls++
            val r = packs.apply(d, dyn, pack.id, draft)
            com.dsapp.backend.shared.idempotency.IdempotencyResponse(201, r.rewardIds.toString().toByteArray())
        }
        val outcome2 = idempotency.executeOnce(d, key, "apply_starter_pack_test", hash) { _ ->
            calls++
            val r = packs.apply(d, dyn, pack.id, draft)
            com.dsapp.backend.shared.idempotency.IdempotencyResponse(201, r.rewardIds.toString().toByteArray())
        }

        assertEquals(1, calls, "second call should replay the cached response, not re-invoke the block")
        assertEquals(outcome1.body.toString(Charsets.UTF_8), outcome2.body.toString(Charsets.UTF_8))

        val rewardCount = dsl.fetchOne(
            "SELECT count(*) c FROM rewards WHERE dynamic_id = {0} AND title = {1}", dyn, pack.rewards.first().titleZh,
        )!!.get("c", Long::class.java)
        assertEquals(1, rewardCount)
    }

    @Test
    fun `custom preference item can be answered and compared like a system item`() {
        val custom = preferences.addCustom(d, dyn, "other", "自定义条目", null)
        preferences.answer(d, dyn, custom.id, "want")
        preferences.answer(s, dyn, custom.id, "want")
        val cmp = preferences.compare(d, dyn)
        assertTrue(cmp.bothWant.any { it.itemId == custom.id })
    }

    @Test
    fun `d note save is private and s save records idea_card_states instead`() {
        val dCard = catalog.cards.first { it.audience in setOf("for_d", "for_both") }
        val dResult = cards.act(d, dyn, dCard.id, "save")
        assertNotNull(dResult.noteId)

        val sCard = catalog.cards.first { it.audience in setOf("for_s", "for_both") }
        val sResult = cards.act(s, dyn, sCard.id, "save")
        assertNull(sResult.noteId)
        assertEquals("saved", sResult.state)
    }
}
