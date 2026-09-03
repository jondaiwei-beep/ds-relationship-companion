package com.dsapp.backend.activation

import com.dsapp.backend.activation.application.StarterRhythmService
import com.dsapp.backend.dynamic.application.DynamicQueryService
import com.dsapp.backend.expectation.application.OccurrenceGenerator
import com.dsapp.backend.expectation.application.OverdueSweeper
import com.dsapp.backend.response.application.AdjustmentService
import com.dsapp.backend.response.application.AdjustmentType
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.time.Instant
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertTrue

/** Starter Rhythm (Notion 02 §A3, 05 §4) and the overdue sweep. */
@SpringBootTest
@ActiveProfiles("test")
class StarterRhythmAndOverdueIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var starter: StarterRhythmService
    @Autowired lateinit var generator: OccurrenceGenerator
    @Autowired lateinit var sweeper: OverdueSweeper
    @Autowired lateinit var adjustments: AdjustmentService
    @Autowired lateinit var dynamics: DynamicQueryService

    private lateinit var creator: UUID
    private lateinit var partner: UUID
    private lateinit var dynamicId: UUID

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
        creator = UUID.randomUUID(); partner = UUID.randomUUID(); dynamicId = UUID.randomUUID()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Alex')", creator, "$creator@t").execute()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Jamie')", partner, "$partner@t").execute()
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','SERVICE','LIGHT','ACTIVE','America/New_York')""", dynamicId,
        ).execute()
        for ((u, r) in listOf(creator to "CREATOR", partner to "PARTNER")) {
            dsl.query(
                "INSERT INTO memberships (user_id,dynamic_id,role_context,access_state) VALUES ({0},{1},{2},'ACTIVE')",
                u, dynamicId, r,
            ).execute()
        }
    }

    // ---- Starter Rhythm ----

    @Test
    fun `the default rhythm is exactly 1 Ritual + 1 Expectation`() {
        starter.start(creator, dynamicId, assigneeUserId = partner)

        val kinds = dsl.fetch(
            "SELECT kind FROM expectation_definitions WHERE dynamic_id={0}", dynamicId,
        ).map { it.get("kind", String::class.java) }

        // Notion 05 §4: the first day must not arrive already full.
        assertEquals(1, kinds.count { it == "RITUAL" })
        assertEquals(1, kinds.count { it == "TASK" })
    }

    @Test
    fun `an apart couple is seeded content that works across timezones`() {
        // LDR is the design pressure case named in 00-overview, the wizard has
        // always asked the question, and until now the answer was dropped
        // before the request was sent. "Have it ready before they arrive"
        // assumes a shared room; offered to a couple in different timezones it
        // reads as written for somebody else.
        dsl.query(
            "UPDATE dynamics SET long_distance = true WHERE id = {0}", dynamicId,
        ).execute()

        val p = starter.propose(creator, dynamicId)

        assertEquals("Say goodnight to the timezone you are not in", p.expectationTitle)
        assertEquals("One hour you both keep", p.ritualTitle)
    }

    @Test
    fun `a couple who live together are unaffected by the distance content`() {
        // The column defaults to false, so every dynamic that existed before
        // the flag keeps the rhythm it would have had.
        val p = starter.propose(creator, dynamicId)

        assertEquals("Have it ready before they arrive", p.expectationTitle)
    }

    @Test
    fun `the second Expectation is opt-in, never a default`() {
        starter.start(creator, dynamicId, assigneeUserId = partner, includeSecondExpectation = true)

        val tasks = dsl.fetchOne(
            "SELECT count(*) AS n FROM expectation_definitions WHERE dynamic_id={0} AND kind='TASK'",
            dynamicId,
        )!!.get("n", Int::class.java)
        assertEquals(2, tasks)
    }

    @Test
    fun `the proposal matches the desired outcome and is not yet written`() {
        val p = starter.propose(creator, dynamicId)

        // SERVICE was chosen in setup.
        assertEquals("Have it ready before they arrive", p.expectationTitle)
        assertTrue(p.checkInFraming.isNotBlank())
        // Nothing persisted by proposing.
        assertEquals(0, dsl.fetchOne(
            "SELECT count(*) AS n FROM expectation_definitions WHERE dynamic_id={0}", dynamicId,
        )!!.get("n", Int::class.java))
    }

    @Test
    fun `the creator can replace any title before starting`() {
        starter.start(creator, dynamicId, assigneeUserId = partner,
            ritualTitle = "Our own evening thing")

        val title = dsl.fetchOne(
            "SELECT title FROM expectation_definitions WHERE dynamic_id={0} AND kind='RITUAL'",
            dynamicId,
        )!!.get("title", String::class.java)
        // "Keep what feels right. Replace anything that doesn't."
        assertEquals("Our own evening thing", title)
    }

    @Test
    fun `starting twice is refused - a double tap cannot create two rhythms`() {
        starter.start(creator, dynamicId, assigneeUserId = partner)
        assertFailsWith<IllegalStateException> {
            starter.start(creator, dynamicId, assigneeUserId = partner)
        }
    }

    @Test
    fun `the ritual recurs daily in the dynamic's own timezone`() {
        starter.start(creator, dynamicId, assigneeUserId = partner)

        val r = dsl.fetchOne(
            """SELECT frequency, timezone FROM expectation_recurrences r
                 JOIN expectation_definitions d ON d.id = r.definition_id
                WHERE d.dynamic_id = {0}""",
            dynamicId,
        )!!
        assertEquals("DAILY", r.get("frequency", String::class.java))
        assertEquals("America/New_York", r.get("timezone", String::class.java))
    }

    @Test
    fun `no starter content mentions punishment, proof or points`() {
        starter.start(creator, dynamicId, assigneeUserId = partner, includeSecondExpectation = true)

        val text = dsl.fetch(
            "SELECT title, purpose FROM expectation_definitions WHERE dynamic_id={0}", dynamicId,
        ).joinToString(" ") {
            "${it.get("title", String::class.java)} ${it.get("purpose", String::class.java)}"
        }.lowercase()

        // Notion 05 §4: the first day must not teach the couple that this app
        // is about scoring each other.
        for (banned in listOf("punish", "proof", "point", "score", "streak", "obey", "fail")) {
            assertTrue(!text.contains(banned), "starter content contains \"$banned\"")
        }
    }

    // ---- overdue sweep ----

    private fun overdueOccurrence(): UUID {
        val defId = UUID.randomUUID(); val occId = UUID.randomUUID()
        dsl.query(
            """INSERT INTO expectation_definitions
                 (id,dynamic_id,kind,title,creator_user_id,assignee_user_id,visibility)
               VALUES ({0},{1},'TASK','Something',{2},{3},'SHARED')""",
            defId, dynamicId, creator, partner,
        ).execute()
        dsl.query(
            """INSERT INTO occurrences (id,definition_id,dynamic_id,state,relationship_day,due_at)
               VALUES ({0},{1},{2},'ACTIVE',CURRENT_DATE, now() - interval '2 hours')""",
            occId, defId, dynamicId,
        ).execute()
        return occId
    }

    private fun stateOf(id: UUID) =
        dsl.fetchOne("SELECT state FROM occurrences WHERE id={0}", id)!!.get("state", String::class.java)

    @Test
    fun `overdue leads to NEEDS_REVIEW and nothing worse`() {
        val occ = overdueOccurrence()
        sweeper.sweep()

        // Invariant: this is the ONLY destination for an overdue occurrence.
        assertEquals("NEEDS_REVIEW", stateOf(occ))
    }

    @Test
    fun `the sweep queues NO notification - lateness is never nagged about`() {
        overdueOccurrence()
        sweeper.sweep()

        val queued = dsl.fetchOne(
            "SELECT count(*) AS n FROM outbox_records WHERE dynamic_id={0}", dynamicId,
        )!!.get("n", Int::class.java)
        assertEquals(0, queued, "being chased about lateness is exactly what this product refuses")
    }

    @Test
    fun `someone waiting on an adjustment is NEVER marked overdue`() {
        val occ = overdueOccurrence()
        adjustments.request(partner, occ, AdjustmentType.CANT_DO,
            "I'm ill today.", idempotencyId = idem(partner))

        sweeper.sweep()

        // Saying "I can't right now" and then being marked as having let the
        // time run out would turn honesty into a penalty.
        assertEquals("EXCUSE_REQUESTED", stateOf(occ))
    }

    @Test
    fun `nothing goes overdue while the dynamic is paused`() {
        val occ = overdueOccurrence()
        dynamics.pause(partner, dynamicId)

        sweeper.sweep()
        assertEquals("ACTIVE", stateOf(occ))
    }

    @Test
    fun `the sweep is idempotent`() {
        val occ = overdueOccurrence()
        assertEquals(1, sweeper.sweep())
        assertEquals(0, sweeper.sweep(), "an already-reviewed occurrence is not swept again")
        assertEquals("NEEDS_REVIEW", stateOf(occ))
    }

    @Test
    fun `the overdue event has no actor - nobody did this, time simply passed`() {
        overdueOccurrence()
        sweeper.sweep()

        val actor = dsl.fetchOne(
            """SELECT actor_user_id FROM relationship_events
                WHERE dynamic_id={0} AND event_type='occurrence_needs_review'""",
            dynamicId,
        )!!.get("actor_user_id", UUID::class.java)
        assertTrue(actor == null, "attributing lateness to a person would make it an accusation")
    }
}
