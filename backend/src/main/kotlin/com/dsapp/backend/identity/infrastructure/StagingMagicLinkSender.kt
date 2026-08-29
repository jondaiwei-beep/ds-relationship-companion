package com.dsapp.backend.identity.infrastructure

import com.dsapp.backend.identity.application.MagicLinkSender
import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Profile
import org.springframework.stereotype.Component
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.StandardOpenOption
import java.time.Instant

/**
 * Staging sender: writes the link to a restricted file instead of emailing.
 *
 * Real email delivery arrives with the outbox/DeliveryIntent worker in
 * Milestone 4A. Until then this keeps the invited-partner flow testable on a
 * real device without an email provider.
 *
 * Deliberately NOT the application log: a magic link is a credential, and
 * `app.log` is read casually during deploys. The file is written 0600 and is
 * never served by nginx.
 *
 * `staging` profile only — production still fails to start without a real
 * sender, which is the intended safety behaviour.
 */
@Component
@Profile("staging")
class StagingMagicLinkSender : MagicLinkSender {

    private val log = LoggerFactory.getLogger(StagingMagicLinkSender::class.java)
    private val sink: Path = Path.of("/opt/applications/dsapp/magic-links.txt")

    override fun send(email: String, url: String) {
        // The address is logged so a tester knows a link was issued; the URL,
        // which is the credential, goes only to the restricted file.
        log.info("Magic link issued for {} (written to {})", email, sink.fileName)
        runCatching {
            Files.writeString(
                sink,
                "${Instant.now()}\t$email\t$url\n",
                StandardOpenOption.CREATE,
                StandardOpenOption.APPEND,
            )
            Files.setPosixFilePermissions(
                sink,
                java.nio.file.attribute.PosixFilePermissions.fromString("rw-------"),
            )
        }.onFailure { log.error("Could not write magic link sink", it) }
        synchronized(latest) { latest[email.lowercase()] = url }
    }

    /** Most recent link issued for [email], if this process issued one. */
    fun lastLinkFor(email: String): String? =
        synchronized(latest) { latest[email.lowercase()] }

    // In memory only: a magic link is a credential and this map must not
    // outlive the process or reach any other surface.
    private val latest = mutableMapOf<String, String>()
}
