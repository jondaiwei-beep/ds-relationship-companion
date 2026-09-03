package com.dsapp.backend.today

import com.dsapp.backend.dynamic.domain.AuthorizationException
import com.dsapp.backend.points.application.PointsService
import com.dsapp.backend.today.application.DayCloser
import com.dsapp.backend.today.application.DispositionService
import com.dsapp.backend.today.application.DynamicDays
import com.dsapp.backend.today.application.OccurrenceGenerator
import com.dsapp.backend.today.application.OccurrenceNotActionable
import com.dsapp.backend.today.application.OutcomeService
import com.dsapp.backend.today.application.TaskService
import com.dsapp.backend.today.application.TodayQueryService
import com.dsapp.backend.today.domain.Disposition
import com.dsapp.backend.today.domain.Outcome
import com.dsapp.backend.today.domain.TaskKind
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.time.temporal.ChronoUnit
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * The 今天 loop (product/03-domain.md invariants). Two people, one dynamic:
 * the s side delivers, the D side disposes, and neither axis is ever moved
 * by the software except the day-end `missed` mark.
 */
@SpringBootTest
@ActiveProfiles("test")
class TodayIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var tasks: TaskService
    @Autowired lateinit var generator: OccurrenceGenerator
    @Autowired lateinit var closer: DayCloser
    @Autowired lateinit var outcomes: OutcomeService
    @Autowired lateinit var dispositions: DispositionService
    @Autowired lateinit var query: TodayQueryService
    @Autowired lateinit var days: DynamicDays
    @Autowired lateinit var points: PointsService

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

    private val today: LocalDate get() = days.today(dyn)

    private fun daily(title: String, pointsEarn: Int = 0, dueTime: LocalTime? = null) =
        tasks.create(d, dyn, TaskService.NewTask(title = title, pointsEarn = pointsEarn, dueTime = dueTime))

    private fun onlyOccurrence(taskId: UUID): UUID = dsl.fetchOne(
        "SELECT id FROM occurrences WHERE task_id={0} AND day={1}", taskId, today,
    )!!.get("id", UUID::class.java)

    private fun col(occ: UUID, c: String): String? =
        dsl.fetchOne("SELECT $c AS v FROM occurrences WHERE id={0}", occ)!!.get("v")?.toString()

    private fun history(occ: UUID) = dsl.fetch(
        "SELECT axis, from_value, to_value, by_user_id FROM occurrence_history WHERE occurrence_id={0} ORDER BY at", occ,
    ).map { Triple(it.get("axis", String::class.java), it.get("to_value", String::class.java), it.get("by_user_id", UUID::class.java)) }

    // ---- generation --------------------------------------------------------

    @Test
    fun `creating a task materialises today once, and generation is idempotent`() {
        val t = daily("Morning greeting")
        assertEquals(1, dsl.fetchOne("SELECT count(*) AS n FROM occurrences WHERE task_id={0}", t.id)!!.get("n", Int::class.java))
        generator.generate(dyn, today); generator.generate(dyn, today)
        assertEquals(1, dsl.fetchOne("SELECT count(*) AS n FROM occurrences WHERE task_id={0}", t.id)!!.get("n", Int::class.java))
    }

    @Test
    fun `weekday schedules skip days they do not name`() {
        val monday = LocalDate.of(2026, 9, 7)
        tasks.create(d, dyn, TaskService.NewTask(title = "Gym", schedule = mapOf("type" to "weekdays", "days" to listOf(1, 3))))
        val gym = dsl.fetchOne("SELECT id FROM tasks WHERE dynamic_id={0} AND title='Gym'", dyn)!!.get("id", UUID::class.java)
        dsl.query("DELETE FROM occurrences WHERE task_id={0}", gym).execute()
        generator.generate(dyn, monday)
        generator.generate(dyn, monday.plusDays(1))
        generator.generate(dyn, monday.plusDays(2))
        val days = dsl.fetch("SELECT day FROM occurrences WHERE task_id={0} ORDER BY day", gym).map { it.get("day", LocalDate::class.java) }
        assertEquals(listOf(monday, monday.plusDays(2)), days)
    }

    @Test
    fun `the day end only writes the outcome axis, and signs as nobody`() {
        val t = daily("Evening report")
        val yesterday = today.minusDays(1)
        dsl.query("DELETE FROM occurrences WHERE task_id={0}", t.id).execute()
        generator.generate(dyn, yesterday)
        val occ = dsl.fetchOne("SELECT id FROM occurrences WHERE task_id={0}", t.id)!!.get("id", UUID::class.java)

        assertEquals(1, closer.closeBefore(dyn, today))
        assertEquals("missed", col(occ, "outcome"))
        assertEquals("none", col(occ, "disposition"), "the software never disposes")
        assertEquals(listOf(Triple("outcome", "missed", null as UUID?)), history(occ))
        assertEquals(0, closer.closeBefore(dyn, today), "closing is idempotent")
    }

    // ---- the s axis ----------------------------------------------------------

    @Test
    fun `only the s side sets an outcome, only the D side a disposition`() {
        val occ = onlyOccurrence(daily("Greeting").id)
        assertFailsWith<AuthorizationException.WrongSide> { outcomes.set(d, occ, OutcomeService.Change(Outcome.delivered)) }
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered))
        assertFailsWith<AuthorizationException.WrongSide> { dispositions.set(s, occ, DispositionService.Change(Disposition.praised)) }
        dispositions.set(d, occ, DispositionService.Change(Disposition.praised))
    }

    @Test
    fun `delivering after the due time is recorded as late, not refused`() {
        val occ = onlyOccurrence(daily("Greeting", dueTime = LocalTime.of(8, 0)).id)
        val dueAt = dsl.fetchOne("SELECT due_at FROM occurrences WHERE id={0}", occ)!!.get("due_at", java.time.OffsetDateTime::class.java).toInstant()
        val r = outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered), now = dueAt.plus(2, ChronoUnit.HOURS))
        assertEquals("delivered_late", r.outcome)
    }

    @Test
    fun `an s can withdraw, and the trail keeps both moves`() {
        val occ = onlyOccurrence(daily("Greeting", pointsEarn = 5).id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered))
        assertEquals(5, points.balanceOf(dyn, s))

        outcomes.set(s, occ, OutcomeService.Change(Outcome.open))
        assertEquals("open", col(occ, "outcome"))
        assertEquals(0, points.balanceOf(dyn, s), "withdrawing gives the points back")
        assertEquals(listOf("delivered", "open"), history(occ).map { it.second })
        // the reversal is the s's own act, so it names them
        val actors = dsl.fetch("SELECT actor_user_id FROM point_entries WHERE occurrence_id={0} ORDER BY created_at", occ)
            .map { it.get("actor_user_id", UUID::class.java) }
        assertEquals(listOf(null, s), actors)
    }

    @Test
    fun `points are credited once, however many times the s re-delivers`() {
        val occ = onlyOccurrence(daily("Greeting", pointsEarn = 3).id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered))
        outcomes.set(s, occ, OutcomeService.Change(Outcome.cant_do, note = "actually, no"))
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered))
        assertEquals(3, points.balanceOf(dyn, s))
    }

    @Test
    fun `once the D has answered, the s side is closed for edits`() {
        val occ = onlyOccurrence(daily("Greeting").id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered))
        dispositions.set(d, occ, DispositionService.Change(Disposition.praised))
        val e = assertFailsWith<OccurrenceNotActionable> { outcomes.set(s, occ, OutcomeService.Change(Outcome.open)) }
        assertEquals("OCCURRENCE_DISPOSED", e.code)
    }

    // ---- the D axis ----------------------------------------------------------

    @Test
    fun `a disposition never expires - weeks later still counts`() {
        val t = daily("Greeting")
        dsl.query("DELETE FROM occurrences WHERE task_id={0}", t.id).execute()
        val old = today.minusDays(21)
        generator.generate(dyn, old)
        closer.closeBefore(dyn, today)
        val occ = dsl.fetchOne("SELECT id FROM occurrences WHERE task_id={0}", t.id)!!.get("id", UUID::class.java)
        assertEquals("missed", col(occ, "outcome"))

        val r = dispositions.set(d, occ, DispositionService.Change(Disposition.let_go, note = "you were ill"))
        assertEquals("let_go", r.disposition)
        assertTrue(query.needsMe(d, dyn).none { it.id == occ }, "answered things leave the D's list")
    }

    @Test
    fun `punished always carries a consequence issued by the D`() {
        val occ = onlyOccurrence(daily("Greeting").id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.cant_do))

        assertFailsWith<IllegalArgumentException> { dispositions.set(d, occ, DispositionService.Change(Disposition.punished)) }

        val r = dispositions.set(
            d, occ,
            DispositionService.Change(Disposition.punished, consequence = DispositionService.NewConsequence(title = "Early bedtime")),
        )
        val issuedBy = dsl.fetchOne("SELECT issued_by FROM consequences WHERE id={0}", r.consequenceId)!!.get("issued_by", UUID::class.java)
        assertEquals(d, issuedBy)
    }

    @Test
    fun `make up creates the owed occurrence on the named day`() {
        val occ = onlyOccurrence(daily("Greeting").id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.cant_do))
        val tomorrow = today.plusDays(1)
        val r = dispositions.set(d, occ, DispositionService.Change(Disposition.make_up, makeUpDay = tomorrow))
        val owed = assertNotNull(r.makeUpOccurrenceId)
        assertEquals(tomorrow.toString(), col(owed, "day"))
        assertEquals(occ.toString(), col(owed, "make_up_of"))
    }

    @Test
    fun `the D cannot dispose of something still open - there is nothing to answer yet`() {
        val occ = onlyOccurrence(daily("Greeting").id)
        val e = assertFailsWith<OccurrenceNotActionable> { dispositions.set(d, occ, DispositionService.Change(Disposition.praised)) }
        assertEquals("OCCURRENCE_OPEN", e.code)
    }

    @Test
    fun `seen is a receipt the s can read, separate from the answer`() {
        val occ = onlyOccurrence(daily("Greeting").id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered))
        assertNull(query.occurrence(s, occ).seenAt)
        dispositions.markSeen(d, occ)
        val view = query.occurrence(s, occ)
        assertNotNull(view.seenAt)
        assertEquals("none", view.disposition, "a receipt is not a disposition")
    }

    // ---- pause = no debt -------------------------------------------------------

    @Test
    fun `a paused task produces nothing to miss`() {
        val t = daily("Gym")
        val occ = onlyOccurrence(t.id)
        tasks.pause(d, dyn, t.id, until = Instant.now().plus(3, ChronoUnit.DAYS))
        assertEquals("paused", col(occ, "outcome"))
        assertEquals(0, closer.closeBefore(dyn, today.plusDays(1)), "paused is not open, so it cannot be missed")
        assertFailsWith<OccurrenceNotActionable> { outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered)) }
        assertFailsWith<OccurrenceNotActionable> { dispositions.set(d, occ, DispositionService.Change(Disposition.let_go)) }
    }

    // ---- proposals, open tasks, and what each side sees --------------------------

    @Test
    fun `an s proposal waits for the D to accept before it is scheduled`() {
        val t = tasks.create(s, dyn, TaskService.NewTask(title = "Let me cook on Fridays"))
        assertEquals("proposed", t.status)
        assertEquals(0, dsl.fetchOne("SELECT count(*) AS n FROM occurrences WHERE task_id={0}", t.id)!!.get("n", Int::class.java))
        tasks.accept(d, dyn, t.id)
        assertEquals(1, dsl.fetchOne("SELECT count(*) AS n FROM occurrences WHERE task_id={0}", t.id)!!.get("n", Int::class.java))
    }

    @Test
    fun `an open task has no occurrence until the s delivers one`() {
        val t = tasks.create(d, dyn, TaskService.NewTask(title = "Write me a letter", kind = TaskKind.open, pointsEarn = 10))
        assertEquals(0, dsl.fetchOne("SELECT count(*) AS n FROM occurrences WHERE task_id={0}", t.id)!!.get("n", Int::class.java))
        assertTrue(query.today(s, dyn).openTasks.any { it.id == t.id })
        val r = outcomes.deliverOpen(s, dyn, t.id, note = "in the drawer", proofKind = null, proofRef = null)
        assertEquals("delivered", r.outcome)
        assertEquals(10, points.balanceOf(dyn, s))
    }

    @Test
    fun `today reads differently from each side`() {
        val occ = onlyOccurrence(daily("Greeting").id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered))
        val forD = query.today(d, dyn)
        val forS = query.today(s, dyn)
        assertEquals("D", forD.side); assertEquals("S", forS.side)
        assertEquals(1, forD.needsMe, "one thing waits for the D")
        assertEquals("Jamie", forD.partnerDisplayName)
        assertEquals("Alex", forS.partnerDisplayName)
        assertEquals(1, forS.items.size)
    }

    @Test
    fun `each move on either axis leaves an outbox record for the other side`() {
        val occ = onlyOccurrence(daily("Greeting").id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered))
        dispositions.set(d, occ, DispositionService.Change(Disposition.praised))
        val types = dsl.fetch("SELECT event_type FROM outbox_records WHERE aggregate_id={0} ORDER BY created_at", occ)
            .map { it.get("event_type", String::class.java) }
        assertEquals(listOf("occurrence_delivered", "disposition_set"), types)
    }
}
