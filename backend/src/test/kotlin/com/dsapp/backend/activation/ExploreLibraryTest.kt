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
        // Raised from 24/6 when the distance collection was added. The cap is
        // an editorial guard against becoming a content product, not a
        // technical limit, so it moves only for a reason that is written
        // down: LDR is the design pressure case named in 00-overview
        // (Android giving member, iPhone receiving member, different
        // timezones) and the library had nothing for it.
        //
        // It should keep taking a stated reason to move. A competitor ships
        // 46 ideas; matching that number is not a goal.
        assertTrue(ExploreLibrary.ideas.size <= 30,
            "this is a companion, not a library: ${ExploreLibrary.ideas.size}")
        assertTrue(ExploreLibrary.collections.size in 4..7)
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
    fun `nothing teaches the couple to score each other`() {
        val text = ExploreLibrary.ideas.joinToString(" ") {
            "${it.title} ${it.purpose} ${it.detail}"
        }.lowercase()
        for (banned in listOf(
            "punish", "proof", "point", "score", "streak", "obey",
            "fail", "reward", "earn", "deserve", "discipline",
        )) {
            assertTrue(!text.contains(banned),
                "the first thing a person reads must not teach scoring: '$banned'")
        }
    }

    @Test
    fun `nothing is explicit or describes a scene`() {
        val text = ExploreLibrary.ideas.joinToString(" ") {
            "${it.title} ${it.purpose} ${it.detail}"
        }.lowercase()
        // A person may be reading this on a train. Low privacy sensitivity is
        // a content rule, not a preference.
        for (banned in listOf(
            "kneel", "collar", "cuff", "spank", "naked", "bedroom",
            "submit to", "master", "slave", "worship",
        )) {
            assertTrue(!text.contains(banned), "not safe to read in public: '$banned'")
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
