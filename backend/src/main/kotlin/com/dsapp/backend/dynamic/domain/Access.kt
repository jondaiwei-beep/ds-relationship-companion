package com.dsapp.backend.dynamic.domain

import java.util.UUID

/** Membership access state — Notion 03 §2. */
enum class AccessState { ACTIVE, LEFT, BLOCKED }

/** Dynamic lifecycle — Notion 03 §2. */
enum class DynamicState { DRAFT, PENDING_PARTNER, ACTIVE, PAUSED, ENDED }

/**
 * Role within a Dynamic.
 *
 * Invariant: role belongs to MEMBERSHIP, never to User as a permanent
 * identity. The same person may hold different roles in different Dynamics.
 */
enum class RoleContext { CREATOR, PARTNER }

/**
 * Which side of the dynamic a member is on (product/03-domain.md). The S side
 * delivers; the D side disposes. Authorization stays on [RoleContext]; side
 * decides who may write which axis of an occurrence.
 */
enum class Side { D, S }

/** A member's authorization context, resolved server-side on every request. */
data class MemberContext(
    val userId: UUID,
    val dynamicId: UUID,
    val membershipId: UUID,
    val role: RoleContext,
    val side: Side,
    val accessState: AccessState,
    val dynamicState: DynamicState,
) {
    /** Reads stay available while PAUSED/ENDED; only LEFT/BLOCKED cuts them off. */
    val mayRead: Boolean get() = accessState == AccessState.ACTIVE

    /** Relationship mutations (complete, acknowledge) need a live Dynamic. */
    val mayMutate: Boolean
        get() = accessState == AccessState.ACTIVE && dynamicState == DynamicState.ACTIVE

    /**
     * Setup mutations (create invite, revoke invite, add the first Expectation)
     * are additionally allowed while PENDING_PARTNER.
     *
     * Without this, activation deadlocks: the Dynamic cannot reach ACTIVE until
     * a partner joins, and no partner can be invited while it is not ACTIVE
     * (Journey A4).
     */
    val maySetUp: Boolean
        get() = accessState == AccessState.ACTIVE &&
            (dynamicState == DynamicState.ACTIVE || dynamicState == DynamicState.PENDING_PARTNER)
}
