package com.dsapp.backend.expectation

import com.dsapp.backend.expectation.application.TodayQueryService
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
import kotlin.test.assertTrue

/** Today — Journey B (Notion 02 §3). */
@SpringBootTest
@ActiveProfiles("test")
class TodayIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var today: TodayQueryService

    private lateinit var creator: UUID
    private lateinit var partner: UUID
    private lateinit var dynamicId: UUID

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

    private fun expectation(title: String, state: String, assignee: UUID = partner): UUID {
        val defId = UUID.randomUUID(); val occId = UUID.randomUUID()
        dsl.query(
            """INSERT INTO expectation_definitions
                 (id,dynamic_id,kind,title,purpose,creator_user_id,assignee_user_id,visibility)
               VALUES ({0},{1},'TASK',{2},'A small act of care.',{3},{4},'SHARED')""",
            defId, dynamicId, title, creator, assignee,
        ).execute()
        dsl.query(
            """INSERT INTO occurrences (id,definition_id,dynamic_id,state,relationship_day)
               VALUES ({0},{1},{2},{3},CURRENT_DATE)""",
            occId, defId, dynamicId, state,
        ).execute()
        return occId
    }

    @Test
    fun `Today shows only what is assigned to me`() {
        expectation("mine", "ACTIVE", assignee = partner)
        expectation("theirs", "ACTIVE", assignee = creator)

        val t = today.forDynamic(partner, dynamicId)
        assertEquals(listOf("mine"), t.priorityItems.map { it.title })
    }

    @Test
    fun `Today shows three priorities and keeps the rest as Later`() {
        repeat(6) { expectation("item $it", "ACTIVE") }

        val t = today.forDynamic(partner, dynamicId)
        // Notion 02 §3 asks for 1-3 important expectations first; SCR-01 rev 2
        // keeps the remainder reachable behind one disclosure instead of
        // discarding it. Truncating server-side made the Later row impossible.
        assertEquals(3, t.priorityItems.size)
        assertEquals(3, t.laterItems.size)
        assertEquals(6, t.totalCount)
    }

    @Test
    fun `a relationship day holds at most ten actionable items`() {
        repeat(14) { expectation("item $it", "ACTIVE") }

        val t = today.forDynamic(partner, dynamicId)
        // Beyond ten is a read-model contract violation. The server bounds it
        // rather than letting the client invent pagination.
        assertEquals(3, t.priorityItems.size)
        assertEquals(7, t.laterItems.size)
    }

    @Test
    fun `the relationship day comes from the Dynamic zone, not the server clock`() {
        expectation("anything", "ACTIVE")

        val t = today.forDynamic(partner, dynamicId)
        // Whatever the JVM default zone is, the day must be resolved in the
        // Dynamic's own reference timezone.
        val expected = com.dsapp.backend.shared.time.RelationshipDay.dayOf(
            instant = t.lastConfirmedAt,
            zone = java.time.ZoneId.of(
                dsl.fetchOne(
                    "SELECT reference_timezone FROM dynamics WHERE id = {0}",
                    dynamicId,
                )!!.get("reference_timezone", String::class.java),
            ),
            boundaryMinutes = 0,
        )
        assertEquals(expected, t.relationshipDay)
    }

    @Test
    fun `completed work moves out of the action list and into awaiting response`() {
        expectation("still to do", "ACTIVE")
        expectation("already done", "WAITING_ACK")

        val t = today.forDynamic(partner, dynamicId)
        assertEquals(listOf("still to do"), t.priorityItems.map { it.title })
        assertEquals(listOf("already done"), t.awaitingResponse.map { it.title })
    }

    @Test
    fun `settled work does not clutter Today`() {
        expectation("acknowledged", "ACKNOWLEDGED")
        expectation("cancelled", "CANCELLED")

        val t = today.forDynamic(partner, dynamicId)
        assertTrue(t.priorityItems.isEmpty())
        assertTrue(t.laterItems.isEmpty())
        assertTrue(t.awaitingResponse.isEmpty())
    }

    @Test
    fun `an expectation carries who it came from - direction comes from a person`() {
        expectation("Prepare the evening space", "ACTIVE")

        val item = today.forDynamic(partner, dynamicId).priorityItems.single()
        assertEquals("Alex", item.fromDisplayName)
        assertEquals("A small act of care.", item.purpose)
    }

    @Test
    fun `the most recent human response is surfaced - presence while apart`() {
        val occ = expectation("Prepare the evening space", "ACKNOWLEDGED")
        val idem = UUID.randomUUID()
        dsl.query(
            """INSERT INTO idempotency_keys (id,actor_user_id,key_value,command_name,request_hash,state)
               VALUES ({0},{1},{2},'t',{3},'IN_PROGRESS')""",
            idem, creator, "k-$idem", ByteArray(32),
        ).execute()
        dsl.query(
            """INSERT INTO acknowledgements (occurrence_id,sender_user_id,type,text,idempotency_id)
               VALUES ({0},{1},'PRAISE','I noticed the care you put into this.',{2})""",
            occ, creator, idem,
        ).execute()

        val r = today.forDynamic(partner, dynamicId).recentResponse
        assertNotNull(r)
        assertEquals("I noticed the care you put into this.", r.text)
        // Attributed to the real sender, never to the system (red line #1).
        assertEquals("Alex", r.senderDisplayName)
    }

    @Test
    fun `no response yet means no fabricated encouragement`() {
        expectation("waiting", "WAITING_ACK")

        // The system must not invent something warm to fill the gap.
        assertNull(today.forDynamic(partner, dynamicId).recentResponse)
    }

    @Test
    fun `a non-member cannot read Today`() {
        val stranger = UUID.randomUUID()
        dsl.query("INSERT INTO users (id,email) VALUES ({0},{1})", stranger, "$stranger@t").execute()
        expectation("private", "ACTIVE")

        assertFailsWith<Exception> { today.forDynamic(stranger, dynamicId) }
    }
}
