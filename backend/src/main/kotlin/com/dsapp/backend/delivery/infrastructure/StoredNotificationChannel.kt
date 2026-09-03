package com.dsapp.backend.delivery.infrastructure

import com.dsapp.backend.delivery.domain.EventCopy
import com.dsapp.backend.delivery.domain.NotificationChannel
import com.dsapp.backend.delivery.domain.NotificationRequest
import org.jooq.DSLContext
import org.springframework.stereotype.Component
import java.util.UUID

/**
 * Durable in-app inbox: one row per recipient for every dispatched outbox
 * event, so the client can show a notification list/unread-count beyond
 * whatever a push provider delivered.
 *
 * Runs alongside [LoggingNotificationChannel] (both are `NotificationChannel`
 * beans; `OutboxDispatcher` iterates every one). Unlike the push/email path,
 * this is allowed to carry the real title/body — [EventCopy] — because it
 * only ever renders inside the app, to the person it is addressed to, never
 * to a lockscreen or a third party.
 */
@Component
class StoredNotificationChannel(private val dsl: DSLContext) : NotificationChannel {

    override val name = "stored"

    override fun send(request: NotificationRequest) {
        val copy = EventCopy.forEventType(request.eventType)
        dsl.query(
            """
            INSERT INTO notifications
                (id, user_id, dynamic_id, event_type, title, body, neutral_body, deep_link, outbox_id)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})
            """.trimIndent(),
            UUID.randomUUID(), request.recipientUserId, request.dynamicId, request.eventType,
            copy.title, copy.body, request.body, request.deepLink, request.outboxId,
        ).execute()
    }
}
