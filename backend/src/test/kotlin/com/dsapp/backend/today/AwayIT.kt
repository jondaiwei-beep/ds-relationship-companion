package com.dsapp.backend.today

import com.dsapp.backend.today.application.AwayService
import com.dsapp.backend.today.application.DynamicDays
import com.dsapp.backend.today.application.OccurrenceGenerator
import com.dsapp.backend.today.application.TaskService
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.time.Instant
import java.time.temporal.ChronoUnit
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertNull

/**
 * D「我不在」— product/03-domain.md, D-26. One key pauses every task that
 * `requires_d_present`; `back` restores only what this away-window paused,
 * so no debt piles up while the D is out and a hand-set per-task pause
 * survives coming back.
 */
@SpringBootTest
@ActiveProfiles("test")
class AwayIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var tasks: TaskService
    @Autowired lateinit var away: AwayService
    @Autowired lateinit var generator: OccurrenceGenerator
    @Autowired lateinit var days: DynamicDays

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

    private fun outcomeOf(taskId: UUID): String = dsl.fetchOne(
        "SELECT outcome FROM occurrences WHERE task_id={0} AND day={1}", taskId, days.today(dyn),
    )!!.get("outcome", String::class.java)

    @Test
    fun `away pauses only tasks that require the D present`() {
        val needsD = tasks.create(d, dyn, TaskService.NewTask(title = "Kneel at the door", requiresDPresent = true))
        val onOwn = tasks.create(d, dyn, TaskService.NewTask(title = "Journal", requiresDPresent = false))

        val until = Instant.now().plus(14, ChronoUnit.DAYS)
        away.away(d, dyn, until)

        assertEquals("paused", outcomeOf(needsD.id))
        assertEquals("open", outcomeOf(onOwn.id))
        assertEquals(until, dsl.fetchOne("SELECT d_away_until FROM dynamics WHERE id={0}", dyn)!!.get("d_away_until", Instant::class.java))
        assertEquals(until, dsl.fetchOne("SELECT paused_until FROM tasks WHERE id={0}", needsD.id)!!.get("paused_until", Instant::class.java))
    }

    @Test
    fun `back restores only the tasks this away-window paused`() {
        val needsD = tasks.create(d, dyn, TaskService.NewTask(title = "Kneel at the door", requiresDPresent = true))
        val until = Instant.now().plus(14, ChronoUnit.DAYS)
        away.away(d, dyn, until)

        away.back(d, dyn)

        assertEquals("open", outcomeOf(needsD.id))
        assertNull(dsl.fetchOne("SELECT paused_until FROM tasks WHERE id={0}", needsD.id)!!.get("paused_until", Instant::class.java))
        assertNull(dsl.fetchOne("SELECT d_away_until FROM dynamics WHERE id={0}", dyn)!!.get("d_away_until", Instant::class.java))
    }

    @Test
    fun `a hand-set per-task pause survives back - only away's own pauses are cleared`() {
        val needsD = tasks.create(d, dyn, TaskService.NewTask(title = "Kneel at the door", requiresDPresent = true))
        val handSet = Instant.now().plus(365, ChronoUnit.DAYS)
        tasks.pause(d, dyn, needsD.id, handSet)

        val awayUntil = Instant.now().plus(14, ChronoUnit.DAYS)
        away.away(d, dyn, awayUntil)
        // away() overwrote the hand-set pause with its own value...
        assertEquals(awayUntil, dsl.fetchOne("SELECT paused_until FROM tasks WHERE id={0}", needsD.id)!!.get("paused_until", Instant::class.java))

        away.back(d, dyn)
        // ...so back() DOES clear it, since paused_until now equals the away value.
        assertNull(dsl.fetchOne("SELECT paused_until FROM tasks WHERE id={0}", needsD.id)!!.get("paused_until", Instant::class.java))
    }

    @Test
    fun `a task paused by hand to a DIFFERENT value than the current away window is left alone by back`() {
        val needsD = tasks.create(d, dyn, TaskService.NewTask(title = "Kneel at the door", requiresDPresent = true))
        val awayUntil = Instant.now().plus(14, ChronoUnit.DAYS)
        away.away(d, dyn, awayUntil)

        // The D re-paused this one task by hand, to a different date, after
        // going away — a deliberate, separate decision.
        val handSet = Instant.now().plus(365, ChronoUnit.DAYS)
        tasks.pause(d, dyn, needsD.id, handSet)

        away.back(d, dyn)

        assertEquals(handSet, dsl.fetchOne("SELECT paused_until FROM tasks WHERE id={0}", needsD.id)!!.get("paused_until", Instant::class.java))
        assertNull(dsl.fetchOne("SELECT d_away_until FROM dynamics WHERE id={0}", dyn)!!.get("d_away_until", Instant::class.java))
    }
}
