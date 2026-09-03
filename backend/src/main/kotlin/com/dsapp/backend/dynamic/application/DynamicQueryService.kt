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
        val accessState: String,
    )

    data class StructureItem(val definitionId: UUID, val kind: String, val title: String, val active: Boolean)

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
                   day_boundary_minutes, paused_at
              FROM dynamics WHERE id = {0}
            """.trimIndent(),
            dynamicId,
        )!!

        val members = dsl.fetch(
            """
            SELECT u.id AS user_id, u.display_name, m.role_context,
                   m.role_preset, m.access_state
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
                it.get("access_state", String::class.java),
            )
        }

        val structure = dsl.fetch(
            """
            SELECT id, kind, title, active FROM expectation_definitions
             WHERE dynamic_id = {0} ORDER BY created_at
            """.trimIndent(),
            dynamicId,
        ).map {
            StructureItem(
                it.get("id", UUID::class.java),
                it.get("kind", String::class.java),
                it.get("title", String::class.java),
                it.get("active", Boolean::class.java),
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
        )
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

    @Transactional
    /**
     * Coming back — Journey E (Notion 02 Section 6).
     *
     * [lighter] halves the recurring structure rather than restoring all of
     * it. Returning after a hard stretch and being handed the same load is
     * how people leave again; the choice belongs to them, and the third
     * option (adjust) is the Dynamic screen, not a mode here.
     */
    fun resume(actorUserId: UUID, dynamicId: UUID, lighter: Boolean = false) {
        val ctx = authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))

        dsl.fetchOne(
            """
            UPDATE dynamics SET state = 'ACTIVE', paused_at = NULL, version = version + 1
             WHERE id = {0} AND state = 'PAUSED'
            RETURNING id
            """.trimIndent(),
            dynamicId,
        ) ?: throw DynamicNotPausable(detail(actorUserId, dynamicId).state)

        if (lighter) {
            // Deactivate half of the recurring structure, oldest kept first.
            // Nothing is deleted: the definitions stay and can be switched
            // back on from the Dynamic screen.
            dsl.query(
                """
                UPDATE expectation_definitions
                   SET active = false
                 WHERE id IN (
                     SELECT d.id FROM expectation_definitions d
                      WHERE d.dynamic_id = {0} AND d.active
                      ORDER BY d.created_at DESC
                      LIMIT GREATEST(
                          (SELECT count(*) / 2 FROM expectation_definitions
                            WHERE dynamic_id = {0} AND active), 0)
                 )
                """.trimIndent(),
                dynamicId,
            ).execute()
        }

        // Advance the generation barrier to today's relationship day. This is
        // what makes Resume backlog-free: paused days are simply not eligible,
        // so returning never means facing work you "owe" (Journey E).
        dsl.query(
            """
            UPDATE expectation_recurrences r
               SET eligible_from_day = (
                     SELECT (now() AT TIME ZONE d.reference_timezone)::date
                       FROM dynamics d WHERE d.id = {0}
                   ),
                   updated_at = now()
              FROM expectation_definitions e
             WHERE r.definition_id = e.id AND e.dynamic_id = {0}
            """.trimIndent(),
            dynamicId,
        ).execute()

        events.append(dynamicId, actorUserId, "dynamic_resumed", """{"dynamic_id":"$dynamicId"}""")
        events.enqueueOutbox("dynamic", dynamicId, "dynamic_resumed", "resume:$dynamicId:${ctx.membershipId}:${Instant.now().epochSecond}")
    }
}
