package com.dsapp.backend.dynamic

import com.dsapp.backend.dynamic.application.InviteAlreadyPending
import com.dsapp.backend.dynamic.application.InviteNotRevocable
import com.dsapp.backend.dynamic.application.InviteNotJoinable
import com.dsapp.backend.dynamic.application.InviteService
import com.dsapp.backend.dynamic.domain.RoleContext
import com.dsapp.backend.dynamic.domain.AuthorizationException
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNotEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

/** Invite lifecycle — Notion 04 §2 and Journey A4/A5. */
@SpringBootTest
@ActiveProfiles("test")
class InviteServiceIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var invites: InviteService

    private lateinit var creator: UUID
    private lateinit var invitee: UUID
    private lateinit var dynamicId: UUID

    @BeforeEach
    fun seed() {
        creator = UUID.randomUUID(); invitee = UUID.randomUUID(); dynamicId = UUID.randomUUID()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Alex')", creator, "$creator@t.local").execute()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Jamie')", invitee, "$invitee@t.local").execute()
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','CLOSER','LIGHT','ACTIVE','America/New_York')""", dynamicId,
        ).execute()
        dsl.query(
            """INSERT INTO memberships (user_id,dynamic_id,role_context,side,access_state)
               VALUES ({0},{1},'CREATOR','D','ACTIVE')""", creator, dynamicId,
        ).execute()
    }

    @Test
    fun `only the SHA-256 hash is stored, never the plaintext token`() {
        val created = invites.create(creator, dynamicId, RoleContext.PARTNER)

        val stored = dsl.fetchOne("SELECT token_hash FROM invites WHERE id={0}", created.inviteId)!!
            .get("token_hash", ByteArray::class.java)
        assertEquals(32, stored.size, "must be a 32-byte SHA-256 digest")
        assertEquals(
            InviteService.hash(created.token).toList(), stored.toList(),
            "stored value must be the hash of the issued token",
        )

        // The plaintext must appear nowhere in the row.
        val dump = dsl.fetchOne("SELECT invites::text AS r FROM invites WHERE id={0}", created.inviteId)!!
            .get("r", String::class.java)
        assert(!dump.contains(created.token)) { "plaintext token leaked into the row" }
    }

    @Test
    fun `resolve never 404s - unknown, expired and revoked each get an explicit state`() {
        assertEquals("NOT_FOUND", invites.resolve("iv1.nonexistent").state)

        val expired = invites.create(creator, dynamicId, RoleContext.PARTNER)
        dsl.query("UPDATE invites SET created_at = now() - interval '8 days', expires_at = now() - interval '1 day' WHERE id={0}", expired.inviteId).execute()
        assertEquals("EXPIRED", invites.resolve(expired.token).state)

        dsl.query("UPDATE invites SET state='REVOKED', revoked_at=now() WHERE id={0}", expired.inviteId).execute()
        assertEquals("REVOKED", invites.resolve(expired.token).state)
    }

    @Test
    fun `resolve exposes who invited you but not private dynamic content`() {
        val created = invites.create(creator, dynamicId, RoleContext.PARTNER)
        val r = invites.resolve(created.token)

        assertEquals("PENDING", r.state)
        assertEquals("Alex", r.inviterDisplayName)
        assertEquals("PARTNER", r.intendedRoleContext)
        assertNotNull(r.dynamicId)
    }

    @Test
    fun `a dead invitation carries no content at all`() {
        // `resolve` is anonymous, so whatever it returns goes to whoever holds
        // the URL. A live invitation must name its inviter — that is how the
        // invitee knows the link is real. A revoked one must not: there is
        // nothing left to decide, and the name is a fact about someone's
        // private life handed to a stranger after the link was meant to stop
        // working.
        //
        // It is also what makes REVOKED and NOT_FOUND genuinely
        // indistinguishable. SCR-10 renders them identically, which was
        // cosmetic while the JSON told them apart.
        val created = invites.create(creator, dynamicId, RoleContext.PARTNER)
        invites.revoke(creator, dynamicId, created.inviteId)

        val revoked = invites.resolve(created.token)
        assertEquals("REVOKED", revoked.state)
        assertNull(revoked.inviterDisplayName, "a dead link must not name a person")
        assertNull(revoked.dynamicId, "a dead link must not identify a Dynamic")
        assertNull(revoked.inviteId)
        assertNull(revoked.intendedRoleContext)

        val absent = invites.resolve("no-such-token")
        assertEquals("NOT_FOUND", absent.state)
        assertEquals(
            listOf(absent.inviteId, absent.dynamicId, absent.intendedRoleContext,
                   absent.inviterDisplayName),
            listOf(revoked.inviteId, revoked.dynamicId, revoked.intendedRoleContext,
                   revoked.inviterDisplayName),
            "revoked and not-found must be indistinguishable in the payload, " +
                "not only on the screen",
        )
    }

    @Test
    fun `join creates an active membership and consumes the invite`() {
        val created = invites.create(creator, dynamicId, RoleContext.PARTNER)
        val membershipId = invites.join(invitee, created.token)

        val m = dsl.fetchOne("SELECT role_context, access_state FROM memberships WHERE id={0}", membershipId)!!
        assertEquals("PARTNER", m.get("role_context", String::class.java))
        assertEquals("ACTIVE", m.get("access_state", String::class.java))
        assertEquals("ACCEPTED", invites.resolve(created.token).state)
    }

    @Test
    fun `an invite is single-use`() {
        val created = invites.create(creator, dynamicId, RoleContext.PARTNER)
        invites.join(invitee, created.token)

        val third = UUID.randomUUID()
        dsl.query("INSERT INTO users (id,email) VALUES ({0},{1})", third, "$third@t.local").execute()

        val ex = assertFailsWith<InviteNotJoinable> { invites.join(third, created.token) }
        assertEquals("ACCEPTED", ex.state)
    }

    @Test
    fun `an expired invite cannot be joined`() {
        val created = invites.create(creator, dynamicId, RoleContext.PARTNER)
        dsl.query("UPDATE invites SET created_at = now() - interval '8 days', expires_at = now() - interval '1 second' WHERE id={0}", created.inviteId).execute()

        assertFailsWith<InviteNotJoinable> { invites.join(invitee, created.token) }
        assertNull(
            dsl.fetchOne("SELECT id FROM memberships WHERE user_id={0} AND dynamic_id={1}", invitee, dynamicId),
            "no membership may be created from an expired invite",
        )
    }

    @Test
    fun `a revoked invite cannot be joined`() {
        val created = invites.create(creator, dynamicId, RoleContext.PARTNER)
        dsl.query("UPDATE invites SET state='REVOKED', revoked_at=now() WHERE id={0}", created.inviteId).execute()

        assertFailsWith<InviteNotJoinable> { invites.join(invitee, created.token) }
    }

    @Test
    fun `only one pending invite may exist per dynamic`() {
        invites.create(creator, dynamicId, RoleContext.PARTNER)
        // The partial unique index is the enforcement, not application logic.
        assertFailsWith<Exception> { invites.create(creator, dynamicId, RoleContext.PARTNER) }
    }

    @Test
    fun `a second invitation while one is live explains itself`() {
        invites.create(creator, dynamicId, RoleContext.PARTNER)

        // The partial unique index allows one PENDING invite per dynamic. Left
        // to the database this surfaced as a 500 — the screen contract says
        // retry must be recoverable, and a stack trace is not recoverable.
        val e = assertFailsWith<InviteAlreadyPending> {
            invites.create(creator, dynamicId, RoleContext.PARTNER)
        }
        assertNotNull(e.inviteId)
    }

    @Test
    fun `revoking frees the dynamic for a new invitation`() {
        val first = invites.create(creator, dynamicId, RoleContext.PARTNER)
        dsl.query(
            "UPDATE invites SET state='REVOKED', revoked_at=now() WHERE id={0}",
            first.inviteId,
        ).execute()

        // The Creator can always issue another once the live one is closed.
        val second = invites.create(creator, dynamicId, RoleContext.PARTNER)
        assertNotEquals(first.inviteId, second.inviteId)
    }

    @Test
    fun `a creator can withdraw an invitation they sent`() {
        // There was no way to do this at all. Invites were revoked only as a
        // side effect of Block — a safety action about a person — so a link
        // sent to the wrong address had no way back.
        val invite = invites.create(creator, dynamicId, RoleContext.PARTNER)

        invites.revoke(creator, dynamicId, invite.inviteId)

        assertEquals("REVOKED", invites.resolve(invite.token).state)
    }

    @Test
    fun `withdrawing frees the dynamic for a new invitation`() {
        // The reason this endpoint had to exist: one PENDING invite per
        // Dynamic, and the guidance when a second is refused is to revoke the
        // first. That was impossible to follow.
        val first = invites.create(creator, dynamicId, RoleContext.PARTNER)
        invites.revoke(creator, dynamicId, first.inviteId)

        val second = invites.create(creator, dynamicId, RoleContext.PARTNER)

        assertNotEquals(first.inviteId, second.inviteId)
    }

    @Test
    fun `a revoked link cannot be joined`() {
        val invite = invites.create(creator, dynamicId, RoleContext.PARTNER)
        invites.revoke(creator, dynamicId, invite.inviteId)

        assertFailsWith<InviteNotJoinable> { invites.join(invitee, invite.token) }
    }

    @Test
    fun `withdrawing twice is refused rather than silently repeated`() {
        val invite = invites.create(creator, dynamicId, RoleContext.PARTNER)
        invites.revoke(creator, dynamicId, invite.inviteId)

        assertFailsWith<InviteNotRevocable> {
            invites.revoke(creator, dynamicId, invite.inviteId)
        }
    }

    @Test
    fun `an accepted invitation cannot be withdrawn`() {
        // The partner is already in. Withdrawing the link would suggest
        // undoing that, and leaving is a separate act with its own rules.
        val invite = invites.create(creator, dynamicId, RoleContext.PARTNER)
        invites.join(invitee, invite.token)

        assertFailsWith<InviteNotRevocable> {
            invites.revoke(creator, dynamicId, invite.inviteId)
        }
    }

    @Test
    fun `a non-member cannot withdraw someone else's invitation`() {
        val invite = invites.create(creator, dynamicId, RoleContext.PARTNER)
        val stranger = UUID.randomUUID()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Sam')",
            stranger, "$stranger@t.local").execute()

        assertFailsWith<AuthorizationException.NotAMember> {
            invites.revoke(stranger, dynamicId, invite.inviteId)
        }
    }
}
