package com.dsapp.backend.delivery.application

import com.dsapp.backend.delivery.domain.NeutralCopy
import com.dsapp.backend.delivery.domain.NotificationChannel
import com.dsapp.backend.delivery.domain.NotificationRequest
import com.dsapp.backend.delivery.domain.SuppressionReason
import com.dsapp.backend.shared.time.RelationshipDay
import org.jooq.DSLContext
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.time.ZoneId
import java.util.UUID

/**
 * Outbox dispatcher — Notion 04 §6/§7/§8, 06 §4.
 *
 * The business transaction is already committed; delivery happens strictly
 * afterwards, and **provider success or failure never changes business truth**.
 *
 * Every claimed record is re-checked immediately before sending, because the
 * world moves between enqueue and send: the recipient may have left, the thing
 * may already be acknowledged, or quiet hours may have begun.
 */
@Service
class OutboxDispatcher(
    private val dsl: DSLContext,
    private val channels: List<NotificationChannel>,
) {
    private val log = LoggerFactory.getLogger(OutboxDispatcher::class.java)

    companion object {
        const val LEASE_SECONDS = 60L
        const val MAX_ATTEMPTS = 5
        const val BATCH = 20
    }

    data class Claimed(
        val id: UUID,
        val aggregateType: String,
        val aggregateId: UUID,
        val eventType: String,
        val dedupeKey: String,
        val attempts: Int,
        /** True when this one stands for a whole quiet window's backlog. */
        val aggregated: Boolean = false,
    )

    /**
     * Claim due work with a lease.
     *
     * `FOR UPDATE SKIP LOCKED` lets several dispatchers run without contending.
     * The lease is what makes a dispatcher crash recoverable: if the process
     * dies mid-send, `locked_until` simply expires and another dispatcher
     * picks the row up. That is also why sends must be idempotent at the
     * provider — a crash after the provider accepted but before we marked SENT
     * will be retried.
     */
    @Transactional
    fun claim(now: Instant = Instant.now()): List<Claimed> =
        dsl.fetch(
            """
            UPDATE outbox_records SET locked_until = {0}, attempts = attempts + 1
             WHERE id IN (
                SELECT id FROM outbox_records
                 WHERE state = 'PENDING'
                   AND not_before <= {1}
                   AND (locked_until IS NULL OR locked_until < {1})
                 ORDER BY not_before, created_at, id
                 FOR UPDATE SKIP LOCKED
                 LIMIT {2}
             )
            RETURNING id, aggregate_type, aggregate_id, event_type, dedupe_key,
                      attempts, aggregated
            """.trimIndent(),
            now.plusSeconds(LEASE_SECONDS), now, BATCH,
        ).map {
            Claimed(
                it.get("id", UUID::class.java),
                it.get("aggregate_type", String::class.java),
                it.get("aggregate_id", UUID::class.java),
                it.get("event_type", String::class.java),
                it.get("dedupe_key", String::class.java),
                it.get("attempts", Int::class.java),
                it.get("aggregated", Boolean::class.java),
            )
        }

    /** One dispatch pass. Called on a schedule; safe to run concurrently. */
    fun dispatchOnce(now: Instant = Instant.now()): Int {
        collapseQuietHoursBacklog(now)
        var sent = 0
        for (record in claim(now)) {
            runCatching { process(record, now) }
                .onSuccess { if (it) sent++ }
                .onFailure { fail(record, it) }
        }
        return sent
    }

    /**
     * @return true when something was actually handed to a channel.
     *
     * Runs inside a transaction holding the per-Dynamic delivery fence in
     * SHARED mode. Leave/Block takes the same lock EXCLUSIVELY, so once it
     * commits no dispatcher can get past the access re-check below. Cancelling
     * outbox rows alone would not close that window: a dispatcher could
     * already have checked access and be about to call the provider.
     */
    @Transactional
    fun process(record: Claimed, now: Instant): Boolean {
        val recipient = recipientFor(record) ?: run {
            suppress(record, SuppressionReason.STALE); return false
        }

        // Take the shared fence BEFORE the authorization re-check, and hold it
        // through the provider call (G-1).
        dsl.fetchOne("SELECT pg_advisory_xact_lock_shared({0})", recipient.dynamicId.mostSignificantBits)

        // --- re-check 1: access. LEFT or BLOCKED cuts delivery immediately,
        // and must not wait for a client refresh (Notion 04 §8).
        if (!hasAccess(recipient.userId, recipient.dynamicId)) {
            suppress(record, SuppressionReason.NO_ACCESS); return false
        }

        // --- re-check 2: the dynamic itself must be live.
        if (!dynamicActive(recipient.dynamicId)) {
            suppress(record, SuppressionReason.DYNAMIC_INACTIVE); return false
        }

        // --- re-check 3: is this still true? Never send a reminder about
        // something the partner has already responded to.
        if (isStale(record)) {
            suppress(record, SuppressionReason.STALE); return false
        }

        // --- re-check 4: quiet hours DELAY delivery; they never drop the
        // domain event, and they never replay a backlog later.
        val until = quietUntil(recipient.userId, now)
        if (until != null) {
            defer(record, until); return false
        }

        // Constructed from constants and locating IDs only. The event payload
        // is deliberately NOT consulted here — that is the leak vector.
        val request = NotificationRequest(
            recipientUserId = recipient.userId,
            // One summary when several waited out the window; the specific
            // neutral line only when this is the single thing to say.
            body = if (record.aggregated) {
                NeutralCopy.WHILE_YOU_WERE_AWAY
            } else {
                neutralBodyFor(record.eventType)
            },
            deepLink = "/occurrences/${record.aggregateId}",
            dedupeKey = record.dedupeKey,
        )
        require(request.body in NeutralCopy.all) { "non-neutral notification copy" }

        channels.forEach { it.send(request) }
        markSent(record)
        return true
    }

    // ---- re-check helpers -------------------------------------------------

    private data class Recipient(val userId: UUID, val dynamicId: UUID)

    /**
     * Who should hear about this, resolved from CURRENT state.
     *
     * The notification goes to the OTHER member — the person who did the thing
     * does not need telling that they did it.
     */
    private fun recipientFor(record: Claimed): Recipient? {
        val row = dsl.fetchOne(
            """
            SELECT o.dynamic_id,
                   CASE WHEN {1} = 'acknowledgement_sent' THEN c.actor_user_id
                        ELSE d.creator_user_id END AS recipient
              FROM occurrences o
              JOIN expectation_definitions d ON d.id = o.definition_id
              LEFT JOIN occurrence_completions c ON c.occurrence_id = o.id
             WHERE o.id = {0}
            """.trimIndent(),
            record.aggregateId, record.eventType,
        ) ?: return null
        val user = row.get("recipient", UUID::class.java) ?: return null
        return Recipient(user, row.get("dynamic_id", UUID::class.java))
    }

    private fun hasAccess(userId: UUID, dynamicId: UUID): Boolean =
        dsl.fetchOne(
            """SELECT 1 FROM memberships
                WHERE user_id = {0} AND dynamic_id = {1} AND access_state = 'ACTIVE'""",
            userId, dynamicId,
        ) != null

    private fun dynamicActive(dynamicId: UUID): Boolean =
        dsl.fetchOne("SELECT 1 FROM dynamics WHERE id = {0} AND state = 'ACTIVE'", dynamicId) != null

    /** A completion notice is stale once an acknowledgement exists. */
    private fun isStale(record: Claimed): Boolean = when (record.eventType) {
        "completion_submitted" -> dsl.fetchOne(
            "SELECT 1 FROM acknowledgements WHERE occurrence_id = {0}", record.aggregateId,
        ) != null
        else -> false
    }

    /**
     * When quiet hours end for this user, or null if they are not in them.
     *
     * Uses the user's OWN IANA timezone — never the server's.
     */
    private fun quietUntil(userId: UUID, now: Instant): Instant? {
        val u = dsl.fetchOne(
            "SELECT timezone, quiet_hours_start_min, quiet_hours_end_min FROM users WHERE id = {0}",
            userId,
        ) ?: return null
        val start = u.get("quiet_hours_start_min", Int::class.javaObjectType) ?: return null
        val end = u.get("quiet_hours_end_min", Int::class.javaObjectType) ?: return null
        val zone = ZoneId.of(u.get("timezone", String::class.java))

        val local = now.atZone(zone)
        val minutes = local.hour * 60 + local.minute
        // A window may wrap midnight (e.g. 22:00 -> 07:00).
        val inQuiet = if (start <= end) minutes in start until end
                      else minutes >= start || minutes < end
        if (!inQuiet) return null

        val endToday = local.toLocalDate().atStartOfDay(zone).plusMinutes(end.toLong())
        val target = if (endToday.toInstant() > now) endToday else endToday.plusDays(1)
        return RelationshipDay.resolve(target.toLocalDateTime(), zone)
    }

    private fun neutralBodyFor(eventType: String): String = when (eventType) {
        "completion_submitted", "adjustment_requested" -> NeutralCopy.NEEDS_ATTENTION
        else -> NeutralCopy.GENERIC
    }

    // ---- state transitions ------------------------------------------------

    private fun markSent(record: Claimed) {
        dsl.query(
            "UPDATE outbox_records SET state='SENT', sent_at=now(), locked_until=NULL WHERE id={0}",
            record.id,
        ).execute()
    }

    private fun suppress(record: Claimed, reason: SuppressionReason) {
        // CANCELLED, not FAILED: nothing went wrong. The delivery simply
        // should not happen, and that is a normal outcome worth observing.
        dsl.query(
            "UPDATE outbox_records SET state='CANCELLED', locked_until=NULL, last_error={1} WHERE id={0}",
            record.id, "suppressed:${reason.name}",
        ).execute()
        log.info("delivery suppressed {} {} {}", record.eventType, record.aggregateId, reason)
    }

    /** Quiet hours delay; the record stays PENDING and is retried later. */
    /**
     * When a quiet window ends, collapse everything that waited it out into
     * one message per person.
     *
     * Notion 04 Section 7 forbids replaying the backlog: waking to six
     * notifications about a night that has already passed is worse than
     * having been left alone, and each would point at something the person
     * may already have dealt with.
     *
     * Runs before claiming, because once records are claimed each one looks
     * like the only thing there is.
     *
     * `deferred_until` is set solely by quiet hours. Retry backoff moves
     * `not_before` too, so aggregating on that would silently hide an
     * ordinary burst of daytime activity behind one vague line.
     */
    private fun collapseQuietHoursBacklog(now: Instant) {
        val waited = dsl.fetch(
            """
            SELECT id, aggregate_type, aggregate_id, event_type, dedupe_key
              FROM outbox_records
             WHERE state = 'PENDING'
               AND deferred_until IS NOT NULL
               AND deferred_until <= {0}
             ORDER BY created_at
            """.trimIndent(),
            now,
        ).map {
            Claimed(
                id = it.get("id", UUID::class.java),
                aggregateType = it.get("aggregate_type", String::class.java),
                aggregateId = it.get("aggregate_id", UUID::class.java),
                eventType = it.get("event_type", String::class.java),
                dedupeKey = it.get("dedupe_key", String::class.java),
                attempts = 0,
            )
        }
        if (waited.size < 2) return

        // Group by the person who would be told, not by dynamic: one person
        // should get one message even across several dynamics.
        waited.groupBy { recipientFor(it)?.userId }
            .forEach { (userId, group) ->
                if (userId == null || group.size < 2) return@forEach
                // Keep the oldest and mark it as standing for the rest.
                val keep = group.first()
                val drop = group.drop(1).map { it.id }
                dsl.query(
                    """
                    UPDATE outbox_records
                       SET state = 'CANCELLED', last_error = 'AGGREGATED',
                           locked_until = NULL
                     WHERE id = ANY({0})
                    """.trimIndent(),
                    drop.toTypedArray(),
                ).execute()
                dsl.query(
                    "UPDATE outbox_records SET aggregated = true WHERE id = {0}",
                    keep.id,
                ).execute()
                log.info(
                    "Collapsed {} deferred notifications into one after quiet hours",
                    group.size,
                )
            }
    }

    private fun defer(record: Claimed, until: Instant) {
        dsl.query(
            """UPDATE outbox_records
                  SET not_before = {1}, deferred_until = {1},
                      locked_until = NULL, attempts = attempts - 1
                WHERE id = {0}""",
            record.id, until,
        ).execute()
    }

    private fun fail(record: Claimed, error: Throwable) {
        // Provider failure NEVER changes business truth (Notion 04 §6): the
        // completion still happened, we just could not tell anyone yet.
        val terminal = record.attempts >= MAX_ATTEMPTS
        dsl.query(
            """UPDATE outbox_records
                  SET state = {1}, locked_until = NULL,
                      not_before = {2}, last_error = {3}
                WHERE id = {0}""",
            record.id,
            if (terminal) "FAILED" else "PENDING",
            // Exponential backoff: 1, 2, 4, 8, 16 minutes.
            Instant.now().plusSeconds(60L * (1L shl minOf(record.attempts, 4))),
            (error.message ?: error::class.simpleName ?: "unknown").take(500),
        ).execute()
        if (terminal) {
            log.error("delivery permanently failed {} {}", record.id, error.message)
        }
    }
}
