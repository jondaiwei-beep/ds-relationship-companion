package com.dsapp.backend.notifications.application

import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/**
 * The stored notification inbox — a durable record written by
 * `StoredNotificationChannel` for every dispatched outbox event.
 *
 * Muting a type is a client-side signal only (never suppressed server-side):
 * the row still lands here so the record of what happened is never dropped,
 * the client just knows not to alert on it.
 */
@Service
class NotificationQueryService(private val dsl: DSLContext) {

    data class NotificationView(
        val id: UUID,
        val dynamicId: UUID,
        val eventType: String,
        val title: String,
        val body: String,
        val neutralBody: String,
        val deepLink: String,
        val createdAt: Instant,
        val readAt: Instant?,
        val muted: Boolean,
    )

    data class ListResult(val items: List<NotificationView>, val unreadCount: Int)

    @Transactional(readOnly = true)
    fun list(userId: UUID, since: Instant?, limit: Int): ListResult {
        val muted = mutedTypes(userId)
        val cappedLimit = limit.coerceIn(1, 200)
        val items = dsl.fetch(
            """
            SELECT id, dynamic_id, event_type, title, body, neutral_body, deep_link, created_at, read_at
              FROM notifications
             WHERE user_id = {0}
               AND (CAST({1} AS timestamptz) IS NULL OR created_at > {1})
             ORDER BY created_at DESC
             LIMIT {2}
            """.trimIndent(),
            userId, since, cappedLimit,
        ).map {
            val eventType = it.get("event_type", String::class.java)
            NotificationView(
                id = it.get("id", UUID::class.java),
                dynamicId = it.get("dynamic_id", UUID::class.java),
                eventType = eventType,
                title = it.get("title", String::class.java),
                body = it.get("body", String::class.java),
                neutralBody = it.get("neutral_body", String::class.java),
                deepLink = it.get("deep_link", String::class.java),
                createdAt = it.get("created_at", Instant::class.java),
                readAt = it.get("read_at", Instant::class.java),
                muted = eventType in muted,
            )
        }
        return ListResult(items, unreadCount(userId))
    }

    @Transactional(readOnly = true)
    fun unreadCount(userId: UUID): Int =
        dsl.fetchOne(
            "SELECT count(*) AS n FROM notifications WHERE user_id = {0} AND read_at IS NULL",
            userId,
        )!!.get("n", Int::class.java)

    /** Marks explicit ids, or everything up to a cutoff, read. Either or both may be given. */
    @Transactional
    fun markRead(userId: UUID, ids: List<UUID>?, allBefore: Instant?): Int {
        var updated = 0
        if (!ids.isNullOrEmpty()) {
            updated += dsl.query(
                """
                UPDATE notifications SET read_at = COALESCE(read_at, now())
                 WHERE user_id = {0} AND id = ANY({1}) AND read_at IS NULL
                """.trimIndent(),
                userId, ids.toTypedArray(),
            ).execute()
        }
        if (allBefore != null) {
            updated += dsl.query(
                """
                UPDATE notifications SET read_at = COALESCE(read_at, now())
                 WHERE user_id = {0} AND created_at <= {1} AND read_at IS NULL
                """.trimIndent(),
                userId, allBefore,
            ).execute()
        }
        return updated
    }

    private fun mutedTypes(userId: UUID): Set<String> =
        dsl.fetchOne("SELECT muted_types FROM notification_settings WHERE user_id = {0}", userId)
            ?.get("muted_types", Array<String>::class.java)?.toSet() ?: emptySet()
}
