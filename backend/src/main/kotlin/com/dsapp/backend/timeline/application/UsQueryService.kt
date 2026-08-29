package com.dsapp.backend.timeline.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/**
 * Us — recent relationship events (Notion 02 §8, 01 §6 "Reality fit").
 *
 * Core Beta shows recent history only. No SavedMoment, no complex private
 * reflection, no 30/90-day analytics, no relationship score (Notion 03 §3).
 *
 * Only events where a REAL PERSON acted are shown. System-generated events
 * (an occurrence activating on schedule) are not connection, and counting them
 * as such would inflate the very signal the product exists to measure
 * (Notion 07 §1).
 */
@Service
class UsQueryService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
) {
    data class RelationshipMoment(
        val eventType: String,
        val actorDisplayName: String?,
        val occurredAt: Instant,
        val title: String?,
        /** Present only for a human acknowledgement — their words, verbatim. */
        val text: String?,
    )

    data class Us(
        val moments: List<RelationshipMoment>,
        /** Days on which BOTH members produced a meaningful event. */
        val connectedDays: Int,
    )

    /** Human-authored events only. Excludes `occurrence_activated` by design. */
    private val humanEvents = listOf(
        "completion_submitted", "acknowledgement_sent",
        "adjustment_requested", "adjustment_resolved",
        "checkin_created", "member_joined",
    )

    @Transactional(readOnly = true)
    fun forDynamic(actorUserId: UUID, dynamicId: UUID, limit: Int = 20): Us {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))

        val moments = dsl.fetch(
            """
            SELECT e.event_type, e.occurred_at, u.display_name,
                   d.title,
                   a.text AS ack_text
              FROM relationship_events e
              LEFT JOIN users u ON u.id = e.actor_user_id
              LEFT JOIN occurrences o
                     ON o.id = NULLIF(CAST(e.object_ref AS jsonb)->>'occurrence_id','')::uuid
              LEFT JOIN expectation_definitions d ON d.id = o.definition_id
              LEFT JOIN acknowledgements a
                     ON a.id = NULLIF(CAST(e.object_ref AS jsonb)->>'acknowledgement_id','')::uuid
             WHERE e.dynamic_id = {0}
               AND e.event_type = ANY({1})
             ORDER BY e.occurred_at DESC
             LIMIT {2}
            """.trimIndent(),
            dynamicId, humanEvents.toTypedArray(), limit,
        ).map {
            RelationshipMoment(
                eventType = it.get("event_type", String::class.java),
                actorDisplayName = it.get("display_name", String::class.java),
                occurredAt = it.get("occurred_at", Instant::class.java),
                title = it.get("title", String::class.java),
                text = it.get("ack_text", String::class.java),
            )
        }

        // North Star (Notion 07 §1): a Connected Dynamic Day requires TWO
        // different members to have acted on the same day. One person being
        // busy alone is not connection.
        val connected = dsl.fetchOne(
            """
            SELECT count(*) AS n FROM (
                SELECT date_trunc('day', e.occurred_at) AS d
                  FROM relationship_events e
                 WHERE e.dynamic_id = {0}
                   AND e.actor_user_id IS NOT NULL
                   AND e.event_type = ANY({1})
                 GROUP BY 1
                HAVING count(DISTINCT e.actor_user_id) >= 2
            ) x
            """.trimIndent(),
            dynamicId, humanEvents.toTypedArray(),
        )!!.get("n", Int::class.java)

        return Us(moments = moments, connectedDays = connected)
    }
}
