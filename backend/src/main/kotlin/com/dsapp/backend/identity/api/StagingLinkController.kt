package com.dsapp.backend.identity.api

import com.dsapp.backend.identity.infrastructure.StagingMagicLinkSender
import org.springframework.context.annotation.Profile
import org.springframework.http.CacheControl
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

/**
 * Hands the most recent magic link back to the caller.
 *
 * Staging has no email sender, so a tester on a phone cannot reach the link
 * that gets written to a restricted file on the host. This endpoint closes
 * that gap so the client can complete a real sign-in without the tester
 * having to copy a credential around by hand.
 *
 * **This is a full authentication bypass for any address it is asked about.**
 * It is therefore:
 *   - `@Profile("staging")` — it does not exist in the bean graph otherwise,
 *     so a production build cannot serve it even by misconfiguration;
 *   - refusing to start under `prod` alone (see [StagingOnlyGuard]).
 *
 * It does not weaken PKCE: the returned link still only completes on the
 * device whose verifier produced the challenge.
 */
@RestController
@RequestMapping("/v1/staging")
@Profile("staging")
class StagingLinkController(private val sender: StagingMagicLinkSender) {

    @GetMapping("/last-magic-link")
    fun lastLink(@RequestParam email: String): ResponseEntity<Map<String, String?>> =
        ResponseEntity.ok()
            .cacheControl(CacheControl.noStore())
            .body(mapOf("url" to sender.lastLinkFor(email)))
}
