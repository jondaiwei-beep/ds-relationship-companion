package com.dsapp.backend.points

import com.dsapp.backend.expectation.application.CompleteOccurrenceService
import com.dsapp.backend.points.application.InsufficientPoints
import com.dsapp.backend.points.application.PointsService
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * Points, rewards and consequences — owner decision 2026-09-02.
 *
 * The tests that matter most here are not the arithmetic ones. They are the
 * two that hold the constraints this feature was allowed under: points must
 * never close a moment that is waiting for a human, and no consequence may
 * exist without a person who issued it.
 */
@SpringBootTest
@ActiveProfiles("test")
class PointsIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var points: PointsService
    @Autowired lateinit var complete: CompleteOccurrenceService

    private lateinit var dom: UUID
    private lateinit var sub: UUID
    private lateinit var dynamicId: UUID
    private lateinit var definitionId: UUID
    private lateinit var occurrenceId: UUID

    private fun idem(actor: UUID): UUID {
        val id = UUID.randomUUID()
        dsl.query(
            """INSERT INTO idempotency_keys (id,actor_user_id,key_value,command_name,request_hash,state)
               VALUES ({0},{1},{2},'t',{3},'IN_PROGRESS')""",
            id, actor, "k-$id", ByteArray(32),
        ).execute()
        return id
    }

    @BeforeEach
    fun seed() {
        dom = UUID.randomUUID(); sub = UUID.randomUUID()
        dynamicId = UUID.randomUUID(); definitionId = UUID.randomUUID()
        occurrenceId = UUID.randomUUID()

        for ((u, n) in listOf(dom to "Alex", sub to "Jamie")) {
            dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},{2})",
                u, "$u@t", n).execute()
        }
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','STRUCTURE','STEADY','ACTIVE','America/New_York')""", dynamicId,
        ).execute()
        for ((u, r) in listOf(dom to "CREATOR", sub to "PARTNER")) {
            dsl.query(
                "INSERT INTO memberships (user_id,dynamic_id,role_context,access_state) VALUES ({0},{1},{2},'ACTIVE')",
                u, dynamicId, r,
            ).execute()
        }
        dsl.query(
            """INSERT INTO expectation_definitions
                 (id,dynamic_id,kind,title,creator_user_id,assignee_user_id,visibility)
               VALUES ({0},{1},'TASK','Prepare the evening space',{2},{3},'SHARED')""",
            definitionId, dynamicId, dom, sub,
        ).execute()
        dsl.query(
            """INSERT INTO occurrences (id,definition_id,dynamic_id,state,relationship_day)
               VALUES ({0},{1},{2},'ACTIVE',CURRENT_DATE)""",
            occurrenceId, definitionId, dynamicId,
        ).execute()
    }

    private fun stateOf() = dsl.fetchOne(
        "SELECT state FROM occurrences WHERE id={0}", occurrenceId,
    )!!.get("state", String::class.java)

    // ---- the constraints this feature was allowed under --------------------

    @Test
    fun `earning points does NOT answer the moment - it still waits for a human`() {
        // The whole product test: reduce the work of maintaining a Dynamic
        // without automating away the human attention that gives it meaning.
        // If points ever closed a completion, they would have replaced the
        // partner rather than supplemented them.
        complete.complete(sub, occurrenceId, null, idem(sub))

        assertEquals(1, points.balanceOf(dynamicId, sub))
        assertEquals("WAITING_ACK", stateOf(), "points must not end the wait")

        val acks = dsl.fetchOne(
            "SELECT count(*) AS n FROM acknowledgements WHERE occurrence_id={0}", occurrenceId,
        )!!.get("n", Int::class.java)
        assertEquals(0, acks, "no acknowledgement may be manufactured by scoring")
    }

    @Test
    fun `a consequence always names the person who issued it`() {
        val a = points.addAgreement(dom, dynamicId, "Missed evening", "Early bedtime", 0)
        points.issueConsequence(dom, dynamicId, sub, a, occurrenceId, waived = false, note = null)

        val issuer = dsl.fetchOne(
            "SELECT issued_by_user_id FROM consequence_events WHERE dynamic_id={0}", dynamicId,
        )!!.get("issued_by_user_id", UUID::class.java)

        assertEquals(dom, issuer, "the software never issues a consequence")
    }

    @Test
    fun `waiving is recorded, and costs nothing`() {
        val a = points.addAgreement(dom, dynamicId, "Missed evening", "Early bedtime", 5)
        points.adjust(dom, dynamicId, sub, 10, null)

        points.issueConsequence(dom, dynamicId, sub, a, occurrenceId, waived = true, note = null)

        assertEquals(10, points.balanceOf(dynamicId, sub), "mercy is free")
        val outcome = dsl.fetchOne(
            "SELECT outcome FROM consequence_events WHERE dynamic_id={0}", dynamicId,
        )!!.get("outcome", String::class.java)
        assertEquals("WAIVED", outcome, "being let off is recorded, not silent")
    }

    @Test
    fun `issuing with a point cost deducts, waiving the same agreement does not`() {
        val a = points.addAgreement(dom, dynamicId, "Missed evening", "Early bedtime", 5)
        points.adjust(dom, dynamicId, sub, 10, null)

        points.issueConsequence(dom, dynamicId, sub, a, null, waived = false, note = null)
        assertEquals(5, points.balanceOf(dynamicId, sub))
    }

    @Test
    fun `a balance never goes negative - nobody is in debt to their partner`() {
        // Obedience shows -152 against a heart: the app telling someone their
        // affection account is overdrawn, with no reward reachable and no move
        // available but climbing out of a hole.
        points.adjust(dom, dynamicId, sub, 3, null)
        points.adjust(dom, dynamicId, sub, -10, null)

        assertEquals(0, points.balanceOf(dynamicId, sub), "a deduction takes what is there")

        // And a deduction against nothing is a no-op, not a debt.
        assertNull(points.adjust(dom, dynamicId, sub, -5, null))
        assertEquals(0, points.balanceOf(dynamicId, sub))
    }

    @Test
    fun `a consequence cannot push someone below zero either`() {
        val a = points.addAgreement(dom, dynamicId, "Missed evening", "Early bedtime", 5)
        points.adjust(dom, dynamicId, sub, 2, null)

        points.issueConsequence(dom, dynamicId, sub, a, null, waived = false, note = null)

        assertEquals(0, points.balanceOf(dynamicId, sub))
    }

    @Test
    fun `a reward can be given outright, and says who gave it`() {
        // The feature none of the three competitors have. No cost, no balance
        // check: authority in its most generous form.
        val r = points.addReward(dom, dynamicId, "Massage", null, 10)
        points.gift(dom, dynamicId, r, sub)

        assertEquals(0, points.balanceOf(dynamicId, sub), "a gift costs the receiver nothing")
        val giver = dsl.fetchOne(
            "SELECT given_by_user_id FROM reward_redemptions WHERE reward_id={0}", r,
        )!!.get("given_by_user_id", UUID::class.java)
        assertEquals(dom, giver, "the point of a gift is who it came from")
    }

    @Test
    fun `taking a free reward yourself is not recorded as a gift`() {
        val r = points.addReward(dom, dynamicId, "Ask for anything", null, 0)
        points.redeem(sub, dynamicId, r)

        assertNull(
            dsl.fetchOne("SELECT given_by_user_id FROM reward_redemptions WHERE reward_id={0}", r)!!
                .get("given_by_user_id", UUID::class.java),
        )
    }

    // ---- ordinary behaviour ------------------------------------------------

    @Test
    fun `a couple can turn the economy off entirely`() {
        dsl.query("UPDATE dynamics SET points_enabled = false WHERE id={0}", dynamicId).execute()

        complete.complete(sub, occurrenceId, null, idem(sub))

        assertEquals(0, points.balanceOf(dynamicId, sub))
        assertEquals("WAITING_ACK", stateOf(), "the loop is unchanged without points")
    }

    @Test
    fun `zero per completion keeps manual awards available`() {
        dsl.query("UPDATE dynamics SET points_per_completion = 0 WHERE id={0}", dynamicId).execute()
        complete.complete(sub, occurrenceId, null, idem(sub))
        assertEquals(0, points.balanceOf(dynamicId, sub))

        points.adjust(dom, dynamicId, sub, 3, "for the week")
        assertEquals(3, points.balanceOf(dynamicId, sub))
    }

    @Test
    fun `a reward cannot be bought without the points`() {
        val r = points.addReward(dom, dynamicId, "Massage", null, 10)
        assertFailsWith<InsufficientPoints> { points.redeem(sub, dynamicId, r) }

        points.adjust(dom, dynamicId, sub, 10, null)
        points.redeem(sub, dynamicId, r)
        assertEquals(0, points.balanceOf(dynamicId, sub))
    }

    @Test
    fun `the ledger is append-only, so a balance always equals its history`() {
        points.adjust(dom, dynamicId, sub, 7, null)
        points.adjust(dom, dynamicId, sub, -2, null)

        val rows = dsl.fetch(
            "SELECT amount FROM point_entries WHERE dynamic_id={0} AND subject_user_id={1}",
            dynamicId, sub,
        ).map { it.get("amount", Int::class.java) }

        assertEquals(listOf(7, -2), rows)
        assertEquals(5, points.balanceOf(dynamicId, sub))
    }

    @Test
    fun `a retired reward disappears from the list but keeps its history readable`() {
        val r = points.addReward(dom, dynamicId, "Massage", null, 4)
        points.adjust(dom, dynamicId, sub, 4, null)
        points.redeem(sub, dynamicId, r)
        points.retireReward(dom, dynamicId, r)

        assertTrue(points.rewards(sub, dynamicId, sub).none { it.id == r })
        val note = dsl.fetchOne(
            "SELECT note FROM point_entries WHERE reward_id={0}", r,
        )!!.get("note", String::class.java)
        assertEquals("Massage", note, "what was bought is still legible")
    }

    @Test
    fun `a free reward can be taken, and taking it is still recorded`() {
        // cost = 0 is legal, but the ledger forbids a zero-amount row. Without
        // a separate record, taking a free reward would either crash or vanish.
        val r = points.addReward(dom, dynamicId, "Ask for anything", null, 0)
        points.redeem(sub, dynamicId, r)

        assertEquals(0, points.balanceOf(dynamicId, sub))
        val n = dsl.fetchOne(
            "SELECT count(*) AS n FROM reward_redemptions WHERE reward_id={0}", r,
        )!!.get("n", Int::class.java)
        assertEquals(1, n, "a free reward taken is still something that happened")
    }

    @Test
    fun `affordability is answered per person, from their own balance`() {
        points.addReward(dom, dynamicId, "Massage", null, 10)
        points.adjust(dom, dynamicId, sub, 10, null)

        assertTrue(points.rewards(sub, dynamicId, sub).single().affordable)
        assertTrue(!points.rewards(dom, dynamicId, dom).single().affordable)
    }

    @Test
    fun `either member may end an agreement alone`() {
        val a = points.addAgreement(dom, dynamicId, "Missed evening", "Early bedtime", 0)
        points.endAgreement(sub, dynamicId, a)

        assertTrue(points.agreements(sub, dynamicId).isEmpty())
    }

    @Test
    fun `a completion award records no actor, because nobody chose it`() {
        complete.complete(sub, occurrenceId, null, idem(sub))
        val actor = dsl.fetchOne(
            "SELECT actor_user_id FROM point_entries WHERE occurrence_id={0}", occurrenceId,
        )!!.get("actor_user_id", UUID::class.java)
        assertNull(actor, "an automatic award must not be attributed to a person")
    }
}
