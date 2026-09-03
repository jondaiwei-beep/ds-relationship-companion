package com.dsapp.backend.today.domain

import java.time.DayOfWeek
import java.time.LocalDate

/** What a task is (product/03-domain.md §Task). */
enum class TaskKind { recurring, one_off, open, checkin, measure }

enum class Proof { check, photo, text, any }

enum class TaskStatus { proposed, active, archived }

/**
 * The s axis. Written only by the s side, or by the day-end sweep (`missed`,
 * `paused`). Nothing on this axis is a judgement — that is the D axis.
 */
enum class Outcome {
    open, delivered, delivered_late, cant_do, new_time_requested,
    discuss_requested, missed, paused;

    /** The s exits a person may choose. `missed`/`paused` are sweeps, `open` is a withdrawal. */
    val chosenByS: Boolean get() = this in setOf(delivered, cant_do, new_time_requested, discuss_requested)
}

/**
 * The D axis. Written only by the D side, never by a job, and never expiring
 * (invariants 2 and 3): a Tuesday can be dealt with on Friday.
 */
enum class Disposition { none, seen, praised, let_go, make_up, punished }

enum class Axis { outcome, disposition }

/**
 * Recurring schedule, stored as jsonb on the task.
 *
 * `{"type":"daily"}` · `{"type":"weekdays","days":[1,3,5]}` (ISO, Mon=1) ·
 * `{"type":"every_n_days","n":3,"from":"2026-09-03"}`
 */
sealed interface Schedule {
    fun appliesTo(day: LocalDate): Boolean

    data object Daily : Schedule {
        override fun appliesTo(day: LocalDate) = true
    }

    data class Weekdays(val days: Set<DayOfWeek>) : Schedule {
        override fun appliesTo(day: LocalDate) = day.dayOfWeek in days
    }

    data class EveryNDays(val n: Int, val from: LocalDate) : Schedule {
        override fun appliesTo(day: LocalDate): Boolean {
            if (day.isBefore(from)) return false
            return (day.toEpochDay() - from.toEpochDay()) % n == 0L
        }
    }

    companion object {
        /** Parse the jsonb map. Throws on an unknown shape so a bad write fails loudly at create. */
        fun from(map: Map<String, Any?>): Schedule = when (val type = map["type"]) {
            "daily" -> Daily
            "weekdays" -> {
                val days = (map["days"] as? List<*>)?.map { DayOfWeek.of((it as Number).toInt()) }
                require(!days.isNullOrEmpty()) { "weekdays schedule needs days" }
                Weekdays(days.toSet())
            }
            "every_n_days" -> {
                val n = (map["n"] as? Number)?.toInt()
                require(n != null && n >= 2) { "every_n_days needs n >= 2" }
                EveryNDays(n, LocalDate.parse(map["from"] as String))
            }
            else -> throw IllegalArgumentException("unknown schedule type: $type")
        }
    }
}
