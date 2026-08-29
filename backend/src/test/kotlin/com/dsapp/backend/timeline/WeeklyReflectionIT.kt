package com.dsapp.backend.timeline

import com.dsapp.backend.expectation.application.CompleteOccurrenceService
import com.dsapp.backend.response.application.AcknowledgementType
import com.dsapp.backend.response.application.SendAcknowledgementService
import com.dsapp.backend.timeline.application.WeeklyReflectionService
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

/** D7 Weekly Reflection — Notion 02 §8. Deliberately light. */
@SpringBootTest
@ActiveProfiles("test")
class WeeklyReflectionIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var weekly: WeeklyReflectionService
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
               VALUES ({0},'COUPLE','CLOSER','LIGHT','ACTIVE','UTC')""", dynamicId,
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
    fun `an ANSWERED completion is a moment, an unanswered one is not`() {
        val answered = occurrence("Prepare the evening space")
        complete.complete(partner, answered, null, idem(partner))
        acknowledge.send(creator, answered, AcknowledgementType.PRAISE,
            "I noticed the care you put into this.", idem(creator))

        // Completed but never answered by a person.
        val ignored = occurrence("Tidy the entryway")
        complete.complete(partner, ignored, null, idem(partner))

        val r = weekly.forDynamic(partner, dynamicId)

        assertEquals(1, r.answeredMoments.size,
            "a completion nobody answered is not a connected moment")
        assertEquals("I noticed the care you put into this.", r.answeredMoments.single().text)
        assertEquals("Alex", r.answeredMoments.single().fromDisplayName)
    }

    @Test
    fun `there is NO score, rate or streak in the shape of the result`() {
        val occ = occurrence("x")
        complete.complete(partner, occ, null, idem(partner))
        acknowledge.send(creator, occ, AcknowledgementType.ACKNOWLEDGE, "Seen.", idem(creator))

        val r = weekly.forDynamic(partner, dynamicId)
        // Notion 03 §3 excludes a performance score outright. The result
        // carries counts of real things, never a computed rating.
        val fields = r.toString()
        for (banned in listOf("score", "rate", "streak", "percent", "grade")) {
            assertTrue(!fields.lowercase().contains(banned), "weekly exposes \"$banned\"")
        }
    }

    @Test
    fun `a connected day needs BOTH people`() {
        val occ = occurrence("x")
        complete.complete(partner, occ, null, idem(partner))
        assertEquals(0, weekly.forDynamic(partner, dynamicId).connectedDays)

        acknowledge.send(creator, occ, AcknowledgementType.ACKNOWLEDGE, "Seen.", idem(creator))
        assertEquals(1, weekly.forDynamic(partner, dynamicId).connectedDays)
    }

    @Test
    fun `adjustments worked through together are counted, not penalised`() {
        val occ = occurrence("x")
        val adj = UUID.randomUUID()
        dsl.query(
            """INSERT INTO adjustment_requests
                 (id,occurrence_id,requester_user_id,type,status,resolution,
                  resolver_user_id,resolved_at)
               VALUES ({0},{1},{2},'DISCUSS','RESOLVED','CONTINUE',{3},now())""",
            adj, occ, partner, creator,
        ).execute()

        // Adjusting together is something the week DID, not something it lost.
        assertEquals(1, weekly.forDynamic(partner, dynamicId).adjustmentsResolved)
    }

    @Test
    fun `a brand new dynamic is flagged as not having enough history`() {
        // Showing a weekly reflection on day two would invite a judgement
        // about a week that has not happened yet.
        assertTrue(!weekly.forDynamic(partner, dynamicId).hasEnoughHistory)
    }

    @Test
    fun `a week-old dynamic is ready for reflection`() {
        dsl.query("UPDATE dynamics SET created_at = now() - interval '8 days' WHERE id={0}",
            dynamicId).execute()
        assertTrue(weekly.forDynamic(partner, dynamicId).hasEnoughHistory)
    }

    @Test
    fun `a non-member cannot read the reflection`() {
        val stranger = UUID.randomUUID()
        dsl.query("INSERT INTO users (id,email) VALUES ({0},{1})", stranger, "$stranger@t").execute()
        assertFailsWith<Exception> { weekly.forDynamic(stranger, dynamicId) }
    }
}
