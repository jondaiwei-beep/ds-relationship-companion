package com.dsapp.backend.today.application

import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDate
import java.util.UUID

/**
 * Day end: whatever is still `open` on a past relationship day becomes
 * `missed`. That is the only thing this writes. No points move, no
 * consequence is issued, nothing is said to anyone — what a missed thing
 * means is the D's call, whenever they get to it (invariants 1, 2, 3).
 */
@Service
class DayCloser(private val dsl: DSLContext) {

    @Transactional
    fun closeBefore(dynamicId: UUID, today: LocalDate): Int {
        val closed = dsl.fetch(
            """
            UPDATE occurrences
               SET outcome = 'missed', outcome_at = now(), version = version + 1, updated_at = now()
             WHERE dynamic_id = {0} AND day < {1} AND outcome = 'open'
            RETURNING id
            """.trimIndent(),
            dynamicId, today,
        ).map { it.get("id", UUID::class.java) }
        for (id in closed) {
            dsl.query(
                """
                INSERT INTO occurrence_history (id, occurrence_id, by_user_id, axis, from_value, to_value)
                VALUES ({0}, {1}, NULL, 'outcome', 'open', 'missed')
                """.trimIndent(),
                UUID.randomUUID(), id,
            ).execute()
        }
        return closed.size
    }
}
