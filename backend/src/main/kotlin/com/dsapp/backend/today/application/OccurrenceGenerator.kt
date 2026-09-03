package com.dsapp.backend.today.application

import com.dsapp.backend.today.domain.Schedule
import com.dsapp.backend.today.domain.TaskKind
import com.fasterxml.jackson.databind.ObjectMapper
import org.jooq.DSLContext
import org.jooq.JSONB
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.util.UUID

/**
 * Turns active tasks into the day's occurrences.
 *
 * Idempotent by construction: `UNIQUE (task_id, day, slot)` means a second
 * tick, a restart, or a query racing the scheduler all land on the same rows.
 * A task paused over the day produces a `paused` occurrence rather than
 * nothing, so the s screen can show it grey and the day owes nothing
 * (invariant 9).
 */
@Service
class OccurrenceGenerator(
    private val dsl: DSLContext,
    private val days: DynamicDays,
    private val mapper: ObjectMapper,
) {
    private data class TaskRow(
        val id: UUID, val kind: TaskKind, val schedule: Schedule?, val timesPerDay: Int,
        val dueTime: LocalTime?, val dueAt: Instant?, val pausedUntil: Instant?,
    )

    /** Generate every repeating task's occurrences for [day]. Returns rows inserted. */
    @Transactional
    fun generate(dynamicId: UUID, day: LocalDate): Int {
        val settings = days.settings(dynamicId)
        val range = settings.rangeOf(day)
        var inserted = 0
        for (t in activeTasks(dynamicId)) {
            if (!repeatsOn(t, day)) continue
            val paused = t.pausedUntil != null && t.pausedUntil > range.start
            for (slot in 0 until t.timesPerDay) {
                val due = t.dueTime?.let { settings.dueAt(day, it) } ?: range.endInclusive
                inserted += insert(t.id, dynamicId, day, slot, due, if (paused) "paused" else "open")
            }
        }
        return inserted
    }

    /** A one-off gets its single occurrence the moment it exists. */
    @Transactional
    fun ensureOneOff(taskId: UUID) {
        val t = dsl.fetchOne(
            "SELECT dynamic_id, due_at, paused_until FROM tasks WHERE id = {0} AND kind = 'one_off'", taskId,
        ) ?: return
        val dynamicId = t.get("dynamic_id", UUID::class.java)
        val settings = days.settings(dynamicId)
        val due = t.get("due_at", Instant::class.java)
        val day = settings.dayOf(due ?: Instant.now())
        insert(taskId, dynamicId, day, 0, due ?: settings.rangeOf(day).endInclusive, "open")
    }

    private fun repeatsOn(t: TaskRow, day: LocalDate): Boolean = when (t.kind) {
        TaskKind.recurring -> t.schedule?.appliesTo(day) ?: false
        TaskKind.checkin, TaskKind.measure -> true
        TaskKind.one_off, TaskKind.open -> false
    }

    private fun insert(taskId: UUID, dynamicId: UUID, day: LocalDate, slot: Int, due: Instant, outcome: String): Int =
        dsl.query(
            """
            INSERT INTO occurrences (id, task_id, dynamic_id, day, slot, due_at, outcome)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6})
            ON CONFLICT (task_id, day, slot) DO NOTHING
            """.trimIndent(),
            UUID.randomUUID(), taskId, dynamicId, day, slot, due, outcome,
        ).execute()

    private fun activeTasks(dynamicId: UUID): List<TaskRow> = dsl.fetch(
        """
        SELECT id, kind, schedule, times_per_day, due_time, due_at, paused_until
          FROM tasks WHERE dynamic_id = {0} AND status = 'active'
        """.trimIndent(),
        dynamicId,
    ).map {
        TaskRow(
            id = it.get("id", UUID::class.java),
            kind = TaskKind.valueOf(it.get("kind", String::class.java)),
            schedule = it.get("schedule", JSONB::class.java)?.let { j -> parseSchedule(j.data()) },
            timesPerDay = it.get("times_per_day", Int::class.java),
            dueTime = it.get("due_time", LocalTime::class.java),
            dueAt = it.get("due_at", Instant::class.java),
            pausedUntil = it.get("paused_until", Instant::class.java),
        )
    }

    @Suppress("UNCHECKED_CAST")
    fun parseSchedule(json: String): Schedule =
        Schedule.from(mapper.readValue(json, Map::class.java) as Map<String, Any?>)
}
