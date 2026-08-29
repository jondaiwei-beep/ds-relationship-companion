package com.dsapp.backend.identity.infrastructure

import com.dsapp.backend.identity.application.MagicLinkSender
import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Profile
import org.springframework.stereotype.Component

/**
 * Dev/test magic-link sender: writes the URL to the log instead of emailing.
 *
 * Real email delivery arrives with the outbox/DeliveryIntent worker in
 * Milestone 4A (Notion 06 §13.6). Until then this keeps the auth flow
 * end-to-end testable without an email provider.
 *
 * Never active under the `prod` profile — a production deployment without a
 * real sender must fail to start rather than silently log credentials.
 */
@Component
@Profile("!prod")
class LoggingMagicLinkSender : MagicLinkSender {

    private val log = LoggerFactory.getLogger(LoggingMagicLinkSender::class.java)

    override fun send(email: String, url: String) {
        // Dev-only. Notion 04 §5 forbids sensitive content in real delivery,
        // and a magic link is a credential — this must never run in production.
        log.info("MAGIC LINK for {} -> {}", email, url)
    }
}
