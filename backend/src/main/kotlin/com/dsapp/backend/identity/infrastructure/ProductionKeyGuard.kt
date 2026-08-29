package com.dsapp.backend.identity.infrastructure

import com.dsapp.backend.identity.domain.AuthProperties
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.annotation.Profile
import org.springframework.context.event.EventListener
import org.springframework.stereotype.Component

/**
 * Refuses to run in production with an ephemeral signing key.
 *
 * Notion 04 §2 requires durable sessions with a clear expiry. An ephemeral key
 * silently signs everyone out on every restart — a reliability failure, and
 * reliability here is relationship trust (Notion 01 §2.5).
 */
@Component
@Profile("prod")
class ProductionKeyGuard(private val properties: AuthProperties) {

    @EventListener(ApplicationReadyEvent::class)
    fun verify() {
        require(properties.privateKeyBase64.isNotBlank() && properties.publicKeyBase64.isNotBlank()) {
            "dsapp.auth.private-key-base64 and public-key-base64 must be set in production"
        }
    }
}
