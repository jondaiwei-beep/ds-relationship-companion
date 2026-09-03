package com.dsapp.backend.points

import com.dsapp.backend.points.application.PointsService
import com.dsapp.backend.points.application.RedemptionRequiresCost
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNotNull
import kotlin.test.assertNull

/**
 * Redemption requests (product/03-domain.md §Reward/Redemption): the s asks,
 * the D decides. Only an approval ever writes a ledger row, and it writes
 * exactly one, attributed to the deciding D.
 */
@SpringBootTest
@ActiveProfiles("test")
class RedemptionIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var points: PointsService

    private lateinit var dom: UUID
    private lateinit var sub: UUID
    private lateinit var dynamicId: UUID

    @BeforeEach
    fun seed() {
        dom = UUID.randomUUID(); sub = UUID.randomUUID(); dynamicId = UUID.randomUUID()
        for ((u, n) in listOf(dom to "Alex", sub to "Jamie")) {
            dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},{2})", u, "$u@t", n).execute()
        }
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','STRUCTURE','STEADY','ACTIVE','UTC')""", dynamicId,
        ).execute()
        for ((u, r, side) in listOf(Triple(dom, "CREATOR", "D"), Triple(sub, "PARTNER", "S"))) {
            dsl.query(
                "INSERT INTO memberships (user_id,dynamic_id,role_context,side,access_state) VALUES ({0},{1},{2},{3},'ACTIVE')",
                u, dynamicId, r, side,
            ).execute()
        }
    }

    @Test
    fun `a requested redemption deducts nothing until approved`() {
        val r = points.addReward(dom, dynamicId, "Movie night", null, 5)
        points.adjust(dom, dynamicId, sub, 10, null)

        val redemptionId = points.request(sub, dynamicId, r, "pretty please")

        assertEquals(10, points.balanceOf(dynamicId, sub), "asking spends nothing")
        val row = dsl.fetchOne("SELECT status, point_entry_id FROM reward_redemptions WHERE id={0}", redemptionId)!!
        assertEquals("requested", row.get("status", String::class.java))
        assertNull(row.get("point_entry_id", UUID::class.java))
    }

    @Test
    fun `denying a redemption deducts nothing`() {
        val r = points.addReward(dom, dynamicId, "Movie night", null, 5)
        points.adjust(dom, dynamicId, sub, 10, null)
        val redemptionId = points.request(sub, dynamicId, r, null)

        points.decide(dom, dynamicId, redemptionId, approve = false, note = "not tonight")

        assertEquals(10, points.balanceOf(dynamicId, sub))
        val row = dsl.fetchOne("SELECT status, decided_by FROM reward_redemptions WHERE id={0}", redemptionId)!!
        assertEquals("denied", row.get("status", String::class.java))
        assertEquals(dom, row.get("decided_by", UUID::class.java))
    }

    @Test
    fun `approving writes exactly one redemption ledger row attributed to the D`() {
        val r = points.addReward(dom, dynamicId, "Movie night", null, 5)
        points.adjust(dom, dynamicId, sub, 10, null)
        val redemptionId = points.request(sub, dynamicId, r, null)

        points.decide(dom, dynamicId, redemptionId, approve = true, note = null)

        assertEquals(5, points.balanceOf(dynamicId, sub))
        val entries = dsl.fetch(
            "SELECT actor_user_id, amount FROM point_entries WHERE dynamic_id={0} AND reason='redemption'", dynamicId,
        )
        assertEquals(1, entries.size)
        assertEquals(dom, entries[0].get("actor_user_id", UUID::class.java))
        assertEquals(-5, entries[0].get("amount", Int::class.java))

        val row = dsl.fetchOne("SELECT status, point_entry_id FROM reward_redemptions WHERE id={0}", redemptionId)!!
        assertEquals("approved", row.get("status", String::class.java))
        assertNotNull(row.get("point_entry_id", UUID::class.java))
    }

    @Test
    fun `a D-decided reward requires a cost at approval`() {
        val r = points.addReward(dom, dynamicId, "Surprise", null, null)
        points.adjust(dom, dynamicId, sub, 10, null)
        val redemptionId = points.request(sub, dynamicId, r, null)

        assertFailsWith<RedemptionRequiresCost> {
            points.decide(dom, dynamicId, redemptionId, approve = true, note = null, costOverride = null)
        }

        points.decide(dom, dynamicId, redemptionId, approve = true, note = null, costOverride = 3)
        assertEquals(7, points.balanceOf(dynamicId, sub))
    }

    @Test
    fun `the existing instant redeem path still works for a priced reward`() {
        val r = points.addReward(dom, dynamicId, "Coffee", null, 2)
        points.adjust(dom, dynamicId, sub, 5, null)
        points.redeem(sub, dynamicId, r)
        assertEquals(3, points.balanceOf(dynamicId, sub))
    }

    @Test
    fun `redeem() refuses a D-decided reward - the s path for those is request()`() {
        val r = points.addReward(dom, dynamicId, "Surprise", null, null)
        points.adjust(dom, dynamicId, sub, 5, null)
        assertFailsWith<RedemptionRequiresCost> { points.redeem(sub, dynamicId, r) }
    }

    @Test
    fun `fulfill moves an approved redemption to fulfilled`() {
        val r = points.addReward(dom, dynamicId, "Movie night", null, 5)
        points.adjust(dom, dynamicId, sub, 10, null)
        val redemptionId = points.request(sub, dynamicId, r, null)
        points.decide(dom, dynamicId, redemptionId, approve = true, note = null)

        points.fulfill(sub, dynamicId, redemptionId)

        assertEquals(
            "fulfilled",
            dsl.fetchOne("SELECT status FROM reward_redemptions WHERE id={0}", redemptionId)!!.get("status", String::class.java),
        )
    }

    @Test
    fun `redemptions are visible to both sides`() {
        val r = points.addReward(dom, dynamicId, "Movie night", null, 5)
        points.adjust(dom, dynamicId, sub, 10, null)
        val redemptionId = points.request(sub, dynamicId, r, null)

        assertEquals(1, points.redemptions(dom, dynamicId).size)
        assertEquals(1, points.redemptions(sub, dynamicId).size)
        assertEquals(1, points.redemptions(dom, dynamicId, status = "requested").size)
        assertEquals(0, points.redemptions(dom, dynamicId, status = "approved").size)
    }

    @Test
    fun `every ledger deduction has an actor - the schema-level guarantee holds through the request flow`() {
        val r = points.addReward(dom, dynamicId, "Movie night", null, 5)
        points.adjust(dom, dynamicId, sub, 10, null)
        val redemptionId = points.request(sub, dynamicId, r, null)
        points.decide(dom, dynamicId, redemptionId, approve = true, note = null)

        val negatives = dsl.fetch(
            "SELECT actor_user_id FROM point_entries WHERE dynamic_id={0} AND amount < 0", dynamicId,
        )
        assertEquals(1, negatives.size)
        assertNotNull(negatives[0].get("actor_user_id", UUID::class.java))
    }

    @Test
    fun `points rules lists only active tasks that pay`() {
        dsl.query(
            """INSERT INTO tasks (id,dynamic_id,title,kind,schedule,points_earn,created_by,status)
               VALUES ({0},{1},'Pays','recurring','{"type":"daily"}'::jsonb,3,{2},'active')""",
            UUID.randomUUID(), dynamicId, dom,
        ).execute()
        dsl.query(
            """INSERT INTO tasks (id,dynamic_id,title,kind,schedule,points_earn,created_by,status)
               VALUES ({0},{1},'Base',  'recurring','{"type":"daily"}'::jsonb,0,{2},'active')""",
            UUID.randomUUID(), dynamicId, dom,
        ).execute()
        dsl.query(
            """INSERT INTO tasks (id,dynamic_id,title,kind,schedule,points_earn,created_by,status)
               VALUES ({0},{1},'Archived pays','recurring','{"type":"daily"}'::jsonb,4,{2},'archived')""",
            UUID.randomUUID(), dynamicId, dom,
        ).execute()

        val ruleList = points.pointsRules(sub, dynamicId)
        assertEquals(listOf("Pays"), ruleList.map { it.title })
    }
}
