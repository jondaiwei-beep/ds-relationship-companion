package com.dsapp.backend.shared.config

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.stereotype.Component

/**
 * The switches Core Beta must be able to throw without a deploy
 * (Notion 06 §9).
 *
 * Deliberately a short, closed list. A general flag framework is on the
 * "do not build early" list (06 §11), and every flag is a branch that has to
 * be reasoned about forever.
 *
 * **Safety and access revocation are never behind a flag.** Leave, Block,
 * privacy defaults and authorization have no switch here and must not gain
 * one — a kill switch that can disable a safety control is a safety defect.
 */
@Component
@ConfigurationProperties(prefix = "dsapp.features")
class FeatureFlags {
    /**
     * Web Push. Off by default: Notion 04 §6 permits feature-flagging it in
     * Core Beta, and the stable fallback is the invite/magic-link email.
     */
    var webPush: Boolean = false

    /** Explore's placeholder suggestions. */
    var explorePlaceholder: Boolean = true

    /** Optional analytics experiments, distinct from domain events. */
    var analyticsExperiments: Boolean = false
}
