package com.dsapp.backend.timeline

import com.dsapp.backend.dynamic.application.DynamicNotPausable
import com.dsapp.backend.dynamic.application.DynamicQueryService
import com.dsapp.backend.expectation.application.CompleteOccurrenceService
import com.dsapp.backend.response.application.AcknowledgementType
import com.dsapp.backend.response.application.SendAcknowledgementService
import com.dsapp.backend.timeline.application.UsQueryService
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

/** Us (Notion 02 §8) and Dynamic / Pause-Resume (Journey E). */
@SpringBootTest
@ActiveProfiles("test")
class UsAndDynamicIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var us: UsQueryService
    @Autowired lateinit var dynamics: DynamicQueryService
    @Autowired lateinit var complete: CompleteOccurrenceService
    @Autowired lateinit var acknowledge: SendAcknowledgementService

    private lateinit var creator: UUID
    private lateinit var partner: UUID
    private lateinit var dynamicId: UUID

    private fun idem(actor: UUID): UUID {
        val id = UUID.randomUUID()
        dsl.query(
            """INSERT INTO idempotency_keys (id,actor_user_id,key_value,command_name,request_hash,state)
               VALUES ({0},{1},{2},'t',{3},'IN_PROGRESS')""",
            id, actor, "k-$id", ByteArray(32),
        ).execute()
        return id
    }

    @BeforeEach
    fun seed() {
        creator = UUID.randomUUID(); partner = UUID.randomUUID(); dynamicId = UUID.randomUUID()
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
    }

    private fun occurrence(title: String): UUID {
        val defId = UUID.randomUUID(); val occId = UUID.randomUUID()
        dsl.query(
            """INSERT INTO expectation_definitions
                 (id,dynamic_id,kind,title,creator_user_id,assignee_user_id,visibility)
               VALUES ({0},{1},'TASK',{2},{3},{4},'SHARED')""",
            defId, dynamicId, title, creator, partner,
        ).execute()
        dsl.query(
            """INSERT INTO occurrences (id,definition_id,dynamic_id,state,relationship_day)
               VALUES ({0},{1},{2},'ACTIVE',CURRENT_DATE)""",
            occId, defId, dynamicId,
        ).execute()
        return occId
    }

    @Test
    fun `Us shows human moments and carries the acknowledgement text verbatim`() {
        val occ = occurrence("Prepare the evening space")
        complete.complete(partner, occ, null, idem(partner))
        acknowledge.send(creator, occ, AcknowledgementType.PRAISE,
            "I noticed the care you put into this.", idem(creator))

        val moments = us.forDynamic(partner, dynamicId).moments
        assertEquals(
            listOf("acknowledgement_sent", "completion_submitted"),
            moments.map { it.eventType },
            "most recent first",
        )
        val ack = moments.first()
        assertEquals("Alex", ack.actorDisplayName)
        assertEquals("I noticed the care you put into this.", ack.text)
        assertEquals("Prepare the evening space", ack.title)
    }

    @Test
    fun `Us excludes system-generated events - a scheduler firing is not connection`() {
        // occurrence_activated is written by the system, not by a person.
        dsl.query(
            """INSERT INTO relationship_events (dynamic_id, event_type, object_ref)
               VALUES ({0},'occurrence_activated','{}'::jsonb)""", dynamicId,
        ).execute()

        assertTrue(
            us.forDynamic(partner, dynamicId).moments.none { it.eventType == "occurrence_activated" },
            "counting scheduler events as connection would inflate the North Star",
        )
    }

    @Test
    fun `a connected day requires BOTH members to have acted`() {
        val occ = occurrence("x")
        complete.complete(partner, occ, null, idem(partner))

        // Only one person has acted so far.
        assertEquals(0, us.forDynamic(partner, dynamicId).connectedDays)

        acknowledge.send(creator, occ, AcknowledgementType.ACKNOWLEDGE, "Seen.", idem(creator))
        assertEquals(1, us.forDynamic(partner, dynamicId).connectedDays)
    }

    @Test
    fun `Dynamic detail shows members, structure and inviolable agency`() {
        occurrence("Evening ritual")

        val d = dynamics.detail(partner, dynamicId)
        assertEquals("ACTIVE", d.state)
        assertEquals(setOf("Alex", "Jamie"), d.members.map { it.displayName }.toSet())
        assertEquals(listOf("Evening ritual"), d.structure.map { it.title })
        // Red line #4: these can never be switched off by any role.
        assertTrue(d.alwaysAvailable.containsAll(
            listOf("discuss", "reschedule", "cant_do", "pause", "leave", "block")))
    }

    @Test
    fun `either member may pause - it is agency, not a Dom privilege`() {
        // The receiving side pauses.
        dynamics.pause(partner, dynamicId)
        assertEquals("PAUSED", dynamics.detail(partner, dynamicId).state)

        dynamics.resume(partner, dynamicId)
        assertEquals("ACTIVE", dynamics.detail(partner, dynamicId).state)
    }

    @Test
    fun `pausing never deletes history`() {
        val occ = occurrence("x")
        complete.complete(partner, occ, null, idem(partner))
        val before = us.forDynamic(partner, dynamicId).moments.size

        dynamics.pause(creator, dynamicId)

        assertEquals(before, us.forDynamic(partner, dynamicId).moments.size,
            "Pause stops future generation; it must not erase what happened")
    }

    @Test
    fun `pausing twice is refused rather than silently repeated`() {
        dynamics.pause(creator, dynamicId)
        assertFailsWith<DynamicNotPausable> { dynamics.pause(creator, dynamicId) }
    }

    @Test
    fun `a non-member can read neither Us nor Dynamic`() {
        val stranger = UUID.randomUUID()
        dsl.query("INSERT INTO users (id,email) VALUES ({0},{1})", stranger, "$stranger@t").execute()

        assertFailsWith<Exception> { us.forDynamic(stranger, dynamicId) }
        assertFailsWith<Exception> { dynamics.detail(stranger, dynamicId) }
    }
}
