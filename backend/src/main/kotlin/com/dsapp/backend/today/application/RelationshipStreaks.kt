package com.dsapp.backend.today.application

import org.jooq.DSLContext
import org.springframework.stereotype.Service
import java.time.Instant
import java.time.LocalDate
import java.util.UUID

/**
 * `days_together` and `current_streak` (product/03-domain.md §Streak). The
 * one implementation both `今天` and `记录` read, so the two tabs can never
 * disagree about either number.
 */
@Service
class RelationshipStreaks(private val dsl: DSLContext, private val days: DynamicDays) {

    /**
     * Relationship days since the day both members were ACTIVE — the later of
     * the two `memberships.joined_at`, or the dynamic's `created_at` when
     * there is only one member. **Never resets**, only grows: it counts
     * elapsed days, not anything that can be undone.
     */
    fun daysTogether(dynamicId: UUID, now: Instant = Instant.now()): Int {
        val settings = days.settings(dynamicId)
        val today = settings.dayOf(now)
        val startDay = startDay(dynamicId)
        if (today.isBefore(startDay)) return 0
        return (today.toEpochDay() - startDay.toEpochDay()).toInt() + 1
    }

    /** The relationship day both members were first ACTIVE together — the floor for both numbers below. */
    private fun startDay(dynamicId: UUID): LocalDate {
        val settings = days.settings(dynamicId)
        val joinedAts = dsl.fetch(
            "SELECT joined_at FROM memberships WHERE dynamic_id = {0} AND access_state = 'ACTIVE' ORDER BY joined_at",
            dynamicId,
        ).map { it.get("joined_at", Instant::class.java) }
        val since = if (joinedAts.size >= 2) {
            joinedAts.max()
        } else {
            dsl.fetchOne("SELECT created_at FROM dynamics WHERE id = {0}", dynamicId)!!.get("created_at", Instant::class.java)
        }
        return settings.dayOf(since)
    }

    /**
     * Consecutive relationship days, ending today (or yesterday if today has
     * nothing decided yet — it is still in progress), where every non-open,
     * non-paused occurrence of the day is `delivered` / `delivered_late` / has
     * disposition `let_go` / `make_up`. Days with no occurrences at all do not
     * break it — there was simply nothing asked. `missed` with no `let_go`
     * breaks it (invariant 6: paused produces no debt, so `paused` never
     * breaks it either).
     */
    fun currentStreak(dynamicId: UUID, now: Instant = Instant.now()): Int {
        val settings = days.settings(dynamicId)
        val today = settings.dayOf(now)
        // The relationship cannot have a streak before it started — this is
        // also what keeps the walk-back below from running off into the past
        // on a day with no occurrences at all yet.
        val floor = startDay(dynamicId)

        fun daySatisfied(day: LocalDate): Boolean {
            val rows = dsl.fetch(
                """
                SELECT outcome, disposition FROM occurrences
                 WHERE dynamic_id = {0} AND day = {1} AND outcome NOT IN ('open', 'paused')
                """.trimIndent(),
                dynamicId, day,
            )
            return rows.all { r ->
                val outcome = r.get("outcome", String::class.java)
                val disposition = r.get("disposition", String::class.java)
                outcome == "delivered" || outcome == "delivered_late" ||
                    disposition == "let_go" || disposition == "make_up"
            }
        }

        fun dayHasAnything(day: LocalDate): Boolean = dsl.fetchOne(
            "SELECT 1 FROM occurrences WHERE dynamic_id = {0} AND day = {1} AND outcome NOT IN ('open', 'paused')",
            dynamicId, day,
        ) != null

        if (today.isBefore(floor)) return 0
        // Today counts only once something has actually been decided on it;
        // otherwise an empty today would wrongly break a real streak while
        // the relationship day is still in progress.
        var cursor = if (dayHasAnything(today)) today else today.minusDays(1)
        var streak = 0
        while (!cursor.isBefore(floor) && daySatisfied(cursor)) {
            streak++
            cursor = cursor.minusDays(1)
        }
        return streak
    }
}
