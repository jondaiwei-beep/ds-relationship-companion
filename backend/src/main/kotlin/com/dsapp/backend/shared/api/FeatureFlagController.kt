package com.dsapp.backend.shared.api

import com.dsapp.backend.shared.config.FeatureFlags
import org.springframework.http.CacheControl
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

/**
 * Which optional surfaces are on right now.
 *
 * The client reads this rather than deciding for itself, so throwing a
 * switch takes effect without shipping an app build — which is the point of
 * having one (Notion 06 §9).
 *
 * Carries no user data and no relationship content, so it is safe to read
 * before a session exists.
 */
@RestController
@RequestMapping("/v1/features")
class FeatureFlagController(private val flags: FeatureFlags) {

    @GetMapping
    fun current(): ResponseEntity<Map<String, Boolean>> = ResponseEntity.ok()
        .cacheControl(CacheControl.noStore())
        .body(
            mapOf(
                "webPush" to flags.webPush,
                "explorePlaceholder" to flags.explorePlaceholder,
                "analyticsExperiments" to flags.analyticsExperiments,
            ),
        )
}
