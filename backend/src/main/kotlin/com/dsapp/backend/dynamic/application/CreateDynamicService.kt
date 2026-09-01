package com.dsapp.backend.dynamic.application

import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

/**
 * Minimal Dynamic setup — Journey A2 (Notion 02).
 *
 * Collects only: mode, desired outcome, structure level. Timezone is
 * auto-detected by the client. Nothing else is asked before the user sees a
 * Starter Rhythm.
 */
@Service
class CreateDynamicService(
    private val dsl: DSLContext,
    private val events: RelationshipEventWriter,
) {
    data class Created(val dynamicId: UUID, val membershipId: UUID)

    @Transactional
    fun create(
        actorUserId: UUID,
        mode: String,
        desiredOutcome: String,
        structureLevel: String,
        referenceTimezone: String,
        dayBoundaryMinutes: Int = 0,
        /**
         * How this member describes their role, as a starting point
         * (Notion 03 §2). Optional: a couple that does not want to name it
         * is never blocked, and it grants nothing — authorization uses
         * role_context, never this.
         */
        rolePreset: String? = null,
        /** Couple is apart. Changes what is seeded, never what is permitted. */
        longDistance: Boolean = false,
    ): Created {
        if (rolePreset != null &&
            rolePreset !in setOf("DOMINANT", "SUBMISSIVE", "SWITCH", "CUSTOM")
        ) {
            throw IllegalArgumentException("unknown role preset")
        }
        val dynamicId = UUID.randomUUID()
        val membershipId = UUID.randomUUID()

        // Couple dynamics wait for the partner; solo is immediately active.
        val initialState = if (mode == "COUPLE") "PENDING_PARTNER" else "ACTIVE"

        dsl.query(
            """
            INSERT INTO dynamics (id, mode, desired_outcome, structure_level, state,
                                  reference_timezone, day_boundary_minutes, long_distance)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7})
            """.trimIndent(),
            dynamicId, mode, desiredOutcome, structureLevel, initialState,
            referenceTimezone, dayBoundaryMinutes, longDistance,
        ).execute()

        dsl.query(
            """
            INSERT INTO memberships (id, user_id, dynamic_id, role_context,
                                     role_preset, access_state)
            VALUES ({0}, {1}, {2}, 'CREATOR', {3}, 'ACTIVE')
            """.trimIndent(),
            membershipId, actorUserId, dynamicId, rolePreset,
        ).execute()

        events.append(dynamicId, actorUserId, "dynamic_created", """{"dynamic_id":"$dynamicId"}""")
        return Created(dynamicId, membershipId)
    }
}
