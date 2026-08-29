package com.dsapp.backend.dynamic

import com.dsapp.backend.dynamic.application.InviteNotJoinable
import com.dsapp.backend.dynamic.application.InviteService
import com.dsapp.backend.dynamic.domain.RoleContext
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
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
            """INSERT INTO memberships (user_id,dynamic_id,role_context,access_state)
               VALUES ({0},{1},'CREATOR','ACTIVE')""", creator, dynamicId,
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
}
