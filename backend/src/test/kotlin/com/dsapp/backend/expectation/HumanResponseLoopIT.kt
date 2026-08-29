package com.dsapp.backend.expectation

import com.dsapp.backend.dynamic.domain.AuthorizationException
import com.dsapp.backend.expectation.application.CompleteOccurrenceService
import com.dsapp.backend.expectation.application.OccurrenceNotCompletable
import com.dsapp.backend.response.application.AcknowledgementType
import com.dsapp.backend.response.application.OccurrenceNotAcknowledgeable
import com.dsapp.backend.response.application.SendAcknowledgementService
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

/**
 * The M1 vertical slice: Complete -> WaitingAck -> human Acknowledge.
 *
 * These tests exist to defend the product red lines, not just the code paths.
 */
@SpringBootTest
@ActiveProfiles("test")
class HumanResponseLoopIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var complete: CompleteOccurrenceService
    @Autowired lateinit var acknowledge: SendAcknowledgementService

    private lateinit var creator: UUID
    private lateinit var partner: UUID
    private lateinit var dynamicId: UUID
    private lateinit var occurrenceId: UUID

    private fun idem(actor: UUID): UUID {
        val id = UUID.randomUUID()
        dsl.query(
            """INSERT INTO idempotency_keys (id, actor_user_id, key_value, command_name, request_hash, state)
               VALUES ({0}, {1}, {2}, 'test', {3}, 'IN_PROGRESS')""",
            id, actor, "k-$id", ByteArray(32),
        ).execute()
        return id
    }

    private fun state(): String =
        dsl.fetchOne("SELECT state FROM occurrences WHERE id = {0}", occurrenceId)!!
            .get("state", String::class.java)

    private fun ackCount(): Int =
        dsl.fetchOne("SELECT count(*) FROM acknowledgements WHERE occurrence_id = {0}", occurrenceId)!!
            .get(0, Int::class.java)

    @BeforeEach
    fun seed() {
        creator = UUID.randomUUID(); partner = UUID.randomUUID()
        dynamicId = UUID.randomUUID(); occurrenceId = UUID.randomUUID()
        val defId = UUID.randomUUID()

        dsl.query("INSERT INTO users (id,email) VALUES ({0},{1})", creator, "$creator@t.local").execute()
        dsl.query("INSERT INTO users (id,email) VALUES ({0},{1})", partner, "$partner@t.local").execute()
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','CLOSER','LIGHT','ACTIVE','America/New_York')""", dynamicId,
        ).execute()
        dsl.query(
            """INSERT INTO memberships (user_id,dynamic_id,role_context,access_state)
               VALUES ({0},{1},'CREATOR','ACTIVE')""", creator, dynamicId,
        ).execute()
        dsl.query(
            """INSERT INTO memberships (user_id,dynamic_id,role_context,access_state)
               VALUES ({0},{1},'PARTNER','ACTIVE')""", partner, dynamicId,
        ).execute()
        dsl.query(
            """INSERT INTO expectation_definitions (id,dynamic_id,kind,title,creator_user_id,assignee_user_id,visibility)
               VALUES ({0},{1},'TASK','Prepare the evening space',{2},{3},'SHARED')""",
            defId, dynamicId, creator, partner,
        ).execute()
        dsl.query(
            """INSERT INTO occurrences (id,definition_id,dynamic_id,state,relationship_day)
               VALUES ({0},{1},{2},'ACTIVE',CURRENT_DATE)""",
            occurrenceId, defId, dynamicId,
        ).execute()
    }

    @Test
    fun `RED LINE - completing does NOT create an acknowledgement`() {
        complete.complete(partner, occurrenceId, "done", idem(partner))

        assertEquals("WAITING_ACK", state(), "completion must land in WAITING_ACK, not ACKNOWLEDGED")
        assertEquals(0, ackCount(), "completing must NEVER auto-create partner praise")
    }

    @Test
    fun `full loop - complete then human acknowledge`() {
        complete.complete(partner, occurrenceId, null, idem(partner))
        assertEquals("WAITING_ACK", state())

        acknowledge.send(creator, occurrenceId, AcknowledgementType.PRAISE, "I noticed the care.", idem(creator))
        assertEquals("ACKNOWLEDGED", state())
        assertEquals(1, ackCount())

        val row = dsl.fetchOne(
            "SELECT sender_user_id, text FROM acknowledgements WHERE occurrence_id = {0}", occurrenceId,
        )!!
        assertEquals(creator, row.get("sender_user_id", UUID::class.java), "sender must be the human creator")
        assertEquals("I noticed the care.", row.get("text", String::class.java))
    }

    @Test
    fun `acknowledgement cannot precede a completion`() {
        assertFailsWith<OccurrenceNotAcknowledgeable> {
            acknowledge.send(creator, occurrenceId, AcknowledgementType.ACKNOWLEDGE, "too early", idem(creator))
        }
        assertEquals(0, ackCount())
        assertEquals("ACTIVE", state())
    }

    @Test
    fun `double complete produces only one completion`() {
        complete.complete(partner, occurrenceId, null, idem(partner))
        assertFailsWith<OccurrenceNotCompletable> {
            complete.complete(partner, occurrenceId, null, idem(partner))
        }
        val n = dsl.fetchOne(
            "SELECT count(*) FROM occurrence_completions WHERE occurrence_id = {0}", occurrenceId,
        )!!.get(0, Int::class.java)
        assertEquals(1, n)
    }

    @Test
    fun `creator cannot complete and partner cannot acknowledge`() {
        // Roles are not interchangeable: each command is bound to one role.
        assertFailsWith<AuthorizationException.WrongRole> {
            complete.complete(creator, occurrenceId, null, idem(creator))
        }
        complete.complete(partner, occurrenceId, null, idem(partner))
        assertFailsWith<AuthorizationException.WrongRole> {
            acknowledge.send(partner, occurrenceId, AcknowledgementType.PRAISE, "self-praise", idem(partner))
        }
        assertEquals(0, ackCount())
    }

    @Test
    fun `a blocked member cannot act`() {
        dsl.query(
            "UPDATE memberships SET access_state='BLOCKED' WHERE user_id={0} AND dynamic_id={1}",
            partner, dynamicId,
        ).execute()
        assertFailsWith<AuthorizationException.NotAMember> {
            complete.complete(partner, occurrenceId, null, idem(partner))
        }
        assertEquals("ACTIVE", state())
    }

    @Test
    fun `a paused dynamic refuses mutations`() {
        dsl.query("UPDATE dynamics SET state='PAUSED' WHERE id={0}", dynamicId).execute()
        assertFailsWith<AuthorizationException.DynamicNotActive> {
            complete.complete(partner, occurrenceId, null, idem(partner))
        }
    }

    @Test
    fun `each business action emits exactly one relationship event and one outbox record`() {
        complete.complete(partner, occurrenceId, null, idem(partner))
        acknowledge.send(creator, occurrenceId, AcknowledgementType.ACKNOWLEDGE, "seen", idem(creator))

        val events = dsl.fetch(
            "SELECT event_type FROM relationship_events WHERE dynamic_id = {0} ORDER BY occurred_at", dynamicId,
        ).map { it.get("event_type", String::class.java) }
        assertEquals(listOf("completion_submitted", "acknowledgement_sent"), events)

        val outbox = dsl.fetch(
            "SELECT event_type FROM outbox_records WHERE aggregate_id = {0} ORDER BY created_at", occurrenceId,
        ).map { it.get("event_type", String::class.java) }
        assertEquals(listOf("completion_submitted", "acknowledgement_sent"), outbox)
    }
}
