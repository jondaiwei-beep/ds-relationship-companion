package com.dsapp.backend.dynamic.application

import com.dsapp.backend.dynamic.domain.AuthorizationException
import com.dsapp.backend.dynamic.domain.RoleContext
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.security.MessageDigest
import java.security.SecureRandom
import java.time.Instant
import java.util.Base64
import java.util.UUID

/**
 * Invite lifecycle — Notion 04 §2.
 *
 * The token LOCATES invite context; it never grants business access. Membership
 * is created only after authenticated, idempotent acceptance. Every terminal
 * state is explicit — an expired or revoked invite must never 404 (Notion 02 §A4).
 */
@Service
class InviteService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {
    companion object {
        private const val PREFIX = "iv1."
        private const val TTL_DAYS = 7L
        private val RNG = SecureRandom()

        fun hash(token: String): ByteArray =
            MessageDigest.getInstance("SHA-256").digest(token.toByteArray())
    }

    /** What the join page may show BEFORE authentication. Deliberately minimal. */
    data class ResolvedInvite(
        val state: String,
        val inviteId: UUID?,
        val dynamicId: UUID?,
        val intendedRoleContext: String?,
        val inviterDisplayName: String?,
    )

    /** Plaintext is returned exactly once, at creation. Only the hash is stored. */
    data class CreatedInvite(val inviteId: UUID, val token: String, val expiresAt: Instant)

    @Transactional
    fun create(actorUserId: UUID, dynamicId: UUID, intendedRole: RoleContext): CreatedInvite {
        authorizer.requireSetUp(
            authorizer.contextForDynamic(actorUserId, dynamicId),
            RoleContext.CREATOR,
        )

        val raw = ByteArray(32).also(RNG::nextBytes)
        val token = PREFIX + Base64.getUrlEncoder().withoutPadding().encodeToString(raw)
        val inviteId = UUID.randomUUID()
        val expiresAt = Instant.now().plusSeconds(TTL_DAYS * 86_400)

        // The partial unique index allows only ONE pending invite per dynamic,
        // so a double-tap cannot create a second live token. Ask first, so a
        // Creator who taps again gets an explanation rather than a 500 — the
        // screen contract requires retry to be recoverable, and a stack trace
        // is not.
        //
        // The token is returned exactly once and only its hash is stored, so
        // the existing invitation cannot be handed back here. The Creator
        // revokes it and issues a new one, which is also the honest model: a
        // link they can no longer see is a link they can no longer share.
        val pending = dsl.fetchOne(
            "SELECT id FROM invites WHERE dynamic_id = {0} AND state = 'PENDING'",
            dynamicId,
        )
        if (pending != null) {
            throw InviteAlreadyPending(pending.get("id", UUID::class.java))
        }

        dsl.query(
            """
            INSERT INTO invites (id, dynamic_id, inviter_user_id, intended_role_context,
                                 token_hash, expires_at, state)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5}, 'PENDING')
            """.trimIndent(),
            inviteId, dynamicId, actorUserId, intendedRole.name, hash(token), expiresAt,
        ).execute()

        events.append(
            dynamicId = dynamicId,
            actorUserId = actorUserId,
            eventType = "invite_created",
            objectRef = """{"invite_id":"$inviteId"}""",
        )
        return CreatedInvite(inviteId, token, expiresAt)
    }

    /**
     * Anonymous pre-auth resolution. Never 404s: an unknown, expired or revoked
     * token all return an explicit state so the web page can explain itself.
     */
    @Transactional(readOnly = true)
    fun resolve(token: String): ResolvedInvite {
        val row = dsl.fetchOne(
            """
            SELECT i.id, i.dynamic_id, i.intended_role_context, i.state, i.expires_at,
                   u.display_name
              FROM invites i
              JOIN users u ON u.id = i.inviter_user_id
             WHERE i.token_hash = {0}
            """.trimIndent(),
            hash(token),
        ) ?: return ResolvedInvite("NOT_FOUND", null, null, null, null)

        val stored = row.get("state", String::class.java)
        val expiresAt = row.get("expires_at", Instant::class.java)
        val effective = when {
            stored == "PENDING" && expiresAt.isBefore(Instant.now()) -> "EXPIRED"
            else -> stored
        }

        // A live invitation is the only one that carries content.
        //
        // This endpoint is anonymous, so whoever holds the URL gets whatever
        // it returns. For a PENDING invite that is the point — the invitee
        // must know who invited them before signing in (Notion 02 §A5). For a
        // revoked, expired or already-used one there is nothing to decide, and
        // returning the inviter's name and the Dynamic id would hand a
        // stranger a fact about someone's private life long after the link
        // was meant to stop working.
        //
        // It also makes the states genuinely indistinguishable rather than
        // only indistinguishable on screen: SCR-10 renders revoked and
        // not-found identically, which was cosmetic while the JSON told them
        // apart.
        if (effective != "PENDING") {
            return ResolvedInvite(effective, null, null, null, null)
        }

        return ResolvedInvite(
            state = effective,
            inviteId = row.get("id", UUID::class.java),
            dynamicId = row.get("dynamic_id", UUID::class.java),
            intendedRoleContext = row.get("intended_role_context", String::class.java),
            // Shown pre-auth so the invitee knows who invited them (Notion 02 §A5).
            inviterDisplayName = row.get("display_name", String::class.java),
        )
    }

