package com.dsapp.backend.expectation.application

import com.dsapp.backend.shared.time.RelationshipDay
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneId
import java.util.UUID

/**
 * Turns recurring Rituals into Occurrences for a relationship day.
 *
 * Two properties matter more than anything else here:
 *
 * 1. **Idempotent.** Running generation twice must not duplicate. Enforced by
 *    a unique index on `(recurrence_id, relationship_day)` — the older partial
 *    index only covers non-terminal rows, so it would not stop a duplicate
 *    once an occurrence was acknowledged.
 *
 * 2. **No backlog on Resume.** Pause advances a barrier rather than queueing
 *    missed days. Coming back must never mean facing a pile of things you
 *    "owe" (Notion 03 §4, Journey E).
 */
@Service
class OccurrenceGenerator(
    private val dsl: DSLContext,
    private val events: RelationshipEventWriter,
) {
    private val log = LoggerFactory.getLogger(OccurrenceGenerator::class.java)

    data class Generated(val occurrenceId: UUID, val definitionId: UUID, val day: LocalDate)

    /**
     * Generate for one Dynamic on one relationship day.
     *
     * @param day the RELATIONSHIP day, not the civil date.
     */
    @Transactional
    fun generateFor(dynamicId: UUID, day: LocalDate): List<Generated> {
        // Paused or ended dynamics produce nothing. Row-locking the dynamic
        // serialises generation against a concurrent Pause.
        val dyn = dsl.fetchOne(
            """SELECT state, reference_timezone, day_boundary_minutes
                 FROM dynamics WHERE id = {0} FOR UPDATE""",
            dynamicId,
        ) ?: return emptyList()
        if (dyn.get("state", String::class.java) != "ACTIVE") return emptyList()

        val boundary = dyn.get("day_boundary_minutes", Int::class.java)

        val due = dsl.fetch(
            """
            SELECT r.id AS recurrence_id, r.definition_id, r.frequency, r.weekday,
                   r.local_time, r.timezone, r.eligible_from_day
              FROM expectation_recurrences r
              JOIN expectation_definitions d ON d.id = r.definition_id
             WHERE d.dynamic_id = {0} AND r.active AND d.active
            """.trimIndent(),
            dynamicId,
        )

        val created = mutableListOf<Generated>()
        for (row in due) {
            val frequency = row.get("frequency", String::class.java)
            val weekday = row.get("weekday", Int::class.javaObjectType)
            val barrier = row.get("eligible_from_day", LocalDate::class.java)

            // The barrier is what makes Resume backlog-free: days before it are
            // simply not eligible, however generation is invoked.
            if (barrier != null && day < barrier) continue
            if (frequency == "WEEKLY" && weekday != day.dayOfWeek.value) continue

            val zone = ZoneId.of(row.get("timezone", String::class.java))
            val localTime = row.get("local_time", LocalTime::class.java)

            // THE WRONG-DAY TRAP (Notion 07 §9, S1). The relationship day label
            // is NOT the civil date when the boundary is non-zero: with a 04:00
            // boundary, relationship day 2026-03-04 runs to 03-05 03:59. A
            // 02:00 ritual therefore falls on the FOLLOWING civil date. Derive
            // the instant from the day's actual range instead of assuming.
            val civilDate =
                if (localTime < LocalTime.MIDNIGHT.plusMinutes(boundary.toLong())) {
                    day.plusDays(1)
                } else {
                    day
                }
            val dueAt = RelationshipDay.resolve(LocalDateTime.of(civilDate, localTime), zone)

            val recurrenceId = row.get("recurrence_id", UUID::class.java)
            val definitionId = row.get("definition_id", UUID::class.java)
            val occurrenceId = UUID.randomUUID()

            // ON CONFLICT DO NOTHING makes a second run a no-op rather than an
            // error, so generation is safe to retry.
            val inserted = dsl.fetchOne(
                """
                INSERT INTO occurrences
                    (id, definition_id, dynamic_id, recurrence_id, state, relationship_day, due_at)
                VALUES ({0}, {1}, {2}, {3}, 'ACTIVE', {4}, {5})
                ON CONFLICT (recurrence_id, relationship_day) WHERE recurrence_id IS NOT NULL DO NOTHING
                RETURNING id
                """.trimIndent(),
                occurrenceId, definitionId, dynamicId, recurrenceId, day, dueAt,
            )
            if (inserted == null) continue

            events.append(
                dynamicId, null, "occurrence_activated",
                """{"occurrence_id":"$occurrenceId","recurrence_id":"$recurrenceId"}""",
            )
            events.enqueueOutbox(
                "occurrence", occurrenceId, "occurrence_activated", "activated:$occurrenceId",
            )
            created += Generated(occurrenceId, definitionId, day)
        }

        if (created.isNotEmpty()) {
            log.info("generated {} occurrence(s) for {} on {}", created.size, dynamicId, day)
        }
        return created
    }

    /** Today's relationship day for a Dynamic, in ITS timezone — never the server's. */
    @Transactional(readOnly = true)
    fun currentDayFor(dynamicId: UUID): LocalDate? {
        val d = dsl.fetchOne(
            "SELECT reference_timezone, day_boundary_minutes FROM dynamics WHERE id = {0}",
            dynamicId,
        ) ?: return null
        return RelationshipDay.dayOf(
            instant = java.time.Instant.now(),
            zone = ZoneId.of(d.get("reference_timezone", String::class.java)),
            boundaryMinutes = d.get("day_boundary_minutes", Int::class.java),
        )
    }
}
