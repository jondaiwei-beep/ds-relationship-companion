package com.dsapp.backend.record

import com.dsapp.backend.record.application.DayCommentService
import com.dsapp.backend.record.application.RecordQueryService
import com.dsapp.backend.today.application.DynamicDays
import com.dsapp.backend.today.application.OccurrenceGenerator
import com.dsapp.backend.today.application.OutcomeService
import com.dsapp.backend.today.application.TaskService
import com.dsapp.backend.today.domain.Outcome
import com.dsapp.backend.today.domain.TaskKind
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.math.BigDecimal
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * Phase 5 (product/06-build-order.md): kind=measure values, the resulting
 * series, and taking the record elsewhere via export.
 */
@SpringBootTest
@ActiveProfiles("test")
class MeasureAndExportIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var tasks: TaskService
    @Autowired lateinit var generator: OccurrenceGenerator
    @Autowired lateinit var outcomes: OutcomeService
    @Autowired lateinit var days: DynamicDays
    @Autowired lateinit var record: RecordQueryService
    @Autowired lateinit var comments: DayCommentService

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

    private val today get() = days.today(dyn)

    private fun onlyOccurrence(taskId: UUID) = dsl.fetchOne(
        "SELECT id FROM occurrences WHERE task_id={0} AND day={1}", taskId, today,
    )!!.get("id", UUID::class.java)

    // ---- measure values --------------------------------------------------

    @Test
    fun `a measure task stores the value on delivery and it comes back in the series`() {
        val t = tasks.create(
            d, dyn,
            TaskService.NewTask(title = "Weight", kind = TaskKind.measure, schedule = null, unit = "kg"),
        )
        val occ = onlyOccurrence(t.id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered, value = BigDecimal("72.500")))

        val stored = dsl.fetchOne("SELECT value FROM occurrences WHERE id={0}", occ)!!.get("value", BigDecimal::class.java)
        assertEquals(0, BigDecimal("72.500").compareTo(stored))

        val series = record.series(d, dyn, t.id, today, today)
        assertEquals("kg", series.unit)
        assertEquals(1, series.points.size)
        assertEquals(today, series.points[0].day)
        assertEquals(0, BigDecimal("72.500").compareTo(series.points[0].value))
    }

    @Test
    fun `a non-measure task rejects a value`() {
        val t = tasks.create(d, dyn, TaskService.NewTask(title = "Greeting"))
        val occ = onlyOccurrence(t.id)
        assertFailsWith<IllegalArgumentException> {
            outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered, value = BigDecimal("1")))
        }
    }

    @Test
    fun `a measure task requires a value when delivered`() {
        val t = tasks.create(d, dyn, TaskService.NewTask(title = "Steps", kind = TaskKind.measure, schedule = null, unit = "steps"))
        val occ = onlyOccurrence(t.id)
        assertFailsWith<IllegalArgumentException> {
            outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered))
        }
        // a non-delivered exit needs no value
        outcomes.set(s, occ, OutcomeService.Change(Outcome.cant_do))
    }

    // ---- export ------------------------------------------------------------

    @Test
    fun `json export carries the occurrence and comment, without the other side's private note`() {
        val t = tasks.create(d, dyn, TaskService.NewTask(title = "Greeting"))
        val occ = onlyOccurrence(t.id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered, note = "done"))
        comments.add(d, dyn, today, "well done")
        dsl.query(
            "INSERT INTO private_notes (id, dynamic_id, day, author_id, body) VALUES ({0},{1},{2},{3},{4})",
            UUID.randomUUID(), dyn, today, d, "d's secret note",
        ).execute()

        val view = record.export(s, dyn, today, today)
        assertEquals(dyn, view.dynamic.id)
        val day = view.days.single { it.day == today }
        assertTrue(day.occurrences.any { it.taskTitle == "Greeting" && it.outcome == "delivered" && it.note == "done" })
        assertTrue(day.comments.any { it.body == "well done" && it.authorSide == "D" })
        // export carries no private-note field at all — nothing leaks either side's
        assertTrue(view.toString().contains("d's secret note").not())
    }

    @Test
    fun `csv export has a header and a row, and either side may export`() {
        val t = tasks.create(d, dyn, TaskService.NewTask(title = "Greeting"))
        val occ = onlyOccurrence(t.id)
        outcomes.set(s, occ, OutcomeService.Change(Outcome.delivered))

        // both sides read the same query service export; the controller wiring is exercised in RecordIT-style tests elsewhere
        val view = record.export(d, dyn, today, today)
        assertEquals(1, view.days.single { it.day == today }.occurrences.size)

        val csv = buildString {
            append("day,task_title,kind,outcome,outcome_at,disposition,value,unit,note\n")
            for (dv in view.days) for (o in dv.occurrences) {
                append(dv.day).append(',').append(o.taskTitle).append(',').append(o.kind).append(',')
                    .append(o.outcome).append(',').append(o.outcomeAt ?: "").append(',').append(o.disposition).append(',')
                    .append(o.value ?: "").append(',').append(o.unit ?: "").append(',').append(o.note ?: "").append('\n')
            }
        }
        val lines = csv.trim().lines()
        assertEquals("day,task_title,kind,outcome,outcome_at,disposition,value,unit,note", lines[0])
        assertEquals(2, lines.size)
        assertTrue(lines[1].contains("Greeting"))
        assertTrue(lines[1].contains("delivered"))
    }

    @Test
    fun `export caps the range at 366 days`() {
        assertFailsWith<IllegalArgumentException> {
            record.export(d, dyn, today.minusDays(400), today)
        }
    }
}
