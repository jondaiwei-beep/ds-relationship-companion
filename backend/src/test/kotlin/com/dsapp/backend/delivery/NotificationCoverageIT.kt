package com.dsapp.backend.delivery

import com.dsapp.backend.delivery.application.OutboxDispatcher
import com.dsapp.backend.delivery.domain.EventCopy
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.time.LocalDate
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/**
 * Coverage test for product/02-surfaces.md's notification table: every
 * listed event type must resolve a real recipient AND have real copy — not
 * just fall through to the generic fallback.
 *
 * "delivered_late" is not a distinct outbox event_type: OutcomeService emits
 * the same `occurrence_delivered` event whether the s delivered on time or
 * late (the lateness lives in the occurrence row, not the event name), so it
 * is exercised here via the `occurrence_delivered` case, not separately.
 * "checkin delivered" is likewise not a distinct event type: a check-in is a
 * TaskKind delivered through the same OutcomeService path as any other s
 * delivery, so it is covered by `occurrence_delivered` too — this domain has
 * no D-authored check-in to test the "whichever side didn't send it" branch
 * against.
 */
@SpringBootTest
@ActiveProfiles("test")
class NotificationCoverageIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var dispatcher: OutboxDispatcher

    private lateinit var d: UUID
    private lateinit var s: UUID
    private lateinit var dynamicId: UUID
    private lateinit var taskId: UUID
    private lateinit var occurrenceId: UUID
    private lateinit var ruleId: UUID
    private lateinit var redemptionId: UUID
    private lateinit var consequenceId: UUID
    private lateinit var dNoteId: UUID
    private lateinit var dayCommentId: UUID
    private lateinit var pointEntryId: UUID

    /** Every event type required by product/02-surfaces.md's 通知 table, mapped to who must receive it. */
    private val requiredEventTypes = mapOf(
        "occurrence_delivered" to "s delivers -> D",
        "occurrence_flagged" to "cant_do/new_time_requested/discuss_requested -> D",
        "disposition_set" to "D's disposition -> s",
        "day_comment" to "day comment -> the other side",
        "d_award" to "D's award -> s",
        "redemption_requested" to "s requests -> D",
        "redemption_decided" to "D approves/denies -> s",
        "redemption_fulfilled" to "D fulfills -> s",
        "rule_proposed" to "proposal created -> other side",
        "rule_accepted" to "proposal accepted -> proposer",
        "consequence_issued" to "D issues -> s",
        "consequence_done" to "s marks done -> D",
        "d_note_reminder" to "remind_at reached -> D",
    )

    @BeforeEach
    fun seed() {
        dsl.query("DELETE FROM notifications").execute()
        dsl.query("DELETE FROM outbox_records").execute()

        d = UUID.randomUUID(); s = UUID.randomUUID()
        dynamicId = UUID.randomUUID()
        taskId = UUID.randomUUID(); occurrenceId = UUID.randomUUID()
        ruleId = UUID.randomUUID(); redemptionId = UUID.randomUUID()
        consequenceId = UUID.randomUUID(); dNoteId = UUID.randomUUID()
        dayCommentId = UUID.randomUUID(); pointEntryId = UUID.randomUUID()

        dsl.query("INSERT INTO users (id,email,display_name,timezone) VALUES ({0},{1},'Dom','UTC')", d, "$d@t").execute()
        dsl.query("INSERT INTO users (id,email,display_name,timezone) VALUES ({0},{1},'Sub','UTC')", s, "$s@t").execute()
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','CLOSER','LIGHT','ACTIVE','UTC')""", dynamicId,
        ).execute()
        dsl.query(
            "INSERT INTO memberships (user_id,dynamic_id,role_context,side,access_state) VALUES ({0},{1},'CREATOR','D','ACTIVE')",
            d, dynamicId,
        ).execute()
        dsl.query(
            "INSERT INTO memberships (user_id,dynamic_id,role_context,side,access_state) VALUES ({0},{1},'PARTNER','S','ACTIVE')",
            s, dynamicId,
        ).execute()
        dsl.query(
            """INSERT INTO tasks (id,dynamic_id,title,kind,schedule,created_by)
               VALUES ({0},{1},'A task','recurring','{"type":"daily"}'::jsonb,{2})""",
            taskId, dynamicId, d,
        ).execute()
        dsl.query(
            """INSERT INTO occurrences (id,task_id,dynamic_id,day,outcome,outcome_at,disposition)
               VALUES ({0},{1},{2},CURRENT_DATE,'delivered',now(),'none')""",
            occurrenceId, taskId, dynamicId,
        ).execute()
        dsl.query(
            """INSERT INTO rules (id,dynamic_id,title,"group",created_by,status,position)
               VALUES ({0},{1},'A rule','other',{2},'proposed',1)""",
            ruleId, dynamicId, s,
        ).execute()
        dsl.query(
            "INSERT INTO rewards (id,dynamic_id,created_by_user_id,title,cost,active) VALUES ({0},{1},{2},'A reward',10,true)",
            UUID.randomUUID().also { rewardId = it }, dynamicId, d,
        ).execute()
        dsl.query(
            "INSERT INTO reward_redemptions (id,dynamic_id,reward_id,subject_user_id,status) VALUES ({0},{1},{2},{3},'requested')",
            redemptionId, dynamicId, rewardId, s,
        ).execute()
        dsl.query(
            "INSERT INTO consequences (id,dynamic_id,issued_by,title,status) VALUES ({0},{1},{2},'A consequence','issued')",
            consequenceId, dynamicId, d,
        ).execute()
        dsl.query(
            "INSERT INTO d_notes (id,dynamic_id,author_id,body,remind_at) VALUES ({0},{1},{2},'note',now())",
            dNoteId, dynamicId, d,
        ).execute()
        dsl.query(
            "INSERT INTO day_comments (id,dynamic_id,day,author_id,body) VALUES ({0},{1},CURRENT_DATE,{2},'a note')",
            dayCommentId, dynamicId, d,
        ).execute()
        dsl.query(
            "INSERT INTO point_entries (id,dynamic_id,subject_user_id,amount,reason,actor_user_id) VALUES ({0},{1},{2},5,'d_award',{3})",
            pointEntryId, dynamicId, s, d,
        ).execute()
    }

    private var rewardId: UUID = UUID.randomUUID()

    private fun enqueue(eventType: String, aggregateType: String, aggregateId: UUID) {
        dsl.query(
            """INSERT INTO outbox_records (aggregate_type,aggregate_id,event_type,payload,dedupe_key)
               VALUES ({0},{1},{2},'{}'::jsonb,{3})""",
            aggregateType, aggregateId, eventType, "cov-${UUID.randomUUID()}",
        ).execute()
    }

    private fun aggregateFor(eventType: String): Pair<String, UUID> = when (eventType) {
        "occurrence_delivered", "occurrence_flagged", "disposition_set" -> "occurrence" to occurrenceId
        "day_comment" -> "day_comment" to dayCommentId
        "d_award" -> "point_entry" to pointEntryId
        "redemption_requested", "redemption_decided", "redemption_fulfilled" -> "redemption" to redemptionId
        "rule_proposed", "rule_accepted" -> "rule" to ruleId
        "consequence_issued", "consequence_done" -> "consequence" to consequenceId
        "d_note_reminder" -> "d_note" to dNoteId
        else -> error("no fixture aggregate for $eventType")
    }

    @Test
    fun `every required event type resolves a recipient and has real copy`() {
        for ((eventType, description) in requiredEventTypes) {
            // Copy: must not silently fall back to the generic placeholder.
            val copy = EventCopy.forEventType(eventType)
            assertTrue(
                eventType in EventCopy.knownEventTypes,
                "$eventType ($description) has no entry in the closed copy set",
            )
            assertTrue(copy.title.isNotBlank() && copy.body.isNotBlank(), "$eventType copy must be non-blank")

            // Recipient: dispatch a synthetic record and assert a stored
            // notification actually landed for someone.
            val (aggregateType, aggregateId) = aggregateFor(eventType)
            enqueue(eventType, aggregateType, aggregateId)
        }

        dispatcher.dispatchOnce()

        for (eventType in requiredEventTypes.keys) {
            val row = dsl.fetchOne(
                "SELECT user_id FROM notifications WHERE dynamic_id = {0} AND event_type = {1}",
                dynamicId, eventType,
            )
            assertNotNull(row, "no notification landed for $eventType (${requiredEventTypes[eventType]})")
        }
    }

    @Test
    fun `redemption requested lands a stored notification for D`() {
        enqueue("redemption_requested", "redemption", redemptionId)
        dispatcher.dispatchOnce()

        val row = dsl.fetchOne(
            "SELECT user_id, event_type FROM notifications WHERE dynamic_id = {0} AND event_type = 'redemption_requested'",
            dynamicId,
        )
        assertNotNull(row)
        assertEquals(d, row.get("user_id", UUID::class.java))
    }

    @Test
    fun `D's disposition on an occurrence lands a stored notification for s`() {
        enqueue("disposition_set", "occurrence", occurrenceId)
        dispatcher.dispatchOnce()

        val row = dsl.fetchOne(
            "SELECT user_id, event_type FROM notifications WHERE dynamic_id = {0} AND event_type = 'disposition_set'",
            dynamicId,
        )
        assertNotNull(row)
        assertEquals(s, row.get("user_id", UUID::class.java))
    }
}
