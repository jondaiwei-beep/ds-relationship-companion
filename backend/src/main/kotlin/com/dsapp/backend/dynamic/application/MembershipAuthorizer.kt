package com.dsapp.backend.dynamic.application

import com.dsapp.backend.dynamic.domain.AccessState
import com.dsapp.backend.dynamic.domain.AuthorizationException
import com.dsapp.backend.dynamic.domain.DynamicState
import com.dsapp.backend.dynamic.domain.MemberContext
import com.dsapp.backend.dynamic.domain.RoleContext
import com.dsapp.backend.dynamic.domain.Side
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import java.util.UUID

/**
 * Answers: "may this user act on this resource, in this role, right now?"
 *
 * Every sensitive read and write goes through here (Notion 06 §3). This is a
 * preliminary check that produces good error messages; the concurrency-safe
 * authorization decision is still the guarded conditional UPDATE in the command.
 */
@Service
class MembershipAuthorizer(private val dsl: DSLContext) {

    /** Resolve the actor's membership in a Dynamic, or null if none exists. */
    fun contextForDynamic(actorUserId: UUID, dynamicId: UUID): MemberContext? =
        dsl.fetchOne(
            """
            SELECT m.id, m.role_context, m.side, m.access_state, d.state AS dynamic_state
              FROM memberships m
              JOIN dynamics d ON d.id = m.dynamic_id
             WHERE m.user_id = {0} AND m.dynamic_id = {1}
            """.trimIndent(),
            actorUserId, dynamicId,
        )?.let { r ->
            MemberContext(
                userId = actorUserId,
                dynamicId = dynamicId,
                membershipId = r.get("id", UUID::class.java),
                role = RoleContext.valueOf(r.get("role_context", String::class.java)),
                side = Side.valueOf(r.get("side", String::class.java)),
                accessState = AccessState.valueOf(r.get("access_state", String::class.java)),
                dynamicState = DynamicState.valueOf(r.get("dynamic_state", String::class.java)),
            )
        }

    /** Resolve the actor's membership via an occurrence, or null if none exists. */
    fun contextForOccurrence(actorUserId: UUID, occurrenceId: UUID): MemberContext? =
        dsl.fetchOne(
            """
            SELECT m.id, m.dynamic_id, m.role_context, m.side, m.access_state, d.state AS dynamic_state
              FROM occurrences o
              JOIN memberships m ON m.dynamic_id = o.dynamic_id AND m.user_id = {0}
              JOIN dynamics d ON d.id = o.dynamic_id
             WHERE o.id = {1}
            """.trimIndent(),
            actorUserId, occurrenceId,
        )?.let { r ->
            MemberContext(
                userId = actorUserId,
                dynamicId = r.get("dynamic_id", UUID::class.java),
                membershipId = r.get("id", UUID::class.java),
                role = RoleContext.valueOf(r.get("role_context", String::class.java)),
                side = Side.valueOf(r.get("side", String::class.java)),
                accessState = AccessState.valueOf(r.get("access_state", String::class.java)),
                dynamicState = DynamicState.valueOf(r.get("dynamic_state", String::class.java)),
            )
        }

    /**
     * Require read access. Reads survive PAUSED/ENDED — a paused relationship
     * still has history — but never survive LEFT or BLOCKED (Notion 04 §8).
     */
    fun requireRead(ctx: MemberContext?): MemberContext {
        if (ctx == null || !ctx.mayRead) throw AuthorizationException.NotAMember()
        return ctx
    }

    /**
     * Require SETUP rights in a specific role — also permitted while the
     * Dynamic is PENDING_PARTNER. Use for invite and first-expectation
     * creation only, never for relationship actions.
     */
    fun requireSetUp(ctx: MemberContext?, role: RoleContext): MemberContext {
        val c = requireRead(ctx)
        if (!c.maySetUp) throw AuthorizationException.DynamicNotActive(c.dynamicState)
        if (c.role != role) throw AuthorizationException.WrongRole(role, c.role)
        return c
    }

    /** Require mutation rights on a given side — the s axis or the D axis. */
    fun requireSide(ctx: MemberContext?, side: Side): MemberContext {
        val c = requireRead(ctx)
        if (!c.mayMutate) throw AuthorizationException.DynamicNotActive(c.dynamicState)
        if (c.side != side) throw AuthorizationException.WrongSide(side, c.side)
        return c
    }

    /** Any active member may mutate; used where both sides write (comments, tasks). */
    fun requireActive(ctx: MemberContext?): MemberContext {
        val c = requireRead(ctx)
        if (!c.mayMutate) throw AuthorizationException.DynamicNotActive(c.dynamicState)
        return c
    }

    /**
     * Require mutation rights in a specific role.
     *
     * Note: this never checks whether the *occurrence* is in the right state —
     * that belongs to the guarded UPDATE, so concurrent callers cannot both win.
     */
    fun requireMutate(ctx: MemberContext?, role: RoleContext): MemberContext {
        val c = requireRead(ctx)
        if (!c.mayMutate) throw AuthorizationException.DynamicNotActive(c.dynamicState)
        if (c.role != role) throw AuthorizationException.WrongRole(role, c.role)
        return c
    }
}
