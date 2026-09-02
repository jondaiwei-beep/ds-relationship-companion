package com.dsapp.backend.activation

import com.dsapp.backend.activation.domain.ExploreLibrary
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * The library exists so a person can judge the product's taste before
 * exposing an intimate interest to someone they know. What it contains is
 * therefore a product guarantee, not decoration.
 */
class ExploreLibraryTest {

    @Test
    fun `there is enough to browse and not so much it becomes a content product`() {
        assertTrue(ExploreLibrary.ideas.size >= 12,
            "too thin to prove judgement: ${ExploreLibrary.ideas.size}")
        // Raised 30 -> 45 and 7 -> 9 collections on 2026-09-02 when the
        // library stopped speaking in euphemism and gained rules/consequences
        // and around-a-scene collections. Still an editorial guard: a
        // competitor ships 46+ ideas and matching that is not a goal.
        assertTrue(ExploreLibrary.ideas.size <= 45,
            "this is a companion, not a library: ${ExploreLibrary.ideas.size}")
        assertTrue(ExploreLibrary.collections.size in 4..9)
    }

    @Test
    fun `every collection has something in it`() {
        for (c in ExploreLibrary.collections) {
            assertTrue(ExploreLibrary.byCollection(c.id).isNotEmpty(),
                "empty collection would be another 'nothing here yet': ${c.id}")
        }
    }

    @Test
    fun `every idea belongs to a real collection and has a unique id`() {
        val ids = ExploreLibrary.collections.map { it.id }.toSet()
        for (i in ExploreLibrary.ideas) {
            assertTrue(i.collectionId in ids, "orphan idea: ${i.id}")
        }
        assertEquals(
            ExploreLibrary.ideas.size,
            ExploreLibrary.ideas.map { it.id }.toSet().size,
        )
    }

    @Test
    fun `the library is recognisably D-s, not a couples app in costume`() {
        // Owner's decision 2026-09-02: remove every content restriction that
        // hid what the product is for. The previous guards banned kneel,
        // collar, master, obey, punish, discipline — and the library read as
        // generic. This inverts them: the words this audience uses must
        // appear, or the library has drifted back.
        val text = ExploreLibrary.ideas.joinToString(" ") {
            "${it.title} ${it.purpose} ${it.detail}"
        }.lowercase()
        for (required in listOf(
            "kneel", "collar", "dominant", "submissive", "permission",
            "punishment", "safeword", "protocol", "obedience", "sir",
        )) {
            assertTrue(text.contains(required),
                "a D/s library that never says '$required' is hiding what it is for")
        }
    }

    @Test
    fun `nothing is written in the system's own voice toward a person`() {
        // Red line #1 is the one restriction that stays: the app never
        // praises, corrects or addresses anyone. Every idea is something one
        // of the two people does. A sentence addressed from "we" or "the app"
        // to "you" as a verdict would be the system speaking.
        val text = ExploreLibrary.ideas.joinToString(" ") {
            "${it.purpose} ${it.detail}"
        }.lowercase()
        for (banned in listOf("we think you", "the app ", "this app will", "you have earned")) {
            assertTrue(!text.contains(banned), "system voice leaked into content: '$banned'")
        }
    }

    @Test
    fun `every idea says what it is and why it matters`() {
        for (i in ExploreLibrary.ideas) {
            assertTrue(i.title.isNotBlank())
            // An idea that says only WHAT reads as a chore. The reason is
            // what makes it something one person asks of another.
            assertTrue(i.purpose.length > 20, "no reason given: ${i.id}")
            assertTrue(i.detail.length > 20, "not concrete enough: ${i.id}")
        }
    }

    @Test
    fun `all three kinds are represented`() {
        val kinds = ExploreLibrary.ideas.map { it.kind }.toSet()
        assertEquals(ExploreLibrary.Kind.entries.toSet(), kinds)
    }
}
