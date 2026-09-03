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
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.util.UUID

/** GET /v1/dynamics/{id} exposes `mode` (SOLO vs COUPLE) alongside state. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class DynamicDetailModeIT {

    @Autowired lateinit var mvc: MockMvc
    @Autowired lateinit var dsl: DSLContext

    private lateinit var owner: UUID
    private lateinit var dynamicId: UUID

    @BeforeEach
    fun seed() {
        owner = UUID.randomUUID(); dynamicId = UUID.randomUUID()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Alex')", owner, "$owner@t.local").execute()
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'SOLO','CLOSER','LIGHT','ACTIVE','UTC')""", dynamicId,
        ).execute()
        dsl.query(
            "INSERT INTO memberships (user_id,dynamic_id,role_context,side,access_state) VALUES ({0},{1},'CREATOR','D','ACTIVE')",
            owner, dynamicId,
        ).execute()
    }

    private fun asUser(id: UUID) = jwt().jwt { b: Jwt.Builder -> b.subject(id.toString()) }

    @Test
    fun `detail of a solo dynamic has mode SOLO`() {
        mvc.perform(get("/v1/dynamics/$dynamicId").with(asUser(owner)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.mode").value("SOLO"))
    }
}
