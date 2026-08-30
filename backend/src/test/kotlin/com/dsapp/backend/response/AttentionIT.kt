package com.dsapp.backend.response

import com.dsapp.backend.response.application.AttentionQueryService
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

/** Attention ordering — Journey C (Notion 02 §4). */
@SpringBootTest
@ActiveProfiles("test")
class AttentionIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var attention: AttentionQueryService

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
        dsl.query(
            "INSERT INTO memberships (user_id,dynamic_id,role_context,access_state) VALUES ({0},{1},'CREATOR','ACTIVE')",
            creator, dynamicId,
        ).execute()
        dsl.query(
            "INSERT INTO memberships (user_id,dynamic_id,role_context,access_state) VALUES ({0},{1},'PARTNER','ACTIVE')",
            partner, dynamicId,
        ).execute()
    }

    private fun occurrence(title: String, state: String): UUID {
        val defId = UUID.randomUUID()
        val occId = UUID.randomUUID()
        dsl.query(
            """INSERT INTO expectation_definitions
                 (id,dynamic_id,kind,title,creator_user_id,assignee_user_id,visibility)
               VALUES ({0},{1},'TASK',{2},{3},{4},'SHARED')""",
            defId, dynamicId, title, creator, partner,
        ).execute()
        dsl.query(
            """INSERT INTO occurrences (id,definition_id,dynamic_id,state,relationship_day)
               VALUES ({0},{1},{2},{3},CURRENT_DATE)""",
            occId, defId, dynamicId, state,
        ).execute()
        return occId
    }

    @Test
    fun `discuss outranks waiting-for-ack, which outranks needs-review`() {
        // Inserted in the WRONG order on purpose: ordering must come from the
        // journey's priority, not insertion or recency.
        occurrence("c needs review", "NEEDS_REVIEW")
        occurrence("b waiting", "WAITING_ACK")
        occurrence("a discuss", "NEED_TO_DISCUSS")

        val result = attention.forDynamic(creator, dynamicId)

        assertEquals(
            listOf("NEED_TO_DISCUSS", "WAITING_ACK", "NEEDS_REVIEW"),
            result.items.map { it.state },
            "Journey C fixes this order: discussion first, then awaiting response, then review",
        )
    }

    @Test
    fun `counts separate what needs a response from what needs review`() {
        occurrence("x", "WAITING_ACK")
        occurrence("y", "WAITING_ACK")
        occurrence("z", "NEEDS_REVIEW")

        val r = attention.forDynamic(creator, dynamicId)
        assertEquals(2, r.needsResponseCount)
        assertEquals(1, r.needsReviewCount)
    }

    @Test
    fun `a partner waiting on an answer is counted as needing a response`() {
        // These three sort FIRST — they are the most urgent thing on the
        // screen — and they were counted nowhere. A badge built on this would
        // have read "1" while three people waited.
        occurrence("they asked to discuss", "NEED_TO_DISCUSS")
        occurrence("they asked for a new time", "RESCHEDULE_REQUESTED")
        occurrence("they said they cannot", "EXCUSE_REQUESTED")
        occurrence("they completed something", "WAITING_ACK")

        val r = attention.forDynamic(creator, dynamicId)

        assertEquals(4, r.needsResponseCount)
        assertEquals(0, r.needsReviewCount)
    }

    @Test
    fun `work needing review is not counted as awaiting a response`() {
        // Past due is a fact, not a question someone asked. REQ-REVIEW-001
        // also forbids the software assigning consequence, and folding review
        // into "you owe an answer" is a small way of doing exactly that.
        occurrence("still open", "NEEDS_REVIEW")

        val r = attention.forDynamic(creator, dynamicId)

        assertEquals(0, r.needsResponseCount)
        assertEquals(1, r.needsReviewCount)
    }

    @Test
    fun `settled occurrences do not clutter Attention`() {
        occurrence("done and seen", "ACKNOWLEDGED")
        occurrence("cancelled", "CANCELLED")
        occurrence("still active", "ACTIVE")

        // Nothing here needs a human response, so Attention stays empty —
        // the direction-giving side must not be handed busywork.
        assertTrue(attention.forDynamic(creator, dynamicId).items.isEmpty())
    }

    @Test
    fun `a completion carries the name of the person who acted`() {
        val occId = occurrence("Prepare the evening space", "WAITING_ACK")
        val idem = UUID.randomUUID()
        dsl.query(
            """INSERT INTO idempotency_keys (id,actor_user_id,key_value,command_name,request_hash,state)
               VALUES ({0},{1},{2},'t',{3},'IN_PROGRESS')""",
            idem, partner, "k-$idem", ByteArray(32),
        ).execute()
        dsl.query(
            """INSERT INTO occurrence_completions (occurrence_id,actor_user_id,idempotency_id)
               VALUES ({0},{1},{2})""",
            occId, partner, idem,
        ).execute()

        val item = attention.forDynamic(creator, dynamicId).items.single()
        // A response is addressed to a person, not to a task.
        assertEquals("Jamie", item.actorDisplayName)
    }

    @Test
    fun `a non-member cannot read Attention`() {
        val stranger = UUID.randomUUID()
        dsl.query("INSERT INTO users (id,email) VALUES ({0},{1})", stranger, "$stranger@t").execute()
        occurrence("private", "WAITING_ACK")

        assertFailsWith<Exception> { attention.forDynamic(stranger, dynamicId) }
    }
}
