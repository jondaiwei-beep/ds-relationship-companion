package com.dsapp.backend.dynamic.application

import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

/**
 * Leave and Block — Notion 04 §8, Journey F. The safety feature.
 *
 * **G-1 (closed).** Notion 04 §8 asks for "future delivery = 0", which is
 * physically impossible once bytes are with a provider. The achievable and
 * now-implemented guarantee is:
 *
 * > After the Leave/Block transaction commits, the system initiates **no new**
 * > relationship-delivery provider calls for that Dynamic. Every intent not
 * > already handed off is cancelled. A call initiated before the cut-off may
 * > still arrive and cannot be recalled.
 *
 * The mechanism is a per-Dynamic advisory lock: Leave/Block takes it
 * EXCLUSIVELY, the dispatcher takes it SHARED around its final authorization
 * check and provider call. Cancelling outbox rows alone would not close the
 * check-then-send race — the dispatcher could have already decided to send.
 *
 * **G-2 (closed).** A Block is recorded directionally but takes effect as a
 * MUTUAL separation: it ends the Dynamic, seals shared history from both
 * people, prevents reconnection, and never tells the other person who blocked
 * them. A one-way block that let the blocker keep browsing would be a
 * surveillance asymmetry, and naming the blocker hands an unsafe person a fact
 * to react to.
 */
@Service
class LeaveBlockService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {
    /** Stable per-Dynamic lock id for the delivery fence. */
    private fun fenceKey(dynamicId: UUID): Long = dynamicId.mostSignificantBits

    /**
     * Take the delivery fence exclusively.
     *
     * Any dispatcher mid-flight holds the shared lock, so this blocks until it
     * finishes. After we commit, no dispatcher can pass its authorization
     * check for this Dynamic.
     */
    private fun acquireExclusiveDeliveryFence(dynamicId: UUID) {
        dsl.fetchOne("SELECT pg_advisory_xact_lock({0})", fenceKey(dynamicId))
    }

    /**
     * Leave — Journey F. No partner approval is needed, ever.
     *
     * Leaving does NOT seal history for the person who stayed: they did not do
     * anything, and erasing their record of the relationship would be its own
     * harm. It stops future shared action and delivery.
     */
    @Transactional
    fun leave(actorUserId: UUID, dynamicId: UUID, reason: String? = null) {
        val ctx = authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        acquireExclusiveDeliveryFence(dynamicId)

        // 1. access state changes immediately, server-side.
        dsl.query(
            """UPDATE memberships SET access_state = 'LEFT'
                WHERE id = {0} AND access_state = 'ACTIVE'""",
            ctx.membershipId,
        ).execute()

        // 2. the Dynamic stops producing shared action.
        dsl.query(
            """UPDATE dynamics SET state = 'ENDED', version = version + 1
                WHERE id = {0} AND state <> 'ENDED'""",
            dynamicId,
        ).execute()

        // 3. queued deliveries for this Dynamic are cancelled.
        cancelQueuedDeliveries(dynamicId, "left")

        // 4. any live invite can no longer be used to reconnect.
        revokeInvites(dynamicId)

        dsl.query(
            """INSERT INTO membership_terminations (dynamic_id, actor_user_id, kind, reason)
               VALUES ({0}, {1}, 'LEAVE', {2})""",
            dynamicId, actorUserId, reason,
        ).execute()

        events.append(dynamicId, actorUserId, "member_left", """{"dynamic_id":"$dynamicId"}""")
        // 5. deliberately NO outbox enqueue: the departure itself is visible in
        // the app. Pushing "your partner left" to a lockscreen would be cruel.
    }

    /**
     * Block — the safety action. Immediate, mutual in effect, and silent.
     *
     * @param targetUserId the person being blocked.
     */
    @Transactional
    fun block(actorUserId: UUID, dynamicId: UUID, targetUserId: UUID, reason: String? = null) {
        val ctx = authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        require(targetUserId != actorUserId) { "cannot block yourself" }
        acquireExclusiveDeliveryFence(dynamicId)

        // 1. BOTH memberships lose access. The block is recorded directionally
        // but separates mutually, so neither person can browse the other's
        // shared history afterwards.
        dsl.query(
            """UPDATE memberships SET access_state = 'BLOCKED'
                WHERE dynamic_id = {0} AND access_state = 'ACTIVE'""",
            dynamicId,
        ).execute()

        // 2. the Dynamic ends permanently. Blocking is not a pause.
        dsl.query(
            "UPDATE dynamics SET state = 'ENDED', version = version + 1 WHERE id = {0}",
            dynamicId,
        ).execute()

        // 3. every queued delivery is cancelled before we commit.
        cancelQueuedDeliveries(dynamicId, "blocked")

        // 4. no invite may be used to reconnect.
        revokeInvites(dynamicId)

        dsl.query(
            """INSERT INTO membership_terminations
                 (dynamic_id, actor_user_id, target_user_id, kind, reason)
               VALUES ({0}, {1}, {2}, 'BLOCK', {3})""",
            dynamicId, actorUserId, targetUserId, reason,
        ).execute()

        // The event records that a block happened, WITHOUT naming the blocker
        // in anything the blocked person can read. Notion 04 §8 forbids an
        // "X blocked you" notification, and nothing is enqueued for delivery.
        events.append(dynamicId, actorUserId, "member_blocked", """{"dynamic_id":"$dynamicId"}""")
        require(ctx.membershipId != null)
    }

    /**
     * Cancel everything still queued for this Dynamic.
     *
     * PENDING and FAILED both go: a FAILED row would otherwise be retried by a
     * later operator action and deliver after the cut-off.
     */
    private fun cancelQueuedDeliveries(dynamicId: UUID, why: String) {
        dsl.query(
            """
            UPDATE outbox_records
               SET state = 'CANCELLED', locked_until = NULL, last_error = {1}
             WHERE state IN ('PENDING', 'FAILED')
               AND (dynamic_id = {0}
                    OR aggregate_id IN (SELECT id FROM occurrences WHERE dynamic_id = {0})
                    OR aggregate_id IN (SELECT id FROM d_notes WHERE dynamic_id = {0}))
            """.trimIndent(),
            dynamicId, "suppressed:ACCESS_ENDED:$why",
        ).execute()
    }

    private fun revokeInvites(dynamicId: UUID) {
        dsl.query(
            """UPDATE invites SET state = 'REVOKED', revoked_at = now()
                WHERE dynamic_id = {0} AND state = 'PENDING'""",
            dynamicId,
        ).execute()
    }
}
