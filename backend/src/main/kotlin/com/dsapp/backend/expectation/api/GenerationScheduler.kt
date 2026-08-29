package com.dsapp.backend.expectation.api

import com.dsapp.backend.expectation.application.OccurrenceGenerator
import com.dsapp.backend.expectation.application.OverdueSweeper
import org.jooq.DSLContext
import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import java.util.UUID

/**
 * Drives occurrence generation and the overdue sweep.
 *
 * Runs often enough that a Ritual appears promptly in the couple's own
 * timezone, and is idempotent, so a missed tick simply catches up.
 *
 * Kill switch: `dsapp.generation.enabled=false` (Notion 06 §9).
 */
@Component
@ConditionalOnProperty(
    prefix = "dsapp.generation", name = ["enabled"], havingValue = "true", matchIfMissing = true,
)
class GenerationScheduler(
    private val dsl: DSLContext,
    private val generator: OccurrenceGenerator,
    private val sweeper: OverdueSweeper,
) {
    private val log = LoggerFactory.getLogger(GenerationScheduler::class.java)

    @Scheduled(fixedDelayString = "\${dsapp.generation.poll-ms:300000}")
    fun tick() {
        runCatching {
            val active = dsl.fetch("SELECT id FROM dynamics WHERE state = 'ACTIVE'")
                .map { it.get("id", UUID::class.java) }

            for (dynamicId in active) {
                // Each dynamic's own relationship day, never the server's date.
                val day = generator.currentDayFor(dynamicId) ?: continue
                generator.generateFor(dynamicId, day)
            }
            sweeper.sweep()
        }.onFailure { log.error("generation tick failed", it) }
    }
}
