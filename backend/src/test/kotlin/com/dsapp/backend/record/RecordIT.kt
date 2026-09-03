package com.dsapp.backend.record

import com.dsapp.backend.record.application.DayCommentService
import com.dsapp.backend.record.application.PrivateNoteService
import com.dsapp.backend.record.application.RecordQueryService
import com.dsapp.backend.today.application.DayCloser
import com.dsapp.backend.today.application.DispositionService
import com.dsapp.backend.today.application.DynamicDays
import com.dsapp.backend.today.application.NoSuchItem
import com.dsapp.backend.today.application.OccurrenceGenerator
import com.dsapp.backend.today.application.OutcomeService
import com.dsapp.backend.today.application.TaskService
import com.dsapp.backend.today.domain.Disposition
import com.dsapp.backend.today.domain.Outcome
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.time.Instant
import java.time.LocalDate
import java.time.YearMonth
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * 记录 (product/02-surfaces.md Tab 3, product/03-domain.md). The evening
 * script two people run through together — the day's calendar cell, the
 * timeline, comments either side can leave, and the private note that never
 * crosses to the other person.
 */
@SpringBootTest
@ActiveProfiles("test")
class RecordIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var tasks: TaskService
    @Autowired lateinit var generator: OccurrenceGenerator
    @Autowired lateinit var closer: DayCloser
    @Autowired lateinit var outcomes: OutcomeService
    @Autowired lateinit var dispositions: DispositionService
    @Autowired lateinit var days: DynamicDays
    @Autowired lateinit var record: RecordQueryService
    @Autowired lateinit var comments: DayCommentService
    @Autowired lateinit var privateNotes: PrivateNoteService

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
        // Backdated well past the streak windows the tests below exercise, so
        // `RelationshipStreaks`'s relationship-start floor never clips them.
        for ((u, r, side) in listOf(Triple(d, "CREATOR", "D"), Triple(s, "PARTNER", "S"))) {
            dsl.query(
                "INSERT INTO memberships (user_id,dynamic_id,role_context,side,access_state,joined_at) VALUES ({0},{1},{2},{3},'ACTIVE',now() - interval '30 days')",
                u, dyn, r, side,
            ).execute()
        }
    }

    private val today: LocalDate get() = days.today(dyn)

    private fun daily(title: String, pointsEarn: Int = 0) =
        tasks.create(d, dyn, TaskService.NewTask(title = title, pointsEarn = pointsEarn))

    private fun onlyOccurrence(taskId: UUID, day: LocalDate = today): UUID = dsl.fetchOne(
        "SELECT id FROM occurrences WHERE task_id={0} AND day={1}", taskId, day,
    )!!.get("id", UUID::class.java)

    private fun generateOn(title: String, day: LocalDate, pointsEarn: Int = 0): UUID {
        val t = daily(title, pointsEarn)
        dsl.query("DELETE FROM occurrences WHERE task_id={0}", t.id).execute()
        generator.generate(dyn, day)
        return onlyOccurrence(t.id, day)
    }

    // ---- month cells ---------------------------------------------------------

    @Test
    fun `month cells count due, delivered, flagged and missed, and skip paused`() {
        val month = YearMonth.from(today)
        val running = daily("Running", pointsEarn = 1)
        val meditate = daily("Meditate")
        val occRunning = onlyOccurrence(running.id)
        val occMeditate = onlyOccurrence(meditate.id)

        // pause meditate for today: it must not count toward `due`.
        tasks.pause(d, dyn, meditate.id, until = Instant.now().plus(1, java.time.temporal.ChronoUnit.DAYS))
        outcomes.set(s, occRunning, OutcomeService.Change(Outcome.delivered))

        val cell = record.month(d, dyn, month).first { it.day == today }
        assertEquals(1, cell.due, "the paused one drops out of due")
        assertEquals(1, cell.delivered)
        assertEquals(0, cell.flagged)
        assertEquals(0, cell.missed)

        // Now a missed one, on yesterday. `generate` re-materialises every
        // active task for that day, so first pause the two already-created
        // ones off yesterday's generation to keep this cell isolated to the
        // one new task.
        val yesterday = today.minusDays(1)
        tasks.pause(d, dyn, running.id, until = Instant.now().plus(1, java.time.temporal.ChronoUnit.DAYS))
        val stretch = daily("Stretch")
        dsl.query("DELETE FROM occurrences WHERE task_id={0}", stretch.id).execute()
        generator.generate(dyn, yesterday)
        closer.closeBefore(dyn, today)

        val yesterdayCell = record.month(d, dyn, month).first { it.day == yesterday }
        assertEquals(1, yesterdayCell.missed)
        assertEquals(1, yesterdayCell.undisposed, "missed with disposition none is undisposed")
    }

    @Test
    fun `days with nothing at all return no cell`() {
        val month = YearMonth.from(today).minusMonths(2)
        assertTrue(record.month(d, dyn, month).isEmpty())
    }

    // ---- day timeline: order and privacy --------------------------------------

    @Test
    fun `the day timeline is sorted by time and includes outcome, disposition and comment entries`() {
        val occ = onlyOccurrence(daily("Greeting").id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered, note = "good morning"))
        dispositions.set(d, occ, DispositionService.Change(Disposition.praised, note = "lovely"))
        comments.add(s, dyn, today, "thank you")

        val view = record.day(s, dyn, today)
        assertEquals(listOf("outcome", "disposition", "comment"), view.timeline.map { it.kind })
        assertEquals("delivered", view.timeline[0].outcome!!.toValue)
        assertEquals("Greeting", view.timeline[0].outcome!!.taskTitle)
        assertEquals("praised", view.timeline[1].disposition!!.toValue)
        assertEquals("thank you", view.timeline[2].comment!!.body)
        assertEquals(1, view.comments.size)
    }

    @Test
    fun `a member's private note never appears for the other member, and DNotes never appear at all`() {
        val occ = onlyOccurrence(daily("Greeting").id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered))

        privateNotes.upsert(s, dyn, today, "I was nervous about this one")
        privateNotes.upsert(d, dyn, today, "remember to go easy tonight")

        val forS = record.day(s, dyn, today)
        val forD = record.day(d, dyn, today)
        assertEquals("I was nervous about this one", forS.myPrivateNote)
        assertEquals("remember to go easy tonight", forD.myPrivateNote)

        // Neither the API surface nor the timeline carries any trace of the
        // other person's note, and there is no `d_note` timeline kind at all.
        assertTrue(forS.timeline.none { it.kind == "d_note" })
        assertTrue(forD.timeline.none { it.kind == "d_note" })
    }

    @Test
    fun `points and redemptions in the day's relationship-day range show on the timeline`() {
        val occ = onlyOccurrence(daily("Greeting", pointsEarn = 4).id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered))

        val view = record.day(s, dyn, today)
        val points = view.timeline.filter { it.kind == "points" }
        assertEquals(1, points.size)
        assertEquals(4, points[0].points!!.amount)
        assertEquals("task_earn", points[0].points!!.reason)
    }

    // ---- comments: either side, delete own only -------------------------------

    @Test
    fun `either side may comment, but only the author may delete their own`() {
        val bySide = comments.add(s, dyn, today, "I am sorry about this morning")
        val byD = comments.add(d, dyn, today, "noted, we'll talk tonight")

        val view = record.day(d, dyn, today)
        assertEquals(setOf(s, d), view.comments.map { it.authorId }.toSet())

        assertFailsWith<NoSuchItem> { comments.delete(d, bySide.id) }
        comments.delete(s, bySide.id)

        val after = record.day(d, dyn, today)
        assertEquals(listOf(byD.id), after.comments.map { it.id })

        // Soft delete: the row stays, marked, not gone.
        val deletedAt = dsl.fetchOne("SELECT deleted_at FROM day_comments WHERE id={0}", bySide.id)!!
            .get("deleted_at", Instant::class.java)
        assertTrue(deletedAt != null)
    }

    // ---- facts: counts only ----------------------------------------------------

    @Test
    fun `facts are plain counts, no judgement fields`() {
        val occ1 = onlyOccurrence(daily("Greeting").id)
        outcomes.set(s, occ1, OutcomeService.Change(Outcome.delivered))
        dispositions.set(d, occ1, DispositionService.Change(Disposition.praised))

        val occ2 = onlyOccurrence(daily("Report").id)
        outcomes.set(s, occ2, OutcomeService.Change(Outcome.cant_do, note = "too tired"))
        dispositions.set(d, occ2, DispositionService.Change(Disposition.let_go))

        comments.add(s, dyn, today, "sorry about today")

        val f = record.facts(d, dyn, today, today)
        assertEquals(1, f.delivered)
        assertEquals(0, f.late)
        assertEquals(1, f.flagged)
        assertEquals(0, f.missed)
        assertEquals(1, f.letGo)
        assertEquals(1, f.praised)
        assertEquals(1, f.comments)
    }

    // ---- streak ------------------------------------------------------------

    @Test
    fun `let_go and a paused day do not break the streak, but an undisposed missed day does`() {
        // One daily task drives the whole history, so `generate` never
        // pollutes another task's days (it materialises every active task
        // for the day it is asked about).
        val task = daily("Greeting")

        fun occurrenceOn(day: LocalDate): UUID {
            generator.generate(dyn, day)
            return onlyOccurrence(task.id, day)
        }

        // Four days back: delivered, clean.
        val fourAgo = today.minusDays(4)
        dsl.query("UPDATE occurrences SET outcome='delivered', outcome_at=now() WHERE id={0}", occurrenceOn(fourAgo)).execute()

        // Three days back: paused for that day — contributes nothing, breaks nothing.
        val threeAgo = today.minusDays(3)
        val pausedOcc = occurrenceOn(threeAgo)
        dsl.query("UPDATE occurrences SET outcome='paused' WHERE id={0}", pausedOcc).execute()

        // Two days back: missed, then let_go — the D's mercy, not a debt.
        val twoAgo = today.minusDays(2)
        val letGoOcc = occurrenceOn(twoAgo)
        closer.closeBefore(dyn, twoAgo.plusDays(1))
        assertEquals("missed", dsl.fetchOne("SELECT outcome FROM occurrences WHERE id={0}", letGoOcc)!!.get("outcome", String::class.java))
        dispositions.set(d, letGoOcc, DispositionService.Change(Disposition.let_go))

        // Yesterday: delivered, clean.
        val oneAgo = today.minusDays(1)
        dsl.query("UPDATE occurrences SET outcome='delivered', outcome_at=now() WHERE id={0}", occurrenceOn(oneAgo)).execute()

        // Today: delivered, clean.
        outcomes.set(s, occurrenceOn(today), OutcomeService.Change(Outcome.delivered))

        // Every earlier day has no occurrence at all, which does not break
        // it either — the walk runs all the way back to the day the couple
        // started (seeded 30 days back in `seed()`).
        val streak = record.summary(d, dyn).currentStreak
        assertEquals(31, streak, "paused and let_go break nothing, and neither does a day with no occurrences at all")

        // Now go one day further back and leave it missed, undisposed — this stops the walk exactly there.
        val fiveAgo = today.minusDays(5)
        val brokenOcc = occurrenceOn(fiveAgo)
        closer.closeBefore(dyn, fiveAgo.plusDays(1))
        assertEquals("missed", dsl.fetchOne("SELECT outcome FROM occurrences WHERE id={0}", brokenOcc)!!.get("outcome", String::class.java))

        val afterBreak = record.summary(d, dyn).currentStreak
        assertEquals(5, afterBreak, "the undisposed missed day five days back stops the walk there: today plus the four clean days after it")
    }

    @Test
    fun `summary survives two decided occurrences on the same day`() {
        // Regression: the streak's "anything decided today" probe used fetchOne
        // and blew up with TooManyRowsException on the second delivered task.
        val a = daily("Greeting")
        val b = daily("Water")
        generator.generate(dyn, today)
        dsl.query("UPDATE occurrences SET outcome='delivered', outcome_at=now() WHERE task_id IN ({0}, {1})", a.id, b.id).execute()
        // Empty earlier days never break a streak, so only the floor matters here.
        assertTrue(record.summary(d, dyn).currentStreak >= 1)
    }

    @Test
    fun `days together never decreases as time passes without any writes`() {
        val before = record.summary(d, dyn).daysTogether
        assertTrue(before >= 1)
        // Backdating the earlier-joining member's join does not move it —
        // only the LATER joined_at governs, and it has not changed.
        dsl.query(
            "UPDATE memberships SET joined_at = joined_at - interval '10 days' WHERE dynamic_id={0} AND user_id={1}",
            dyn, d,
        ).execute()
        assertEquals(before, record.summary(d, dyn).daysTogether)
    }

    // ---- history repair: missed -> delivered_late -------------------------------

    @Test
    fun `repairing a missed occurrence records delivered_late with the real timestamp, not the due time`() {
        val yesterday = today.minusDays(1)
        val occ = generateOn("Evening report", yesterday)
        closer.closeBefore(dyn, today)
        assertEquals("missed", dsl.fetchOne("SELECT outcome FROM occurrences WHERE id={0}", occ)!!.get("outcome", String::class.java))

        val repairedAt = Instant.now()
        val result = outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered, note = "sorry, forgot to mark it"), now = repairedAt)

        assertEquals("delivered_late", result.outcome, "the day is over, so it lands as late, not on time")
        val row = dsl.fetchOne("SELECT outcome, outcome_at FROM occurrences WHERE id={0}", occ)!!
        assertEquals("delivered_late", row.get("outcome", String::class.java))
        assertEquals(repairedAt.epochSecond, row.get("outcome_at", Instant::class.java).epochSecond, "the timestamp is the real repair time, not disguised as on-time")

        val history = dsl.fetch(
            "SELECT to_value FROM occurrence_history WHERE occurrence_id={0} ORDER BY at", occ,
        ).map { it.get("to_value", String::class.java) }
        assertEquals(listOf("missed", "delivered_late"), history)
    }

    // ---- outbox: day_comment targets the other member ---------------------------

    @Test
    fun `a day comment enqueues an outbox row that targets the other member`() {
        val c = comments.add(s, dyn, today, "can we talk tonight")
        val row = dsl.fetchOne(
            "SELECT aggregate_type, event_type, dedupe_key FROM outbox_records WHERE aggregate_id={0}", c.id,
        )!!
        assertEquals("day_comment", row.get("aggregate_type", String::class.java))
        assertEquals("day_comment", row.get("event_type", String::class.java))
        assertEquals("comment:${c.id}", row.get("dedupe_key", String::class.java))
    }
}
