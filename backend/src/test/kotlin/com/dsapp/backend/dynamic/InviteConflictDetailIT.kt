package com.dsapp.backend.dynamic

import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.util.UUID

/**
 * POST /v1/dynamics/{id}/invites: creating a second invite while one is
 * still pending must answer 409 INVITE_ALREADY_PENDING with the pending
 * invite's id in `detail`, so the client can revoke it and recreate without
 * a separate lookup round-trip.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class InviteConflictDetailIT {

    @Autowired lateinit var mvc: MockMvc
    @Autowired lateinit var dsl: DSLContext

    private lateinit var creator: UUID
    private lateinit var dynamicId: UUID

    @BeforeEach
    fun seed() {
        creator = UUID.randomUUID(); dynamicId = UUID.randomUUID()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Alex')", creator, "$creator@t.local").execute()
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','CLOSER','LIGHT','ACTIVE','UTC')""", dynamicId,
        ).execute()
        dsl.query(
            "INSERT INTO memberships (user_id,dynamic_id,role_context,side,access_state) VALUES ({0},{1},'CREATOR','D','ACTIVE')",
            creator, dynamicId,
        ).execute()
    }

    private fun asUser(id: UUID) = jwt().jwt { b: Jwt.Builder -> b.subject(id.toString()) }

    @Test
    fun `a second invite while one is pending returns 409 with the first invite's id in detail`() {
        val first = mvc.perform(
            post("/v1/dynamics/$dynamicId/invites").with(asUser(creator))
                .header("Idempotency-Key", "iv-1"),
        ).andExpect(status().isCreated).andReturn()
        val firstId = com.fasterxml.jackson.databind.ObjectMapper()
            .readTree(first.response.contentAsString).get("inviteId").asText()

        mvc.perform(
            post("/v1/dynamics/$dynamicId/invites").with(asUser(creator))
                .header("Idempotency-Key", "iv-2"),
        )
            .andExpect(status().isConflict)
            .andExpect(jsonPath("$.code").value("INVITE_ALREADY_PENDING"))
            .andExpect(jsonPath("$.detail").value(firstId))
    }
}
