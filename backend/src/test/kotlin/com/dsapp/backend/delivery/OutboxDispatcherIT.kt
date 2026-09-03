package com.dsapp.backend.delivery

import com.dsapp.backend.delivery.application.OutboxDispatcher
import com.dsapp.backend.delivery.domain.NeutralCopy
import com.dsapp.backend.delivery.domain.NotificationChannel
import com.dsapp.backend.delivery.domain.NotificationRequest
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Primary
import org.springframework.test.context.ActiveProfiles
import java.time.Instant
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** Captures what a provider would have received. */
class RecordingChannel : NotificationChannel {
    override val name = "recording"
    val sent = mutableListOf<NotificationRequest>()
    override fun send(request: NotificationRequest) { sent += request }
}

/**
 * Outbox delivery rules — Notion 04 §6/§7/§8.
 *
 * These are the privacy and reliability guarantees, not plumbing tests.
 */
@SpringBootTest
@ActiveProfiles("test")
class OutboxDispatcherIT {

    @TestConfiguration
    class Channels {
        @Bean @Primary
        fun recording(): RecordingChannel = RecordingChannel()
    }

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var dispatcher: OutboxDispatcher
    @Autowired lateinit var channel: RecordingChannel

    private lateinit var creator: UUID
    private lateinit var partner: UUID
    private lateinit var dynamicId: UUID
    private lateinit var occurrenceId: UUID

