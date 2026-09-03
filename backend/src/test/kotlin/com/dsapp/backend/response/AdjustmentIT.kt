package com.dsapp.backend.response

import com.dsapp.backend.expectation.application.CompleteOccurrenceService
import com.dsapp.backend.response.application.AdjustmentNotPossible
import com.dsapp.backend.response.application.AdjustmentResolution
import com.dsapp.backend.response.application.AdjustmentService
import com.dsapp.backend.response.application.AdjustmentType
import com.dsapp.backend.response.application.NoOpenAdjustment
import com.dsapp.backend.response.application.NotTheRequester
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.time.Instant
import java.time.LocalDate
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * The adjustment path — Journey D (Notion 02 §5).
 *
 * These tests defend product the invariant: adjustment is the NORMAL path when
 * life gets in the way. Nothing here may behave like a miss or a punishment.
 */
@SpringBootTest
@ActiveProfiles("test")
class AdjustmentIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var adjustments: AdjustmentService
    @Autowired lateinit var complete: CompleteOccurrenceService

    private lateinit var creator: UUID
    private lateinit var partner: UUID
    private lateinit var dynamicId: UUID
    private lateinit var definitionId: UUID
    private lateinit var occurrenceId: UUID

    private fun idem(actor: UUID): UUID {
        val id = UUID.randomUUID()
        dsl.query(
            """INSERT INTO idempotency_keys (id,actor_user_id,key_value,command_name,request_hash,state)
               VALUES ({0},{1},{2},'t',{3},'IN_PROGRESS')""",
            id, actor, "k-$id", ByteArray(32),
        ).execute()
        return id
    }

    private fun stateOf(id: UUID = occurrenceId): String =
        dsl.fetchOne("SELECT state FROM occurrences WHERE id={0}", id)!!.get("state", String::class.java)

    @BeforeEach
    fun seed() {
        creator = UUID.randomUUID(); partner = UUID.randomUUID()
        dynamicId = UUID.randomUUID(); definitionId = UUID.randomUUID(); occurrenceId = UUID.randomUUID()

        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Alex')", creator, "$creator@t").execute()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Jamie')", partner, "$partner@t").execute()
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','CLOSER','LIGHT','ACTIVE','America/New_York')""", dynamicId,
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
            definitionId, dynamicId, creator, partner,
        ).execute()
        dsl.query(
            """INSERT INTO occurrences (id,definition_id,dynamic_id,state,relationship_day)
               VALUES ({0},{1},{2},'ACTIVE',CURRENT_DATE)""",
            occurrenceId, definitionId, dynamicId,
        ).execute()
    }

    // ---- requesting ----

    @Test
    fun `the RECEIVING side can ask to discuss - this is agency, not a privilege`() {
        val r = adjustments.request(partner, occurrenceId, AdjustmentType.DISCUSS,
            "Can we talk about this one?", idempotencyId = idem(partner))

        assertEquals("NEED_TO_DISCUSS", r.occurrenceState)
        assertEquals("NEED_TO_DISCUSS", stateOf())
    }

    @Test
    fun `asking is NOT a miss - no failure state is ever produced`() {
        for (type in AdjustmentType.entries) {
            // Fresh occurrence per type.
            val occ = UUID.randomUUID()
            val def = UUID.randomUUID()
            dsl.query(
                """INSERT INTO expectation_definitions
                     (id,dynamic_id,kind,title,creator_user_id,assignee_user_id,visibility)
                   VALUES ({0},{1},'TASK',{2},{3},{4},'SHARED')""",
                def, dynamicId, "t-$type", creator, partner,
            ).execute()
            dsl.query(
                """INSERT INTO occurrences (id,definition_id,dynamic_id,state,relationship_day)
                   VALUES ({0},{1},{2},'ACTIVE',CURRENT_DATE)""",
                occ, def, dynamicId,
            ).execute()

            adjustments.request(partner, occ, type, null, idempotencyId = idem(partner))

            val s = stateOf(occ)
            assertTrue(
                s in setOf("NEED_TO_DISCUSS", "RESCHEDULE_REQUESTED", "EXCUSE_REQUESTED"),
                "$type produced $s",
            )
            // Invariant: nothing resembling failure or punishment.
            assertTrue(!s.contains("MISS") && !s.contains("FAIL"), "$type looks punitive: $s")
        }
    }

    @Test
    fun `only one open request per occurrence`() {
        adjustments.request(partner, occurrenceId, AdjustmentType.DISCUSS, null, idempotencyId = idem(partner))
        // The occurrence is no longer ACTIVE, so a second ask is refused
        // rather than leaving the partner with two competing questions.
        assertFailsWith<AdjustmentNotPossible> {
            adjustments.request(partner, occurrenceId, AdjustmentType.CANT_DO, null, idempotencyId = idem(partner))
        }
    }

    // ---- resolving ----

    @Test
    fun `CONTINUE returns to ACTIVE - resolving never manufactures a completion`() {
        adjustments.request(partner, occurrenceId, AdjustmentType.DISCUSS, null, idempotencyId = idem(partner))
        val r = adjustments.resolve(creator, occurrenceId, AdjustmentResolution.CONTINUE,
            "Let's keep going.", idempotencyId = idem(creator))

        assertEquals("ACTIVE", r.occurrenceState)
        // NOT WAITING_ACK: that would claim a completion that never happened,
        // the same class of lie as auto-generating partner praise.
        assertTrue(
            dsl.fetchOne("SELECT 1 FROM occurrence_completions WHERE occurrence_id={0}", occurrenceId) == null,
            "no completion may be fabricated by resolving a discussion",
        )
    }

    @Test
    fun `EXCUSE is a clean ending, not a failure`() {
        adjustments.request(partner, occurrenceId, AdjustmentType.CANT_DO,
            "I'm ill today.", idempotencyId = idem(partner))
        val r = adjustments.resolve(creator, occurrenceId, AdjustmentResolution.EXCUSE,
            "Rest.", idempotencyId = idem(creator))

        assertEquals("EXCUSED", r.occurrenceState)
    }

    @Test
    fun `RESCHEDULE creates a new occurrence and NEVER erases the original`() {
        adjustments.request(partner, occurrenceId, AdjustmentType.RESCHEDULE,
            "Tomorrow instead?", requestedAt = Instant.now().plusSeconds(86_400),
            idempotencyId = idem(partner))

        val tomorrow = Instant.now().plusSeconds(86_400)
        val r = adjustments.resolve(creator, occurrenceId, AdjustmentResolution.RESCHEDULE,
            "Of course.", newTime = tomorrow, idempotencyId = idem(creator))

        assertNotNull(r.replacementOccurrenceId)
        assertEquals("ACTIVE", stateOf(r.replacementOccurrenceId!!))

        // The original still exists — history is never rewritten (Notion 03 §4).
        assertEquals("CANCELLED", stateOf(occurrenceId))
        assertNotNull(
            dsl.fetchOne("SELECT 1 FROM occurrences WHERE id={0}", occurrenceId),
            "the original occurrence must remain on record",
        )
    }

    @Test
    fun `a rescheduled original is distinguishable from a plain cancellation`() {
        adjustments.request(partner, occurrenceId, AdjustmentType.RESCHEDULE, null,
            idempotencyId = idem(partner))
        adjustments.resolve(creator, occurrenceId, AdjustmentResolution.RESCHEDULE,
            null, newTime = Instant.now().plusSeconds(86_400), idempotencyId = idem(creator))

        // Both are stored CANCELLED, so the UI needs this link to say
        // "Rescheduled to ..." instead of "Cancelled" — which would read as a
        // failure the person caused.
        val replacement = dsl.fetchOne(
            "SELECT replacement_occurrence_id FROM adjustment_requests WHERE occurrence_id={0}",
            occurrenceId,
        )!!.get("replacement_occurrence_id", UUID::class.java)
        assertNotNull(replacement)
    }

    @Test
    fun `rescheduling within the same day does not collide with the uniqueness index`() {
        adjustments.request(partner, occurrenceId, AdjustmentType.RESCHEDULE, null,
            idempotencyId = idem(partner))
        // Same relationship day, a few hours later.
        val r = adjustments.resolve(creator, occurrenceId, AdjustmentResolution.RESCHEDULE,
            null, newTime = Instant.now().plusSeconds(3600), idempotencyId = idem(creator))

        // The original is CANCELLED (terminal), so the partial unique index on
        // non-terminal occurrences per definition/day permits the replacement.
        assertNotNull(r.replacementOccurrenceId)
    }

    @Test
    fun `resolving with nothing open is refused`() {
        assertFailsWith<NoOpenAdjustment> {
            adjustments.resolve(creator, occurrenceId, AdjustmentResolution.CONTINUE,
                null, idempotencyId = idem(creator))
        }
    }

    @Test
    fun `after CONTINUE the person can still complete normally`() {
        adjustments.request(partner, occurrenceId, AdjustmentType.DISCUSS, null, idempotencyId = idem(partner))
        adjustments.resolve(creator, occurrenceId, AdjustmentResolution.CONTINUE, null, idempotencyId = idem(creator))

        // The whole point: the loop resumes as if life simply happened.
        complete.complete(partner, occurrenceId, "Done now.", idem(partner))
        assertEquals("WAITING_ACK", stateOf())
    }

    @Test
    fun `an adjustment emits domain events for the timeline`() {
        adjustments.request(partner, occurrenceId, AdjustmentType.DISCUSS, null, idempotencyId = idem(partner))
        adjustments.resolve(creator, occurrenceId, AdjustmentResolution.CONTINUE, null, idempotencyId = idem(creator))

        val types = dsl.fetch(
            "SELECT event_type FROM relationship_events WHERE dynamic_id={0} ORDER BY occurred_at",
            dynamicId,
        ).map { it.get("event_type", String::class.java) }
        assertEquals(listOf("adjustment_requested", "adjustment_resolved"), types)
    }

    // --- withdraw -------------------------------------------------------
    //
    // `AllowedActions` advertised `withdraw` to the requester from the start
    // and nothing implemented it, so an item someone had asked to discuss was
    // a dead end for its own author.

    @Test
    fun `the person who asked can take the request back`() {
        adjustments.request(
            partner, occurrenceId, AdjustmentType.DISCUSS, "can we talk",
            null, idem(partner),
        )
        assertEquals("NEED_TO_DISCUSS", stateOf())

        val r = adjustments.withdraw(partner, occurrenceId)

        assertEquals("ACTIVE", r.occurrenceState)
        assertEquals("ACTIVE", stateOf(), "back to where it was before asking")
    }

    @Test
    fun `withdrawing records no resolution and no resolver`() {
        // Nobody resolved anything: the request ended because the person who
        // made it no longer needed it.
        adjustments.request(
            partner, occurrenceId, AdjustmentType.DISCUSS, null, null, idem(partner),
        )
        adjustments.withdraw(partner, occurrenceId)

        val row = dsl.fetchOne(
            "SELECT status, resolution, resolver_user_id, resolved_at " +
                "FROM adjustment_requests WHERE occurrence_id={0}",
            occurrenceId,
        )!!
        assertEquals("WITHDRAWN", row.get("status", String::class.java))
        assertNull(row.get("resolution", String::class.java))
        assertNull(row.get("resolver_user_id", UUID::class.java))
        assertNotNull(row.get("resolved_at", Instant::class.java))
    }

    @Test
    fun `the other person cannot withdraw a request that is not theirs`() {
        // Withdrawing on someone else's behalf would be the "reject" that
        // Journey D's vocabulary exists to prevent.
        adjustments.request(
            partner, occurrenceId, AdjustmentType.DISCUSS, null, null, idem(partner),
        )
        assertFailsWith<NotTheRequester> {
            adjustments.withdraw(creator, occurrenceId)
        }
        assertEquals("NEED_TO_DISCUSS", stateOf(), "nothing changed")
    }

    @Test
    fun `withdrawing when nothing is open is refused`() {
        assertFailsWith<NoOpenAdjustment> {
            adjustments.withdraw(partner, occurrenceId)
        }
    }

    @Test
    fun `a withdrawal is not recorded as an adjustment being resolved`() {
        // Crediting the pair with working something out they never discussed
        // would inflate the one signal Us and the weekly reflection report.
        adjustments.request(
            partner, occurrenceId, AdjustmentType.DISCUSS, null, null, idem(partner),
        )
        adjustments.withdraw(partner, occurrenceId)

        val resolved = dsl.fetch(
            "SELECT 1 FROM relationship_events WHERE dynamic_id={0} " +
                "AND event_type='adjustment_resolved'",
            dynamicId,
        )
        assertTrue(resolved.isEmpty(), "no adjustment_resolved event")

        val withdrawn = dsl.fetch(
            "SELECT 1 FROM relationship_events WHERE dynamic_id={0} " +
                "AND event_type='adjustment_withdrawn'",
            dynamicId,
        )
        assertEquals(1, withdrawn.size, "the withdrawal itself is recorded")
    }
}
