package com.dsapp.backend.delivery.domain

import java.util.UUID

/** Why a queued delivery was not sent. Recorded for observability. */
enum class SuppressionReason {
    /** The recipient left or was blocked (Notion 04 §8). */
    NO_ACCESS,
    /** The thing being notified about is already resolved. */
    STALE,
    /** Inside the recipient's quiet hours (Notion 04 §7). */
    QUIET_HOURS,
    /** The dynamic is paused or ended. */
    DYNAMIC_INACTIVE,
}

/**
 * What the provider is actually given.
 *
 * PRIVACY (Notion 04 §5, §6): this carries LOCATING INFORMATION ONLY. The body
 * is chosen from a fixed set of neutral strings — it is never derived from
 * relationship content. The most likely way to leak intimate text to a
 * lockscreen is to spread an event payload into the provider request, so this
 * type exists specifically to make that impossible: there is nowhere to put it.
 */
data class NotificationRequest(
    val recipientUserId: UUID,
    /** Neutral copy only. See [NeutralCopy]. */
    val body: String,
    /** Where to go when tapped. The client re-resolves current state on open. */
    val deepLink: String,
    /** Provider-side idempotency. Same key must never send twice. */
    val dedupeKey: String,
)

/**
 * The complete set of user-visible notification strings.
 *
 * Notion 04 §5: the default lockscreen, email subject and browser title must
 * never reveal Dom/sub, a task title, a rule, proof, or punishment/reward.
 * Keeping this a closed enum means new event types cannot invent copy.
 */
object NeutralCopy {
    const val GENERIC = "You have a new update."
    const val NEEDS_ATTENTION = "Something needs your attention."

    /**
     * Sent once when quiet hours end, in place of everything that waited.
     *
     * Notion 04 Section 7 forbids replaying the backlog: waking to six
     * notifications about a night that has already passed is worse than
     * having been left alone. Deliberately carries no count either - a
     * number is pressure, and it would leak how much happened.
     */
    const val WHILE_YOU_WERE_AWAY = "There is something waiting for you."

    /** Every value a provider may ever receive as a body. */
    val all = setOf(GENERIC, NEEDS_ATTENTION, WHILE_YOU_WERE_AWAY)
}

/** Pluggable channel. Android push, web push and email each implement this. */
interface NotificationChannel {
    val name: String

    /** Must throw on failure so the dispatcher can retry. */
    fun send(request: NotificationRequest)
}
