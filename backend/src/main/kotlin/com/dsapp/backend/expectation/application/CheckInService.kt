package com.dsapp.backend.expectation.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.shared.time.RelationshipDay
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.util.UUID

enum class CheckInVisibility { PRIVATE, SHARED }

/**
 * Check-in — Notion 03 §2.
 *
 * "What context do I want to share?" A check-in is how someone says *I'm
 * low today, I can continue but gently* without it being a failure to report.
 *
 * PRIVACY (Notion 04 §3): visibility is explicit and enforced on READ. There
 * is no "you're in a dynamic so it's obviously shared" default, and a private
 * check-in never produces a shared timeline event or a notification.
 */
@Service
class CheckInService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {
    data class CheckIn(
        val id: UUID,
        val relationshipDay: LocalDate,
        val mood: String?,
        val energy: String?,
        val need: String?,
        val note: String?,
        val visibility: String,
        val createdAt: Instant,
        val creatorDisplayName: String?,
        /** True when the viewer wrote it. Only then may it be edited. */
        val isMine: Boolean,
    )

    @Transactional
    fun create(
        actorUserId: UUID,
        dynamicId: UUID,
        mood: String?,
        energy: String?,
        need: String?,
        note: String?,
        visibility: CheckInVisibility,
    ): UUID {
        val ctx = authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))

        val d = dsl.fetchOne(
            "SELECT reference_timezone, day_boundary_minutes FROM dynamics WHERE id = {0}",
            dynamicId,
        )!!
        // The relationship day comes from the Dynamic's own zone and boundary.
        val day = RelationshipDay.dayOf(
            instant = Instant.now(),
            zone = ZoneId.of(d.get("reference_timezone", String::class.java)),
            boundaryMinutes = d.get("day_boundary_minutes", Int::class.java),
        )

        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO check_ins
                (id, dynamic_id, creator_user_id, relationship_day, mood, energy, need, note, visibility)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})
            """.trimIndent(),
            id, dynamicId, actorUserId, day, mood, energy, need, note, visibility.name,
        ).execute()

        // A PRIVATE check-in produces no shared event and no delivery. Writing
        // one must not quietly tell the partner that something was written.
        if (visibility == CheckInVisibility.SHARED) {
            events.append(
                ctx.dynamicId, actorUserId, "checkin_shared", """{"check_in_id":"$id"}""",
            )
            events.enqueueOutbox("dynamic", dynamicId, "checkin_shared", "checkin:$id")
        } else {
            // Recorded for the author's own history only — object_ref carries
            // an id, never the note's content.
            events.append(
                ctx.dynamicId, actorUserId, "checkin_created", """{"check_in_id":"$id"}""",
            )
        }
        return id
    }

    /**
     * Recent check-ins the viewer is allowed to see.
     *
     * The privacy filter lives in the SQL, not in the UI: a private check-in
     * must be unreachable, not merely unrendered.
     */
    @Transactional(readOnly = true)
    fun recentFor(actorUserId: UUID, dynamicId: UUID, limit: Int = 10): List<CheckIn> {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))

        return dsl.fetch(
            """
            SELECT c.id, c.relationship_day, c.mood, c.energy, c.need, c.note,
                   c.visibility, c.created_at, u.display_name,
                   (c.creator_user_id = {1}) AS is_mine
              FROM check_ins c
              JOIN users u ON u.id = c.creator_user_id
             WHERE c.dynamic_id = {0}
               -- Either it is shared, or it is mine. Never someone else's private one.
               AND (c.visibility = 'SHARED' OR c.creator_user_id = {1})
             ORDER BY c.created_at DESC
             LIMIT {2}
            """.trimIndent(),
            dynamicId, actorUserId, limit,
        ).map {
            CheckIn(
                id = it.get("id", UUID::class.java),
                relationshipDay = it.get("relationship_day", LocalDate::class.java),
                mood = it.get("mood", String::class.java),
                energy = it.get("energy", String::class.java),
                need = it.get("need", String::class.java),
                note = it.get("note", String::class.java),
                visibility = it.get("visibility", String::class.java),
                createdAt = it.get("created_at", Instant::class.java),
                creatorDisplayName = it.get("display_name", String::class.java),
                isMine = it.get("is_mine", Boolean::class.java),
            )
        }
    }
}
