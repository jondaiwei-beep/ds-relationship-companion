package com.dsapp.backend.dynamic

import com.dsapp.backend.delivery.application.OutboxDispatcher
import com.dsapp.backend.dynamic.application.InviteService
import com.dsapp.backend.dynamic.application.LeaveBlockService
import com.dsapp.backend.dynamic.domain.AuthorizationException
import com.dsapp.backend.dynamic.domain.RoleContext
import com.dsapp.backend.expectation.application.OccurrenceQueryService
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertTrue

/**
 * Leave and Block — Notion 04 §8, Journey F.
 *
 * This is the safety feature. Every assertion here is a promise made to
 * someone who may be leaving an unsafe situation.
 */
@SpringBootTest
@ActiveProfiles("test")
class LeaveBlockIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var leaveBlock: LeaveBlockService
    @Autowired lateinit var invites: InviteService
    @Autowired lateinit var query: OccurrenceQueryService
    @Autowired lateinit var dispatcher: OutboxDispatcher

    private lateinit var creator: UUID
    private lateinit var partner: UUID
    private lateinit var dynamicId: UUID
    private lateinit var occurrenceId: UUID

    @BeforeEach
    fun seed() {
        creator = UUID.randomUUID(); partner = UUID.randomUUID()
        dynamicId = UUID.randomUUID(); occurrenceId = UUID.randomUUID()
        val defId = UUID.randomUUID()

        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Alex')", creator, "$creator@t").execute()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Jamie')", partner, "$partner@t").execute()
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','CLOSER','LIGHT','ACTIVE','UTC')""", dynamicId,
        ).execute()
        for ((u, r) in listOf(creator to "CREATOR", partner to "PARTNER")) {
            dsl.query(
                "INSERT INTO memberships (user_id,dynamic_id,role_context,access_state) VALUES ({0},{1},{2},'ACTIVE')",
                u, dynamicId, r,
            ).execute()
        }
        dsl.query(
            """INSERT INTO expectation_definitions
                 (id,dynamic_id,kind,title,creator_user_id,assignee_user_id,visibility)
               VALUES ({0},{1},'TASK','Prepare the evening space',{2},{3},'SHARED')""",
            defId, dynamicId, creator, partner,
        ).execute()
        dsl.query(
            """INSERT INTO occurrences (id,definition_id,dynamic_id,state,relationship_day)
               VALUES ({0},{1},{2},'ACTIVE',CURRENT_DATE)""",
            occurrenceId, defId, dynamicId,
        ).execute()
    }

    private fun queueDelivery() {
        dsl.query(
            """INSERT INTO outbox_records
                 (aggregate_type,aggregate_id,dynamic_id,event_type,payload,dedupe_key)
               VALUES ('occurrence',{0},{1},'completion_submitted','{}'::jsonb,{2})""",
            occurrenceId, dynamicId, "d-${UUID.randomUUID()}",
        ).execute()
    }

    private fun accessOf(user: UUID): String =
        dsl.fetchOne("SELECT access_state FROM memberships WHERE user_id={0} AND dynamic_id={1}",
            user, dynamicId)!!.get("access_state", String::class.java)

    // ---- Leave ----

    @Test
    fun `leaving twice records one departure, not two`() {
        // REQ-IDEMP-001 names Leave: "retry produces at most one effective
        // business transition."
        //
        // The protection is not where it looks. The access-state and
        // dynamic-state updates are guarded (`WHERE access_state = 'ACTIVE'`),
        // but the termination record and the domain event below them are
        // unconditional INSERTs — so reading the method suggests a retry would
        // duplicate them. It cannot: `requireRead` rejects the second call
        // before any of it runs, because the actor is no longer an active
        // member of what they just left.
        //
        // That is worth a test precisely because the guard is invisible at the
        // point it protects. Someone relaxing authorization to let a departed
        // member read their own history would remove it without noticing.
        //
        // Scope: this covers the SEQUENTIAL retry. `requireRead` runs before
        // the advisory lock, so two *concurrent* direct service calls could
        // both pass it and reach the unconditional inserts. Over HTTP that
        // cannot happen — `/leave` goes through `runOnce`, and
        // `IdempotencyServiceIT."concurrent duplicates run the command only
        // once"` proves the DB unique index arbitrates same-key races. The
        // exposure is a keyless direct call, which no client makes.
        leaveBlock.leave(partner, dynamicId, "I need to step away.")
        assertFailsWith<AuthorizationException.NotAMember> {
            leaveBlock.leave(partner, dynamicId, "I need to step away.")
        }

        val terminations = dsl.fetchOne(
            "SELECT count(*) AS n FROM membership_terminations WHERE dynamic_id={0} AND kind='LEAVE'",
            dynamicId,
        )!!.get("n", Int::class.java)
        assertEquals(1, terminations, "a retried leave must record one departure")

        val events = dsl.fetchOne(
            "SELECT count(*) AS n FROM relationship_events WHERE dynamic_id={0} AND event_type='member_left'",
            dynamicId,
        )!!.get("n", Int::class.java)
        assertEquals(1, events, "a retried leave must emit one member_left event")
    }

    @Test
    fun `leaving needs no approval from the partner`() {
        // Journey F: the person leaving does not have to ask.
        leaveBlock.leave(partner, dynamicId, "I need to step away.")
        assertEquals("LEFT", accessOf(partner))
    }

    @Test
    fun `after leaving, queued deliveries are cancelled`() {
        queueDelivery()
        leaveBlock.leave(partner, dynamicId)

        val pending = dsl.fetchOne(
            "SELECT count(*) AS n FROM outbox_records WHERE dynamic_id={0} AND state='PENDING'",
            dynamicId,
        )!!.get("n", Int::class.java)
        assertEquals(0, pending, "post-leave future delivery must be zero (Notion 04 §8)")
    }

    @Test
    fun `leaving revokes any live invite so nobody can reconnect through it`() {
        val inv = invites.create(creator, dynamicId, RoleContext.PARTNER)
        leaveBlock.leave(creator, dynamicId)

        assertEquals("REVOKED", invites.resolve(inv.token).state)
    }

    @Test
    fun `leaving does NOT seal history for the person who stayed`() {
        leaveBlock.leave(partner, dynamicId)

        // The person who stayed did nothing wrong; erasing their record of the
        // relationship would be its own harm.
        val view = query.get(creator, occurrenceId)
        assertEquals("Prepare the evening space", view.title)
    }

    // ---- Block ----

    @Test
    fun `blocking cuts access for BOTH people - mutual separation (G-2)`() {
        leaveBlock.block(partner, dynamicId, targetUserId = creator, reason = "unsafe")

        assertEquals("BLOCKED", accessOf(partner))
        assertEquals("BLOCKED", accessOf(creator))
        // A one-way block that let the blocker keep browsing would be a
        // surveillance asymmetry.
    }

    @Test
    fun `after a block NEITHER person can read shared history`() {
        leaveBlock.block(partner, dynamicId, targetUserId = creator)

        assertFailsWith<AuthorizationException.NotAMember> { query.get(creator, occurrenceId) }
        assertFailsWith<AuthorizationException.NotAMember> { query.get(partner, occurrenceId) }
    }

    @Test
    fun `blocking ends the dynamic permanently - it is not a pause`() {
        leaveBlock.block(partner, dynamicId, targetUserId = creator)

        val state = dsl.fetchOne("SELECT state FROM dynamics WHERE id={0}", dynamicId)!!
            .get("state", String::class.java)
        assertEquals("ENDED", state)
    }

    @Test
    fun `blocking cancels queued deliveries AND stops the dispatcher sending`() {
        queueDelivery()
        leaveBlock.block(partner, dynamicId, targetUserId = creator)

        // Nothing left to claim, and nothing handed to a channel.
        dispatcher.dispatchOnce()
        // Scoped to THIS dynamic: dispatchOnce is global and will also drain
        // records other tests left in the shared database.
        val delivered = dsl.fetchOne(
            "SELECT count(*) AS n FROM outbox_records WHERE dynamic_id={0} AND state='SENT'",
            dynamicId,
        )!!.get("n", Int::class.java)
        assertEquals(0, delivered, "no delivery may be initiated after the cut-off")
        val pending = dsl.fetchOne(
            "SELECT count(*) AS n FROM outbox_records WHERE dynamic_id={0} AND state='PENDING'",
            dynamicId,
        )!!.get("n", Int::class.java)
        assertEquals(0, pending)
    }

    @Test
    fun `a FAILED delivery is also cancelled, so it cannot be retried later`() {
        queueDelivery()
        dsl.query("UPDATE outbox_records SET state='FAILED' WHERE dynamic_id={0}", dynamicId).execute()

        leaveBlock.block(partner, dynamicId, targetUserId = creator)

        val revivable = dsl.fetchOne(
            """SELECT count(*) AS n FROM outbox_records
                WHERE dynamic_id={0} AND state IN ('PENDING','FAILED')""",
            dynamicId,
        )!!.get("n", Int::class.java)
        assertEquals(0, revivable, "a FAILED row could otherwise be retried past the cut-off")
    }

    @Test
    fun `the blocked person is NEVER told who blocked them`() {
        leaveBlock.block(partner, dynamicId, targetUserId = creator)

        // Notion 04 §8 forbids an "X blocked you" notification. Nothing is
        // enqueued for delivery at all.
        val queued = dsl.fetchOne(
            """SELECT count(*) AS n FROM outbox_records
                WHERE dynamic_id={0} AND state='PENDING'""",
            dynamicId,
        )!!.get("n", Int::class.java)
        assertEquals(0, queued)

        // And no readable event names the blocker to the blocked person.
        val payloads = dsl.fetch(
            "SELECT object_ref::text AS r FROM relationship_events WHERE dynamic_id={0}",
            dynamicId,
        ).map { it.get("r", String::class.java) }
        assertTrue(payloads.none { it.contains(partner.toString()) },
            "the blocker's identity must not appear in a readable event payload")
    }

    @Test
    fun `blocking revokes invites so the blocked person cannot rejoin`() {
        val inv = invites.create(creator, dynamicId, RoleContext.PARTNER)
        leaveBlock.block(partner, dynamicId, targetUserId = creator)

        assertEquals("REVOKED", invites.resolve(inv.token).state)
    }

    @Test
    fun `you cannot block yourself`() {
        assertFailsWith<IllegalArgumentException> {
            leaveBlock.block(partner, dynamicId, targetUserId = partner)
        }
    }

    @Test
    fun `history itself is never deleted - the record survives`() {
        leaveBlock.block(partner, dynamicId, targetUserId = creator)

        // Access is sealed, but relationship_events is append-only: a safety
        // action must not destroy evidence of what happened.
        val n = dsl.fetchOne(
            "SELECT count(*) AS n FROM relationship_events WHERE dynamic_id={0}", dynamicId,
        )!!.get("n", Int::class.java)
        assertTrue(n > 0, "the immutable record must survive a block")
    }
}