    /**
     * Withdraw a live invitation.
     *
     * A Creator could not do this at all. Invites were revoked only as a side
     * effect of Block, which is a safety action about a person — a link sent
     * to the wrong address, or simply thought better of, had no way back.
     *
     * It is also the escape hatch [create] depends on: only one PENDING
     * invitation may exist per Dynamic, and the guidance when a second is
     * refused is to revoke the first. That guidance was impossible to follow.
     *
     * Guarded like [join]: only a PENDING invite flips, so two revokes, or a
     * revoke racing a join, cannot both win.
     */
    @Transactional
    fun revoke(actorUserId: UUID, dynamicId: UUID, inviteId: UUID) {
        authorizer.requireSetUp(
            authorizer.contextForDynamic(actorUserId, dynamicId),
            RoleContext.CREATOR,
        )

        dsl.fetchOne(
            """
            UPDATE invites
               SET state = 'REVOKED', revoked_at = now()
             WHERE id = {0} AND dynamic_id = {1} AND state = 'PENDING'
            RETURNING id
            """.trimIndent(),
            inviteId, dynamicId,
        ) ?: throw InviteNotRevocable(inviteId)

        events.append(
            dynamicId = dynamicId,
            actorUserId = actorUserId,
            eventType = "invite_revoked",
            objectRef = """{"invite_id":"$inviteId"}""",
        )
    }


    /**
     * Consume the invite and create the partner membership, atomically.
     *
     * Notion 03 §4: joining is NOT consent to future expectations — it only
     * establishes membership.
     */
    @Transactional
    fun join(actorUserId: UUID, token: String): UUID {
        // Guarded consume: only a PENDING, unexpired invite flips. Concurrent
        // joins re-evaluate this predicate, so exactly one can win.
        val claimed = dsl.fetchOne(
            """
            UPDATE invites
               SET state = 'ACCEPTED',
                   accepted_by_user_id = {1},
                   accepted_at = now()
             WHERE token_hash = {0} AND state = 'PENDING' AND expires_at > clock_timestamp()
            RETURNING id, dynamic_id, inviter_user_id, intended_role_context
            """.trimIndent(),
            hash(token), actorUserId,
        ) ?: throw InviteNotJoinable(resolve(token).state)

        val dynamicId = claimed.get("dynamic_id", UUID::class.java)
        val inviter = claimed.get("inviter_user_id", UUID::class.java)
        if (inviter == actorUserId) throw AuthorizationException.NotAMember()

        val membershipId = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO memberships (id, user_id, dynamic_id, role_context, side, access_state)
            VALUES ({0}, {1}, {2}, {3},
                    -- the side the inviter did not take
                    COALESCE((SELECT CASE side WHEN 'D' THEN 'S' ELSE 'D' END
                                FROM memberships WHERE dynamic_id = {2} AND user_id = {4}), 'S'),
                    'ACTIVE')
            """.trimIndent(),
            membershipId, actorUserId, dynamicId,
            claimed.get("intended_role_context", String::class.java), inviter,
        ).execute()

        // Both members are present, so the dynamic becomes ACTIVE.
        dsl.query(
            "UPDATE dynamics SET state='ACTIVE', version=version+1 WHERE id={0} AND state='PENDING_PARTNER'",
            dynamicId,
        ).execute()

        events.append(dynamicId, actorUserId, "member_joined", """{"membership_id":"$membershipId"}""")
        events.enqueueOutbox("dynamic", dynamicId, "member_joined", "join:$membershipId")
        return membershipId
    }
}

class InviteNotJoinable(val state: String) : RuntimeException("Invite is $state")

/**
 * A Dynamic may have only one live invitation at a time.
 *
 * Not an error in the Creator's behaviour: two taps, or a screen reopened
 * after the link was already made, both land here. The screen says a link
 * already exists and offers to revoke it.
 */
class InviteAlreadyPending(val inviteId: UUID) : RuntimeException("Invite already pending")

/**
 * The invitation is not live, so there is nothing to withdraw.
 *
 * Already accepted, already revoked, expired, or belonging to another
 * Dynamic — all one answer, because distinguishing them would describe
 * invitations the caller may not be entitled to know about.
 */
class InviteNotRevocable(val inviteId: UUID) : RuntimeException("Invite not revocable")