    @BeforeEach
    fun seed() {
        channel.sent.clear()
        // dispatchOnce() is global and the test database persists across runs,
        // so leftover records from other tests would be claimed here too.
        dsl.query("DELETE FROM outbox_records").execute()
        creator = UUID.randomUUID(); partner = UUID.randomUUID()
        dynamicId = UUID.randomUUID(); occurrenceId = UUID.randomUUID()
        val defId = UUID.randomUUID()

        dsl.query("INSERT INTO users (id,email,display_name,timezone) VALUES ({0},{1},'Alex','UTC')", creator, "$creator@t").execute()
        dsl.query("INSERT INTO users (id,email,display_name,timezone) VALUES ({0},{1},'Jamie','UTC')", partner, "$partner@t").execute()
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','CLOSER','LIGHT','ACTIVE','UTC')""", dynamicId,
        ).execute()
        for ((u, r) in listOf(creator to "CREATOR", partner to "PARTNER")) {
            dsl.query(
                "INSERT INTO memberships (user_id,dynamic_id,role_context,side,access_state) VALUES ({0},{1},{2},CASE WHEN {2}='CREATOR' THEN 'D' ELSE 'S' END,'ACTIVE')",
                u, dynamicId, r,
            ).execute()
        }
        dsl.query(
            """INSERT INTO tasks (id,dynamic_id,title,kind,schedule,created_by)
               VALUES ({0},{1},'A private and intimate task title','recurring','{"type":"daily"}'::jsonb,{2})""",
            defId, dynamicId, creator,
        ).execute()
        dsl.query(
            """INSERT INTO occurrences (id,task_id,dynamic_id,day,outcome,outcome_at)
               VALUES ({0},{1},{2},CURRENT_DATE,'delivered',now())""",
            occurrenceId, defId, dynamicId,
        ).execute()
    }

    private fun enqueue(eventType: String = "occurrence_delivered", dedupe: String? = null) {
        dsl.query(
            """INSERT INTO outbox_records (aggregate_type,aggregate_id,event_type,payload,dedupe_key)
               VALUES ('occurrence',{0},{1},'{"secret":"intimate relationship detail"}'::jsonb,{2})""",
            occurrenceId, eventType, dedupe ?: "d-${UUID.randomUUID()}",
        ).execute()
    }

    /** Only the deliveries belonging to this test's occurrence. */
    private fun mine() = channel.sent.filter { it.deepLink.contains(occurrenceId.toString()) }

    private fun stateOf(): String =
        dsl.fetchOne("SELECT state FROM outbox_records WHERE aggregate_id={0} ORDER BY created_at DESC LIMIT 1",
            occurrenceId)!!.get("state", String::class.java)

    @Test
    fun `a due delivery is sent with NEUTRAL copy only`() {
        enqueue()
        dispatcher.dispatchOnce()

        assertEquals(1, mine().size)
        val req = mine().single()
        assertTrue(req.body in NeutralCopy.all, "body must be one of the fixed neutral strings")
        assertEquals(NeutralCopy.NEEDS_ATTENTION, req.body)
        assertEquals("SENT", stateOf())
    }

    @Test
    fun `PRIVACY - no relationship content reaches the provider`() {
        enqueue()
        dispatcher.dispatchOnce()

        val everything = mine().single().toString()
        // The task title and the payload's contents must not appear anywhere
        // in what the provider is handed (Notion 04 §5/§6).
        assertTrue(!everything.contains("private and intimate"),
            "the expectation title leaked into the provider request")
        assertTrue(!everything.contains("intimate relationship detail"),
            "the event payload leaked into the provider request")
    }

    @Test
    fun `a BLOCKED recipient gets nothing, and the record is cancelled`() {
        dsl.query(
            "UPDATE memberships SET access_state='BLOCKED' WHERE user_id={0} AND dynamic_id={1}",
            creator, dynamicId,
        ).execute()
        enqueue()

        dispatcher.dispatchOnce()

        assertTrue(mine().isEmpty(), "post-block delivery must be zero (Notion 04 §8)")
        assertEquals("CANCELLED", stateOf())
    }

    @Test
    fun `a member who LEFT gets nothing`() {
        dsl.query(
            "UPDATE memberships SET access_state='LEFT' WHERE user_id={0} AND dynamic_id={1}",
            creator, dynamicId,
        ).execute()
        enqueue()

        dispatcher.dispatchOnce()
        assertTrue(mine().isEmpty())
    }

    @Test
    fun `a stale reminder is not sent once the thing is already acknowledged`() {
        dsl.query(
            "UPDATE occurrences SET disposition='seen', disposition_at=now(), seen_at=now() WHERE id={0}",
            occurrenceId,
        ).execute()
        enqueue()

        dispatcher.dispatchOnce()

        assertTrue(mine().isEmpty(),
            "a reminder about something already responded to is noise")
        assertEquals("CANCELLED", stateOf())
    }

    @Test
    fun `a paused dynamic suppresses delivery`() {
        dsl.query("UPDATE dynamics SET state='PAUSED', paused_at=now() WHERE id={0}", dynamicId).execute()
        enqueue()

        dispatcher.dispatchOnce()
        assertTrue(mine().isEmpty())
    }

    @Test
    fun `quiet hours DELAY delivery without dropping the event`() {
        // Quiet hours covering the whole day, in the recipient's own timezone.
        dsl.query(
            "UPDATE users SET quiet_hours_start_min=0, quiet_hours_end_min=1439 WHERE id={0}",
            creator,
        ).execute()
        enqueue()

        dispatcher.dispatchOnce()

        assertTrue(mine().isEmpty(), "nothing should be sent during quiet hours")
        // Still PENDING: quiet hours suppress DELIVERY, never the domain event.
        assertEquals("PENDING", stateOf())
        val notBefore = dsl.fetchOne(
            "SELECT not_before FROM outbox_records WHERE aggregate_id={0}", occurrenceId,
        )!!.get("not_before", Instant::class.java)
        assertTrue(notBefore.isAfter(Instant.now()), "delivery must be deferred, not dropped")
    }

    @Test
    fun `several things waiting out quiet hours become one message`() {
        // Three events pile up overnight. Notion 04 Section 7:
        // "quiet hours 结束后聚合，不逐条补 6 条旧通知."
        //
        // Waking to three notifications about a night that has already
        // passed is worse than having been left alone, and each points at
        // something the person may already have dealt with.
        val past = Instant.now().minusSeconds(60)
        repeat(3) {
            enqueue()
        }
        dsl.query(
            "UPDATE outbox_records SET deferred_until={1}, not_before={1} " +
                "WHERE aggregate_id={0}",
            occurrenceId, past,
        ).execute()

        dispatcher.dispatchOnce()

        val delivered = mine()
        assertEquals(
            1, delivered.size,
            "the backlog must collapse to one message, got " + delivered.size,
        )
        assertEquals(NeutralCopy.WHILE_YOU_WERE_AWAY, delivered.single().body)

        // CANCELLED, not FAILED: nothing went wrong, the telling was
        // collapsed. That distinction matters for observability.
        val cancelled = dsl.fetchOne(
            "SELECT count(*) AS n FROM outbox_records WHERE aggregate_id={0} " +
                "AND state='CANCELLED' AND last_error='AGGREGATED'",
            occurrenceId,
        )!!.get("n", Int::class.java)
        assertEquals(2, cancelled)
    }

    @Test
    fun `one thing waiting still gets its own specific line`() {
        // Aggregation must not make every notification vague.
        enqueue()
        dsl.query(
            "UPDATE outbox_records SET deferred_until={1}, not_before={1} " +
                "WHERE aggregate_id={0}",
            occurrenceId, Instant.now().minusSeconds(60),
        ).execute()

        dispatcher.dispatchOnce()

        val delivered = mine()
        assertEquals(1, delivered.size)
        assertTrue(
            delivered.single().body != NeutralCopy.WHILE_YOU_WERE_AWAY,
            "one waiting item should not read as a night's summary",
        )
    }

    @Test
    fun `an ordinary burst during the day is never collapsed`() {
        // deferred_until is set ONLY by quiet hours. Retry backoff moves
        // not_before too, so aggregating on that would silently hide real
        // events behind one vague line.
        repeat(2) { enqueue() }

        dispatcher.dispatchOnce()
        dispatcher.dispatchOnce()

        assertEquals(2, mine().size, "daytime deliveries must each be sent")
        assertTrue(mine().none { it.body == NeutralCopy.WHILE_YOU_WERE_AWAY })
    }

    @Test
    fun `a retry does not double-send`() {
        enqueue()
        dispatcher.dispatchOnce()
        dispatcher.dispatchOnce()   // second pass: nothing left to claim

        assertEquals(1, mine().size, "a SENT record must never be claimed again")
    }

    @Test
    fun `the dedupe key is passed to the provider for its own idempotency`() {
        enqueue(dedupe = "stable-key-1")
        dispatcher.dispatchOnce()

        assertEquals("stable-key-1", mine().single().dedupeKey)
    }
}
