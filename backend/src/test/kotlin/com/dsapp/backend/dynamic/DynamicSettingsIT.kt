package com.dsapp.backend.dynamic

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
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

/**
 * PUT /v1/dynamics/{id}/settings: partial update from either side,
 * validation on timezone / dayBoundaryMinutes, reflected in GET detail, and
 * a relationship event on success.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class DynamicSettingsIT {

    @Autowired lateinit var mvc: MockMvc
    @Autowired lateinit var dsl: DSLContext

    private lateinit var d: UUID
    private lateinit var s: UUID
    private lateinit var dynamicId: UUID

    @BeforeEach
    fun seed() {
        d = UUID.randomUUID(); s = UUID.randomUUID()
        dynamicId = UUID.randomUUID()
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
    }

    private fun asUser(id: UUID) = jwt().jwt { b: Jwt.Builder -> b.subject(id.toString()) }

    @Test
    fun `D can partially update settings and it is reflected in GET detail`() {
        mvc.perform(
            put("/v1/dynamics/$dynamicId/settings").with(asUser(d))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"honorificForD":"Sir","safeword":"banana"}"""),
        ).andExpect(status().isOk)
            .andExpect(jsonPath("$.honorificForD").value("Sir"))
            .andExpect(jsonPath("$.safeword").value("banana"))
            // Untouched fields keep their existing value.
            .andExpect(jsonPath("$.referenceTimezone").value("UTC"))

        mvc.perform(get("/v1/dynamics/$dynamicId").with(asUser(d)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.honorificForD").value("Sir"))
            .andExpect(jsonPath("$.safeword").value("banana"))
    }

    @Test
    fun `s can also update settings, unlike most mutating endpoints`() {
        mvc.perform(
            put("/v1/dynamics/$dynamicId/settings").with(asUser(s))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"honorificForS":"pet","timezone":"America/New_York","dayBoundaryMinutes":300}"""),
        ).andExpect(status().isOk)
            .andExpect(jsonPath("$.honorificForS").value("pet"))
            .andExpect(jsonPath("$.referenceTimezone").value("America/New_York"))
            .andExpect(jsonPath("$.dayBoundaryMinutes").value(300))
    }

    @Test
    fun `an invalid timezone is rejected with 400`() {
        mvc.perform(
            put("/v1/dynamics/$dynamicId/settings").with(asUser(d))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"timezone":"Not/AZone"}"""),
        ).andExpect(status().isBadRequest)
    }

    @Test
    fun `dayBoundaryMinutes out of range is rejected with 400`() {
        mvc.perform(
            put("/v1/dynamics/$dynamicId/settings").with(asUser(d))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"dayBoundaryMinutes":1440}"""),
        ).andExpect(status().isBadRequest)

        mvc.perform(
            put("/v1/dynamics/$dynamicId/settings").with(asUser(d))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"dayBoundaryMinutes":-1}"""),
        ).andExpect(status().isBadRequest)
    }

    @Test
    fun `a successful change writes a relationship event`() {
        mvc.perform(
            put("/v1/dynamics/$dynamicId/settings").with(asUser(d))
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"safeword":"red"}"""),
        ).andExpect(status().isOk)

        val row = dsl.fetchOne(
            "SELECT actor_user_id, event_type FROM relationship_events WHERE dynamic_id = {0} AND event_type = 'dynamic_settings_changed'",
            dynamicId,
        )
        assertNotNull(row, "expected a dynamic_settings_changed relationship event")
        assertEquals(d, row.get("actor_user_id", UUID::class.java))
    }
}
