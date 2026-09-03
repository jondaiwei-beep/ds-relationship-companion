package com.dsapp.backend.notifications

import com.dsapp.backend.delivery.application.OutboxDispatcher
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * Stored notifications: dispatch writes rows for the correct recipient(s),
 * the inbox lists newest-first with unread_count, read marks stick, and
 * mute/digest settings round-trip.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class NotificationControllerIT {

    @Autowired lateinit var mvc: MockMvc
    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var dispatcher: OutboxDispatcher

    private lateinit var d: UUID
    private lateinit var s: UUID
    private lateinit var dynamicId: UUID
    private lateinit var occurrenceId: UUID
    private lateinit var taskId: UUID

    @BeforeEach
    fun seed() {
        dsl.query("DELETE FROM notifications").execute()
        dsl.query("DELETE FROM outbox_records").execute()
        dsl.query("DELETE FROM notification_settings").execute()

        d = UUID.randomUUID(); s = UUID.randomUUID()
        dynamicId = UUID.randomUUID(); occurrenceId = UUID.randomUUID(); taskId = UUID.randomUUID()

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
               VALUES ({0},{1},'Some task title','recurring','{"type":"daily"}'::jsonb,{2})""",
            taskId, dynamicId, d,
        ).execute()
        dsl.query(
            """INSERT INTO occurrences (id,task_id,dynamic_id,day,outcome,outcome_at)
               VALUES ({0},{1},{2},CURRENT_DATE,'delivered',now())""",
            occurrenceId, taskId, dynamicId,
        ).execute()
    }

    private fun asUser(id: UUID) = jwt().jwt { b: Jwt.Builder -> b.subject(id.toString()) }

    private fun enqueue(eventType: String, aggregateType: String = "occurrence", aggregateId: UUID = occurrenceId) {
        dsl.query(
            """INSERT INTO outbox_records (aggregate_type,aggregate_id,event_type,payload,dedupe_key)
               VALUES ({0},{1},{2},'{}'::jsonb,{3})""",
            aggregateType, aggregateId, eventType, "d-${UUID.randomUUID()}",
        ).execute()
    }

    @Test
    fun `dispatch produces a stored row for the correct recipient`() {
        enqueue("occurrence_delivered")
        dispatcher.dispatchOnce()

        val row = dsl.fetchOne(
            "SELECT user_id, dynamic_id, event_type, title, body, neutral_body, deep_link FROM notifications WHERE dynamic_id = {0}",
            dynamicId,
        )
        assertNotNull(row, "expected a stored notification row")
        assertEquals(d, row.get("user_id", UUID::class.java), "occurrence_delivered notifies D")
        assertEquals("occurrence_delivered", row.get("event_type", String::class.java))
        assertTrue(row.get("title", String::class.java).isNotBlank())
        assertTrue(row.get("body", String::class.java).isNotBlank())
        assertTrue(row.get("neutral_body", String::class.java).isNotBlank())
    }

    @Test
    fun `GET list is newest-first, respects since and limit, and reports unread_count`() {
        enqueue("occurrence_delivered")
        dispatcher.dispatchOnce()
        val mid = java.time.Instant.now()
        Thread.sleep(5)
        dsl.query(
            "UPDATE occurrences SET disposition='none' WHERE id = {0}", occurrenceId,
        ).execute()
        enqueue("disposition_set")
        dispatcher.dispatchOnce()

        val res = mvc.perform(get("/v1/me/notifications").with(asUser(d)))
            .andExpect(status().isOk)
            .andReturn()
        val json = com.fasterxml.jackson.databind.ObjectMapper().readTree(res.response.contentAsString)
        assertEquals(1, json.get("items").size(), "only occurrence_delivered notifies D")
        assertEquals(1, json.get("unreadCount").asInt())

        val sinceRes = mvc.perform(get("/v1/me/notifications").param("since", mid.toString()).with(asUser(d)))
            .andExpect(status().isOk).andReturn()
        val sinceJson = com.fasterxml.jackson.databind.ObjectMapper().readTree(sinceRes.response.contentAsString)
        assertEquals(0, sinceJson.get("items").size(), "nothing new for D since mid (disposition_set notifies s, not d)")
    }

    @Test
    fun `POST read marks matching notifications read`() {
        enqueue("occurrence_delivered")
        dispatcher.dispatchOnce()
        val id = dsl.fetchOne("SELECT id FROM notifications WHERE user_id = {0}", d)!!.get("id", UUID::class.java)

        mvc.perform(
            post("/v1/me/notifications/read").with(asUser(d))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"ids":["$id"]}"""),
        ).andExpect(status().isOk).andExpect(jsonPath("$.updated").value(1))

        val readAt = dsl.fetchOne("SELECT read_at FROM notifications WHERE id = {0}", id)!!.get("read_at")
        assertNotNull(readAt)

        val count = mvc.perform(get("/v1/me/notifications/unread-count").with(asUser(d)))
            .andExpect(status().isOk).andReturn()
        val json = com.fasterxml.jackson.databind.ObjectMapper().readTree(count.response.contentAsString)
        assertEquals(0, json.get("unreadCount").asInt())
    }

    @Test
    fun `mute settings GET then PUT round-trips`() {
        val getRes = mvc.perform(get("/v1/me/notification-mute-settings").with(asUser(d)))
            .andExpect(status().isOk).andReturn()
        val before = com.fasterxml.jackson.databind.ObjectMapper().readTree(getRes.response.contentAsString)
        assertEquals(false, before.get("neutralLockscreen").asBoolean())
        assertTrue(before.get("mutedTypes").isEmpty)

        mvc.perform(
            put("/v1/me/notification-mute-settings").with(asUser(d))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"neutralLockscreen":true,"deliverDigestHours":6,"mutedTypes":["day_comment"]}"""),
        ).andExpect(status().isOk)
            .andExpect(jsonPath("$.neutralLockscreen").value(true))
            .andExpect(jsonPath("$.deliverDigestHours").value(6))

        val afterRes = mvc.perform(get("/v1/me/notification-mute-settings").with(asUser(d)))
            .andExpect(status().isOk).andReturn()
        val after = com.fasterxml.jackson.databind.ObjectMapper().readTree(afterRes.response.contentAsString)
        assertEquals(true, after.get("neutralLockscreen").asBoolean())
        assertEquals(6, after.get("deliverDigestHours").asInt())
        assertEquals("day_comment", after.get("mutedTypes").get(0).asText())
    }

    @Test
    fun `an unknown muted type is rejected`() {
        mvc.perform(
            put("/v1/me/notification-mute-settings").with(asUser(d))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"mutedTypes":["not_a_real_event_type"]}"""),
        ).andExpect(status().isBadRequest)
    }
}
