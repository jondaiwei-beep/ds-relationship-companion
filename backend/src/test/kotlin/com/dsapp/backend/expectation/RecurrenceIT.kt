package com.dsapp.backend.expectation

import com.dsapp.backend.dynamic.application.DynamicQueryService
import com.dsapp.backend.expectation.application.OccurrenceGenerator
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** Ritual recurrence + Check-in — Notion 02 §A3, 03 §2, Journey E. */
@SpringBootTest
@ActiveProfiles("test")
class RecurrenceIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var generator: OccurrenceGenerator
    @Autowired lateinit var dynamics: DynamicQueryService

    private lateinit var creator: UUID
    private lateinit var partner: UUID
    private lateinit var dynamicId: UUID
    private lateinit var definitionId: UUID

    @BeforeEach
    fun seed() {
        creator = UUID.randomUUID(); partner = UUID.randomUUID()
        dynamicId = UUID.randomUUID(); definitionId = UUID.randomUUID()

        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Alex')", creator, "$creator@t").execute()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Jamie')", partner, "$partner@t").execute()
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,
                                     reference_timezone,day_boundary_minutes)
               VALUES ({0},'COUPLE','CLOSER','LIGHT','ACTIVE','America/New_York',240)""", dynamicId,
        ).execute()
        for ((u, r) in listOf(creator to "CREATOR", partner to "PARTNER")) {
            dsl.query(
                "INSERT INTO memberships (user_id,dynamic_id,role_context,access_state) VALUES ({0},{1},{2},'ACTIVE')",
                u, dynamicId, r,
            ).execute()
        }
        dsl.query(
            """INSERT INTO expectation_definitions
                 (id,dynamic_id,kind,title,creator_user_id,assignee_user_id,visibility)
               VALUES ({0},{1},'RITUAL','Evening check-in',{2},{3},'SHARED')""",
            definitionId, dynamicId, creator, partner,
        ).execute()
    }

    private fun recurrence(freq: String = "DAILY", weekday: Int? = null, time: String = "20:30"): UUID {
        val id = UUID.randomUUID()
        dsl.query(
            """INSERT INTO expectation_recurrences
                 (id,definition_id,frequency,weekday,local_time,timezone)
               VALUES ({0},{1},{2},{3},CAST({4} AS time),'America/New_York')""",
            id, definitionId, freq, weekday, time,
        ).execute()
        return id
    }

    private fun occurrenceCount(): Int =
        dsl.fetchOne("SELECT count(*) AS n FROM occurrences WHERE dynamic_id={0}", dynamicId)!!
            .get("n", Int::class.java)

    // ---- recurrence ----

    @Test
    fun `a daily ritual generates one occurrence for the day`() {
        recurrence()
        val made = generator.generateFor(dynamicId, LocalDate.of(2026, 6, 15))

        assertEquals(1, made.size)
        assertEquals(1, occurrenceCount())
    }

    @Test
    fun `generation is IDEMPOTENT - running twice does not duplicate`() {
        recurrence()
        val day = LocalDate.of(2026, 6, 15)
        generator.generateFor(dynamicId, day)
        generator.generateFor(dynamicId, day)

        assertEquals(1, occurrenceCount(), "a second run must be a no-op, not a duplicate")
    }

    @Test
    fun `generation stays idempotent even after the occurrence is terminal`() {
        recurrence()
        val day = LocalDate.of(2026, 6, 15)
        generator.generateFor(dynamicId, day)
        // The older partial index only covers NON-terminal rows, so this is
        // exactly where a duplicate could sneak in.
        dsl.query("UPDATE occurrences SET state='ACKNOWLEDGED' WHERE dynamic_id={0}", dynamicId).execute()

        generator.generateFor(dynamicId, day)
        assertEquals(1, occurrenceCount())
    }

    @Test
    fun `a weekly ritual only fires on its weekday`() {
        recurrence(freq = "WEEKLY", weekday = 1)   // Monday

        assertEquals(1, generator.generateFor(dynamicId, LocalDate.of(2026, 6, 15)).size) // Mon
        assertEquals(0, generator.generateFor(dynamicId, LocalDate.of(2026, 6, 16)).size) // Tue
    }

    @Test
    fun `a paused dynamic generates NOTHING`() {
        recurrence()
        dynamics.pause(partner, dynamicId)

        assertEquals(0, generator.generateFor(dynamicId, LocalDate.of(2026, 6, 15)).size)
        assertEquals(0, occurrenceCount())
    }

    @Test
    fun `RESUME creates no backlog - paused days are never back-filled`() {
        val rec = recurrence()
        dynamics.pause(partner, dynamicId)
        dynamics.resume(partner, dynamicId)

        // Resume advanced the barrier to today, so historical days are simply
        // not eligible however generation is invoked.
        val barrier = dsl.fetchOne(
            "SELECT eligible_from_day FROM expectation_recurrences WHERE id={0}", rec,
        )!!.get("eligible_from_day", LocalDate::class.java)

        assertTrue(barrier != null, "resume must set the generation barrier")
        // Try to back-fill a week of paused days: nothing may appear.
        for (d in 1..7) {
            generator.generateFor(dynamicId, barrier!!.minusDays(d.toLong()))
        }
        assertEquals(0, occurrenceCount(),
            "returning must never mean facing a pile of work you 'owe' (Journey E)")
    }

    @Test
    fun `due_at respects the day boundary - the wrong-day trap`() {
        // A 02:00 ritual with a 04:00 day boundary belongs to the relationship
        // day that STARTED the previous civil date, so its instant is on the
        // FOLLOWING civil date. Getting this wrong is the S1 defect.
        recurrence(time = "02:00")
        val day = LocalDate.of(2026, 6, 15)
        generator.generateFor(dynamicId, day)

        val dueAt = dsl.fetchOne(
            "SELECT due_at FROM occurrences WHERE dynamic_id={0}", dynamicId,
        )!!.get("due_at", Instant::class.java)

        val ny = ZoneId.of("America/New_York")
        assertEquals(LocalDate.of(2026, 6, 16), dueAt.atZone(ny).toLocalDate(),
            "a 02:00 ritual on relationship day 06-15 fires on civil date 06-16")
        assertEquals(2, dueAt.atZone(ny).hour)
    }

    // ---- check-in ----
}
