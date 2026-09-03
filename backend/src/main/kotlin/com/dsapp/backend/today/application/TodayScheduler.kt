package com.dsapp.backend.today.application

import org.jooq.DSLContext
import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import java.util.UUID

/** One tick per poll: every ACTIVE dynamic gets today generated and yesterday closed. */
@Component
@ConditionalOnProperty("dsapp.generation.enabled", havingValue = "true")
class TodayScheduler(
    private val dsl: DSLContext,
    private val days: DynamicDays,
    private val generator: OccurrenceGenerator,
    private val closer: DayCloser,
    private val dNotes: DNoteService,
) {
    private val log = LoggerFactory.getLogger(javaClass)

    @Scheduled(fixedDelayString = "\${dsapp.generation.poll-ms:60000}")
    fun tick() {
        val active = dsl.fetch("SELECT id FROM dynamics WHERE state = 'ACTIVE'")
            .map { it.get("id", UUID::class.java) }
        for (id in active) {
            try {
                val today = days.today(id)
                generator.generate(id, today)
                closer.closeBefore(id, today)
            } catch (e: Exception) {
                // One dynamic's bad data must not stop the others' day from starting.
                log.warn("today tick failed for dynamic {}", id, e)
            }
        }
        dNotes.fireDueReminders()
    }
}
