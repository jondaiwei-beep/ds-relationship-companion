package com.dsapp.backend.today.application

import com.dsapp.backend.shared.time.RelationshipDay
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneId
import java.util.UUID

/**
 * The one relationship-day algorithm (invariant 6): the dynamic's IANA zone
 * plus its day boundary. Nothing else in the backend decides what "today" is.
 */
@Service
class DynamicDays(private val dsl: DSLContext) {

    data class Settings(val zone: ZoneId, val boundaryMinutes: Int) {
        fun dayOf(at: Instant): LocalDate = RelationshipDay.dayOf(at, zone, boundaryMinutes)
        fun rangeOf(day: LocalDate): ClosedRange<Instant> = RelationshipDay.rangeOf(day, zone, boundaryMinutes)

        /**
         * When a local wall-clock time falls inside relationship [day]. A time
         * before the boundary (02:00 with a 04:00 boundary) is the small hours
         * of the NEXT calendar date, still inside this relationship day.
         */
        fun dueAt(day: LocalDate, time: LocalTime): Instant {
            val boundary = LocalTime.MIDNIGHT.plusMinutes(boundaryMinutes.toLong())
            val date = if (time < boundary) day.plusDays(1) else day
            return RelationshipDay.resolve(LocalDateTime.of(date, time), zone)
        }
    }

    fun settings(dynamicId: UUID): Settings {
        val r = dsl.fetchOne(
            "SELECT reference_timezone, day_boundary_minutes FROM dynamics WHERE id = {0}", dynamicId,
        ) ?: throw IllegalArgumentException("no such dynamic")
        return Settings(
            ZoneId.of(r.get("reference_timezone", String::class.java)),
            r.get("day_boundary_minutes", Int::class.java),
        )
    }

    fun today(dynamicId: UUID, now: Instant = Instant.now()): LocalDate = settings(dynamicId).dayOf(now)
}
