package com.dsapp.backend.dynamic.application

import com.dsapp.backend.dynamic.domain.RoleContext
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

class DynamicNotPausable(val state: String) :
    RuntimeException("Dynamic is $state")

class InvalidDynamicSettings(message: String) : IllegalArgumentException(message)

/**
 * Dynamic — the relationship's current shape (Notion 02 §10).
 *
 * Core Beta shows ONLY: partner/role context, current recurring structure,
 * basic settings, Pause/Resume, and the Privacy/Leave/Block entry points.
 *
 * Agreement, Rules, a permissions matrix and subscription are deliberately
 * absent: we prove two people use the loop daily before building governance.
 */
@Service
class DynamicQueryService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {
    data class MemberView(
        /**
         * Needed so the client can address an expectation to a person.
         * Without it there is no way to set one from the app at all.
         */
        val userId: UUID,
        val displayName: String?,
        val roleContext: String,
        /** How they describe their role. Never used for authorization. */
        val rolePreset: String?,
        /** D disposes, S delivers (product/03-domain.md). */
        val side: String,
        val accessState: String,
    )

    data class StructureItem(val taskId: UUID, val kind: String, val title: String, val active: Boolean)

    data class DynamicDetail(
        val dynamicId: UUID,
        val state: String,
        val desiredOutcome: String,
        val structureLevel: String,
        val referenceTimezone: String,
        val dayBoundaryMinutes: Int,
        val pausedAt: Instant?,
        val members: List<MemberView>,
        val structure: List<StructureItem>,
        /** Agency that no role can ever remove (Notion 03 §2). */
        val alwaysAvailable: List<String>,
        /** D「我不在」until this instant, or null when the D is present. */
        val dAwayUntil: Instant?,
        /** How the s addresses the D, and vice versa. Null means "use the display name" (product/02-surfaces.md). */
        val honorificForD: String?,
        val honorificForS: String?,
        val safeword: String?,
    )

    @Transactional(readOnly = true)
    data class DynamicSummary(
        val dynamicId: UUID,
        val state: String,
        val roleContext: String,
        /** The other person, so the chooser names a human not an id. */
        val partnerDisplayName: String?,
    )

    /**
     * Every dynamic this person still belongs to.
     *
     * Without this the client cannot find out which dynamic it is in, so a
     * member who did not arrive through an invite link has nowhere to go
     * after signing in. Every other screen is addressed by `:id`.
     *
     * LEFT and BLOCKED memberships are excluded: separation means the
     * dynamic stops being somewhere you can go back to.
     */
    @Transactional(readOnly = true)
    fun forUser(actorUserId: UUID): List<DynamicSummary> = dsl.fetch(
        """
        SELECT d.id, d.state, m.role_context,
               (SELECT u.display_name
                  FROM memberships om
                  JOIN users u ON u.id = om.user_id
                 WHERE om.dynamic_id = d.id
                   AND om.user_id <> {0}
                   AND om.access_state = 'ACTIVE'
                 LIMIT 1) AS partner_name
          FROM memberships m
          JOIN dynamics d ON d.id = m.dynamic_id
         WHERE m.user_id = {0}
           AND m.access_state = 'ACTIVE'
         ORDER BY d.created_at
        """.trimIndent(),
        actorUserId,
    ).map {
        DynamicSummary(
            dynamicId = it.get("id", UUID::class.java),
            state = it.get("state", String::class.java),
            roleContext = it.get("role_context", String::class.java),
            partnerDisplayName = it.get("partner_name", String::class.java),
        )
    }

