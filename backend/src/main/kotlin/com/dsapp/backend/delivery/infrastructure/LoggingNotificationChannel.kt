package com.dsapp.backend.delivery.infrastructure

import com.dsapp.backend.delivery.domain.NeutralCopy
import com.dsapp.backend.delivery.domain.NotificationChannel
import com.dsapp.backend.delivery.domain.NotificationRequest
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component

/**
 * Dev/staging channel: records that a delivery would have gone out.
 *
 * Real Android Push and Web Push adapters arrive in Milestone 4A. This exists
 * so the dispatcher's suppression and re-check logic can be exercised end to
 * end before a provider is wired up.
 *
 * It logs only the neutral body and locating IDs — the same discipline a real
 * provider adapter must follow.
 */
@Component
class LoggingNotificationChannel : NotificationChannel {

    private val log = LoggerFactory.getLogger(LoggingNotificationChannel::class.java)

    override val name = "log"

    override fun send(request: NotificationRequest) {
        // Defence in depth: even here, refuse anything that is not one of the
        // fixed neutral strings.
        check(request.body in NeutralCopy.all) {
            "refusing to deliver non-neutral copy"
        }
        log.info(
            "deliver[{}] to={} body=\"{}\" link={} dedupe={}",
            name, request.recipientUserId, request.body, request.deepLink, request.dedupeKey,
        )
    }
}
