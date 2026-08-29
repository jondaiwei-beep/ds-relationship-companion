package com.dsapp.backend.delivery.infrastructure

import com.dsapp.backend.delivery.application.OutboxDispatcher
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.scheduling.annotation.EnableScheduling
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component

/**
 * Drives the outbox.
 *
 * A poll loop rather than a broker: at Core Beta scale one deployable and one
 * datastore is the right trade (ADR-0001). `SKIP LOCKED` means several
 * instances can poll safely.
 *
 * Disable with `dsapp.delivery.enabled=false` — a kill switch, per Notion 06 §9.
 */
@Component
@EnableScheduling
@ConditionalOnProperty(
    prefix = "dsapp.delivery", name = ["enabled"], havingValue = "true", matchIfMissing = true,
)
class OutboxScheduler(private val dispatcher: OutboxDispatcher) {

    @Scheduled(fixedDelayString = "\${dsapp.delivery.poll-ms:5000}")
    fun poll() {
        dispatcher.dispatchOnce()
    }
}