    fun detail(actorUserId: UUID, dynamicId: UUID): DynamicDetail {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))

        val d = dsl.fetchOne(
            """
            SELECT state, desired_outcome, structure_level, reference_timezone,
                   day_boundary_minutes, paused_at, d_away_until,
                   honorific_for_d, honorific_for_s, safeword
              FROM dynamics WHERE id = {0}
            """.trimIndent(),
            dynamicId,
        )!!

        val members = dsl.fetch(
            """
            SELECT u.id AS user_id, u.display_name, m.role_context,
                   m.role_preset, m.side, m.access_state
              FROM memberships m JOIN users u ON u.id = m.user_id
             WHERE m.dynamic_id = {0} ORDER BY m.joined_at
            """.trimIndent(),
            dynamicId,
        ).map {
            MemberView(
                it.get("user_id", UUID::class.java),
                it.get("display_name", String::class.java),
                it.get("role_context", String::class.java),
                it.get("role_preset", String::class.java),
                it.get("side", String::class.java),
                it.get("access_state", String::class.java),
            )
        }

        val structure = dsl.fetch(
            """
            SELECT id, kind, title, status FROM tasks
             WHERE dynamic_id = {0} AND status <> 'archived' ORDER BY position, created_at
            """.trimIndent(),
            dynamicId,
        ).map {
            StructureItem(
                it.get("id", UUID::class.java),
                it.get("kind", String::class.java),
                it.get("title", String::class.java),
                it.get("status", String::class.java) == "active",
            )
        }

        return DynamicDetail(
            dynamicId = dynamicId,
            state = d.get("state", String::class.java),
            desiredOutcome = d.get("desired_outcome", String::class.java),
            structureLevel = d.get("structure_level", String::class.java),
            referenceTimezone = d.get("reference_timezone", String::class.java),
            dayBoundaryMinutes = d.get("day_boundary_minutes", Int::class.java),
            pausedAt = d.get("paused_at", Instant::class.java),
            members = members,
            structure = structure,
            // Listed explicitly so the UI can always show them, whatever the
            // role. These can never be switched off (Notion 04 §4).
            alwaysAvailable = listOf("discuss", "reschedule", "cant_do", "pause", "leave", "block"),
            dAwayUntil = d.get("d_away_until", Instant::class.java),
            honorificForD = d.get("honorific_for_d", String::class.java),
            honorificForS = d.get("honorific_for_s", String::class.java),
            safeword = d.get("safeword", String::class.java),
        )
    }

    /**
     * Settings — timezone, day boundary, honorifics, safeword. Partial
     * update: any field left null keeps its current value.
     *
     * Either side may edit any of these fields — a deliberate pre-launch
     * decision (owner 2026-09) not to gate this behind D/s, unlike most
     * mutations in this app.
     */
    @Transactional
    fun updateSettings(
        actorUserId: UUID,
        dynamicId: UUID,
        timezone: String?,
        dayBoundaryMinutes: Int?,
        honorificForD: String?,
        honorificForS: String?,
        safeword: String?,
    ): DynamicDetail {
        val ctx = authorizer.requireActive(authorizer.contextForDynamic(actorUserId, dynamicId))

        if (timezone != null) {
            try {
                java.time.ZoneId.of(timezone)
            } catch (e: java.time.DateTimeException) {
                throw InvalidDynamicSettings("timezone")
            }
        }
        if (dayBoundaryMinutes != null && dayBoundaryMinutes !in 0..1439) {
            throw InvalidDynamicSettings("dayBoundaryMinutes")
        }

        dsl.query(
            """
            UPDATE dynamics
               SET reference_timezone = COALESCE({1}, reference_timezone),
                   day_boundary_minutes = COALESCE({2}, day_boundary_minutes),
                   honorific_for_d = COALESCE({3}, honorific_for_d),
                   honorific_for_s = COALESCE({4}, honorific_for_s),
                   safeword = COALESCE({5}, safeword),
                   updated_at = now(), version = version + 1
             WHERE id = {0}
            """.trimIndent(),
            dynamicId, timezone, dayBoundaryMinutes, honorificForD, honorificForS, safeword,
        ).execute()

        // Visible to the partner via normal relationship-event visibility
        // (dynamic-scoped, not author-scoped) — same pattern as
        // dynamic_paused/dynamic_resumed above. No push notification: this is
        // a quiet settings change, not something that needs an alert.
        events.append(dynamicId, actorUserId, "dynamic_settings_changed", """{"dynamic_id":"$dynamicId"}""")

        return detail(actorUserId, dynamicId)
    }

    /**
     * Pause — Journey E.
     *
     * Stops FUTURE generation. It never deletes history, and returning never
     * requires making up what was missed (Notion 03 §4).
     *
     * Either member may pause: this is inviolable agency, not a Dom privilege.
     */
    @Transactional
    fun pause(actorUserId: UUID, dynamicId: UUID) {
        val ctx = authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))

        dsl.fetchOne(
            """
            UPDATE dynamics SET state = 'PAUSED', paused_at = now(), version = version + 1
             WHERE id = {0} AND state = 'ACTIVE'
            RETURNING id
            """.trimIndent(),
            dynamicId,
        ) ?: throw DynamicNotPausable(detail(actorUserId, dynamicId).state)

        events.append(dynamicId, actorUserId, "dynamic_paused", """{"dynamic_id":"$dynamicId"}""")
        events.enqueueOutbox("dynamic", dynamicId, "dynamic_paused", "pause:$dynamicId:${ctx.membershipId}")
    }

    /**
     * Coming back. Paused days were never generated (the scheduler only ticks
     * ACTIVE dynamics), so resuming never means facing work you "owe"
     * (invariant 9: paused = no debt). Adjusting the load is the 规矩 tab.
     */
    @Transactional
    fun resume(actorUserId: UUID, dynamicId: UUID) {
        val ctx = authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))

        dsl.fetchOne(
            """
            UPDATE dynamics SET state = 'ACTIVE', paused_at = NULL, version = version + 1
             WHERE id = {0} AND state = 'PAUSED'
            RETURNING id
            """.trimIndent(),
            dynamicId,
        ) ?: throw DynamicNotPausable(detail(actorUserId, dynamicId).state)

        events.append(dynamicId, actorUserId, "dynamic_resumed", """{"dynamic_id":"$dynamicId"}""")
        events.enqueueOutbox("dynamic", dynamicId, "dynamic_resumed", "resume:$dynamicId:${ctx.membershipId}:${Instant.now().epochSecond}")
    }
}
