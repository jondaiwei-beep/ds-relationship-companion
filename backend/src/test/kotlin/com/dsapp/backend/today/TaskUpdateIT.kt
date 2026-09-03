package com.dsapp.backend.today

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
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

/**
 * PATCH /v1/dynamics/{id}/tasks/{taskId}: partial edit, D only, blocked on
 * archived tasks, and a schedule change regenerates only today's still-open
 * occurrences (decided ones are left untouched).
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class TaskUpdateIT {

    @Autowired lateinit var mvc: MockMvc
    @Autowired lateinit var dsl: DSLContext

    private lateinit var d: UUID
    private lateinit var s: UUID
    private lateinit var dynamicId: UUID
    private lateinit var taskId: UUID

    @BeforeEach
    fun seed() {
        d = UUID.randomUUID(); s = UUID.randomUUID(); dynamicId = UUID.randomUUID()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Dom')", d, "$d@t.local").execute()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Sub')", s, "$s@t.local").execute()
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
        taskId = UUID.randomUUID()
        dsl.query(
            """INSERT INTO tasks (id,dynamic_id,title,kind,schedule,times_per_day,points_earn,created_by,status,position)
               VALUES ({0},{1},'Original title','recurring','{"type":"daily"}'::jsonb,1,5,{2},'active',1)""",
            taskId, dynamicId, d,
        ).execute()
    }

    private fun asUser(id: UUID) = jwt().jwt { b: Jwt.Builder -> b.subject(id.toString()) }

    @Test
    fun `D edits title and points, returned and persisted`() {
        mvc.perform(
            patch("/v1/dynamics/$dynamicId/tasks/$taskId").with(asUser(d))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"title":"New title","pointsEarn":42}"""),
        ).andExpect(status().isOk)
            .andExpect(jsonPath("$.title").value("New title"))
            .andExpect(jsonPath("$.pointsEarn").value(42))

        mvc.perform(get("/v1/dynamics/$dynamicId/tasks").with(asUser(d)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$[0].title").value("New title"))
            .andExpect(jsonPath("$[0].pointsEarn").value(42))

        val row = dsl.fetchOne("SELECT title, points_earn FROM tasks WHERE id = {0}", taskId)!!
        assertEquals("New title", row.get("title", String::class.java))
        assertEquals(42, row.get("points_earn", Int::class.java))
    }

    @Test
    fun `s editing a task gets WrongSide`() {
        mvc.perform(
            patch("/v1/dynamics/$dynamicId/tasks/$taskId").with(asUser(s))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"title":"Nope"}"""),
        ).andExpect(status().isNotFound) // AuthorizationException.WrongSide -> 404, never leaks structure
    }

    @Test
    fun `archived task cannot be edited`() {
        dsl.query("UPDATE tasks SET status = 'archived' WHERE id = {0}", taskId).execute()

        mvc.perform(
            patch("/v1/dynamics/$dynamicId/tasks/$taskId").with(asUser(d))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"title":"Nope"}"""),
        ).andExpect(status().isConflict)
            .andExpect(jsonPath("$.code").value("TASK_ARCHIVED"))
    }

    @Test
    fun `schedule change regenerates only today's open occurrences`() {
        // Seed today: one still-open occurrence and one already-decided one.
        val openOcc = UUID.randomUUID()
        val decidedOcc = UUID.randomUUID()
        dsl.query(
            """INSERT INTO occurrences (id,task_id,dynamic_id,day,slot,outcome,disposition)
               VALUES ({0},{1},{2},CURRENT_DATE,0,'open','none')""",
            openOcc, taskId, dynamicId,
        ).execute()
        dsl.query(
            """INSERT INTO occurrences (id,task_id,dynamic_id,day,slot,outcome,outcome_at,disposition)
               VALUES ({0},{1},{2},CURRENT_DATE,1,'delivered',now(),'none')""",
            decidedOcc, taskId, dynamicId,
        ).execute()
        dsl.query("UPDATE tasks SET times_per_day = 2 WHERE id = {0}", taskId).execute()

        mvc.perform(
            patch("/v1/dynamics/$dynamicId/tasks/$taskId").with(asUser(d))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"schedule":{"type":"daily"}}"""),
        ).andExpect(status().isOk)

        // The already-decided occurrence must survive untouched.
        val decidedRow = dsl.fetchOne("SELECT outcome FROM occurrences WHERE id = {0}", decidedOcc)
        assertNotNull(decidedRow, "decided occurrence must not be deleted by a schedule change")
        assertEquals("delivered", decidedRow.get("outcome", String::class.java))

        // The old open occurrence row is gone (regenerated), but today still
        // has open occurrence(s) for this task.
        val stillOpenCount = dsl.fetchOne(
            "SELECT count(*) AS n FROM occurrences WHERE task_id = {0} AND day = CURRENT_DATE AND outcome = 'open'",
            taskId,
        )!!.get("n", Int::class.java)
        assert(stillOpenCount >= 1) { "expected regenerated open occurrence(s) for today" }
    }
}
