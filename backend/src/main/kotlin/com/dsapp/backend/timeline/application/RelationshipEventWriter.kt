package com.dsapp.backend.timeline.application

import org.jooq.DSLContext
import org.springframework.stereotype.Service
import java.util.UUID

/**
 * Appends immutable history (Notion 03 §2) and the paired outbox envelope
 * (Notion 06 §4) inside the caller's transaction.
 *
 * Deliberately has NO acknowledgement writer. Product red line #2: nothing that
 * consumes an event may create an Acknowledgement — only an explicit human send
 * through the acknowledgement command can.
 */
@Service
class RelationshipEventWriter(private val dsl: DSLContext) {

    fun append(
        dynamicId: UUID,
        actorUserId: UUID?,
        eventType: String,
        objectRef: String,
        payloadJson: String = "{}",
    ) {
        dsl.query(
            """
            INSERT INTO relationship_events (actor_user_id, dynamic_id, event_type, object_ref, payload)
            VALUES ({0}, {1}, {2}, CAST({3} AS jsonb), CAST({4} AS jsonb))
            """.trimIndent(),
            actorUserId, dynamicId, eventType, objectRef, payloadJson,
        ).execute()
    }

    /**
     * Enqueue an async delivery.
     *
     * [dedupeKey] must be deterministic for the business action so a retry can
     * never double-send (Notion 04 §7). The unique constraint enforces it.
     *
     * Payload carries locating information only — never sensitive relationship
     * text (Notion 04 §6).
     */
    fun enqueueOutbox(
        aggregateType: String,
        aggregateId: UUID,
        eventType: String,
        dedupeKey: String,
        payloadJson: String = "{}",
    ) {
        dsl.query(
            """
            INSERT INTO outbox_records (aggregate_type, aggregate_id, event_type, payload, dedupe_key)
            VALUES ({0}, {1}, {2}, CAST({3} AS jsonb), {4})
            ON CONFLICT (dedupe_key) DO NOTHING
            """.trimIndent(),
            aggregateType, aggregateId, eventType, payloadJson, dedupeKey,
        ).execute()
    }
}
