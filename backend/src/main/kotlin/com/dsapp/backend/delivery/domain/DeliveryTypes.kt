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
    /**
     * Locating information only, same discipline as everything else here —
     * lets a channel that stores its own record (an in-app inbox, never a
     * push/email provider) resolve richer copy without touching the event
     * payload itself.
     */
    val dynamicId: UUID,
    val eventType: String,
    /** The outbox record this delivery came from, for traceability. */
    val outboxId: UUID,
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

/**
 * Real, richer copy for the in-app notification list — never for a push
 * provider or a lockscreen (that is [NeutralCopy]'s job exclusively).
 *
 * Still deliberately generic: it names what kind of thing happened
 * ("delivered", "an answer", "a reward") but never the content of a task,
 * rule, proof or note. That keeps it safe to show on the *other* side's
 * device too (Notion 04 §5/§6) — nothing here is one partner speaking as the
 * system, and nothing here is a private note leaking across sides.
 *
 * Closed by event type, same discipline as [NeutralCopy]: a new event type
 * must add an entry here rather than have a caller invent a string.
 */
object EventCopy {
    data class Copy(val title: String, val body: String)

    private val entries: Map<String, Copy> = mapOf(
        "occurrence_delivered" to Copy("Delivered", "Something was marked delivered."),
        "occurrence_flagged" to Copy("An update", "There is an update on something today."),
        "disposition_set" to Copy("An answer", "There is an answer waiting for you."),
        "day_comment" to Copy("A note", "A note was left on a day."),
        "rule_proposed" to Copy("A proposal", "Something was proposed for you to decide."),
        "rule_accepted" to Copy("Accepted", "Your proposal was accepted."),
        "task_proposed" to Copy("A proposal", "Something was proposed for you to decide."),
        "task_accepted" to Copy("Accepted", "Your proposal was accepted."),
        "redemption_requested" to Copy("A request", "A reward was requested."),
        "redemption_decided" to Copy("Decided", "There is a decision on a request."),
        "redemption_fulfilled" to Copy("Fulfilled", "A reward was marked fulfilled."),
        "consequence_issued" to Copy("Something new", "Something was issued for you."),
        "consequence_done" to Copy("Marked done", "Something was marked done."),
        "consequence_decided" to Copy("Decided", "There is a decision waiting."),
        "d_award" to Copy("Points", "Points were awarded to you."),
        "d_note_reminder" to Copy("A reminder", "A reminder is due."),
    )

    /** Title/body for a known event type, or a generic fallback for anything not yet in [entries]. */
    fun forEventType(eventType: String): Copy =
        entries[eventType] ?: Copy("Update", NeutralCopy.GENERIC)

    /** Every event type this closed set currently has copy for. */
    val knownEventTypes: Set<String> = entries.keys
}
