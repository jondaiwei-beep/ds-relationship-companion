package com.dsapp.backend.shared.time

import java.time.Duration
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneId

/**
 * Relationship-day arithmetic — Notion 03 §5, 04 §9.
 *
 * A relationship day is NOT midnight to midnight. With a 04:00 boundary,
 * something completed at 02:00 local belongs to the PREVIOUS relationship day,
 * because couples are awake past midnight and a day that flips underneath them
 * produces the wrong-day defect that Notion 07 §9 classes as a release blocker.
 *
 * This class NEVER reads the JVM default zone. Every calculation takes the
 * Dynamic's IANA zone explicitly — using the server or device zone is the
 * single most likely source of a wrong-day bug.
 */
object RelationshipDay {

    /**
     * Resolve a local wall-clock time to an instant, handling DST correctly.
     *
     * - **Gap** (spring forward, the local time does not exist): shift forward
     *   by the actual gap length. Never assume one hour — Lord Howe Island
     *   shifts by 30 minutes.
     * - **Fold** (fall back, the local time happens twice): take the FIRST
     *   occurrence, so a ritual fires once rather than twice.
     */
    fun resolve(local: LocalDateTime, zone: ZoneId): Instant {
        val rules = zone.rules
        val valid = rules.getValidOffsets(local)
        return when {
            // Normal: exactly one valid offset.
            valid.size == 1 -> local.toInstant(valid[0])
            // Fold: two valid offsets. The earlier offset is the first pass.
            valid.size > 1 -> local.toInstant(valid[0])
            // Gap: no valid offset. Shift by the transition's own duration.
            else -> {
                val transition = rules.getTransition(local)
                local.plus(transition.duration).toInstant(transition.offsetAfter)
            }
        }
    }

    /**
     * Which relationship day does [instant] fall in?
     *
     * @param boundaryMinutes minutes after local midnight at which the day
     *   turns over (0..1439). 0 means true midnight.
     */
    fun dayOf(instant: Instant, zone: ZoneId, boundaryMinutes: Int): LocalDate {
        require(boundaryMinutes in 0..1439) { "boundaryMinutes must be 0..1439" }
        val local = instant.atZone(zone).toLocalDateTime()
        val boundary = LocalTime.MIDNIGHT.plusMinutes(boundaryMinutes.toLong())
        // Before the boundary means we are still in yesterday's relationship day.
        return if (local.toLocalTime() < boundary) {
            local.toLocalDate().minusDays(1)
        } else {
            local.toLocalDate()
        }
    }

    /**
     * The half-open instant range `[start, end)` covering a relationship day.
     *
     * Length is NOT always 24 hours: a spring-forward day is 23 hours and a
     * fall-back day is 25.
     */
    fun rangeOf(day: LocalDate, zone: ZoneId, boundaryMinutes: Int): ClosedRange<Instant> {
        require(boundaryMinutes in 0..1439) { "boundaryMinutes must be 0..1439" }
        val boundary = LocalTime.MIDNIGHT.plusMinutes(boundaryMinutes.toLong())
        val start = resolve(LocalDateTime.of(day, boundary), zone)
        val end = resolve(LocalDateTime.of(day.plusDays(1), boundary), zone)
        return start..end
    }

    /** True when a whole calendar date does not exist in [zone] (e.g. Pacific/Apia 2011-12-30). */
    fun dateExists(day: LocalDate, zone: ZoneId): Boolean {
        val startOfDay = day.atStartOfDay(zone)
        return startOfDay.toLocalDate() == day
    }

    /** How long a relationship day actually lasts. Used by tests and diagnostics. */
    fun lengthOf(day: LocalDate, zone: ZoneId, boundaryMinutes: Int): Duration {
        val r = rangeOf(day, zone, boundaryMinutes)
        return Duration.between(r.start, r.endInclusive)
    }
}
