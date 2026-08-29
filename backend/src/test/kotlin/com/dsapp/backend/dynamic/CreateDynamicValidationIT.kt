package com.dsapp.backend.dynamic

import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.test.context.ActiveProfiles
import java.util.UUID
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

/**
 * The values a Dynamic is created with decide behaviour, not just storage.
 *
 * `StarterRhythmService` parses `desired_outcome` back into an enum and falls
 * back to CLOSER when it cannot. The column has no CHECK constraint, so
 * before this the API accepted "banana" and lowercase "closer" with a 201 and
 * then handed the person the wrong starter rhythm — no error anywhere.
 *
 * Authenticated, because the security filter chain runs before validation —
 * an unauthenticated request answers 401 whatever the body says, which would
 * make every assertion here meaningless.
 *
 * Accepted values are asserted as "not 400": creating a Dynamic needs a real
 * user row, and this test is about the boundary, not the service.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class CreateDynamicValidationIT {

    @Autowired lateinit var mvc: MockMvc
    @Autowired lateinit var dsl: DSLContext

    private lateinit var actor: UUID

    @BeforeEach
    fun seed() {
        // A real row: the idempotency table has a foreign key to users, so a
        // JWT with an invented subject fails on insert rather than on
        // validation, which is not what these tests are about.
        actor = UUID.randomUUID()
        dsl.query(
            "INSERT INTO users (id,email,display_name) VALUES ({0},{1},'Alex')",
            actor, "$actor@t.local",
        ).execute()
    }

    private fun create(body: String) = mvc.perform(
        post("/v1/dynamics")
            .with(jwt().jwt { b: Jwt.Builder -> b.subject(actor.toString()) })
            .header("Idempotency-Key", "k-${System.nanoTime()}")
            .contentType(MediaType.APPLICATION_JSON)
            .content(body),
    )

    private fun payload(
        outcome: String = "CLOSER",
        structure: String = "LIGHT",
        role: String? = null,
    ) = buildString {
        append("""{"mode":"COUPLE","desiredOutcome":"$outcome",""")
        append(""""structureLevel":"$structure","referenceTimezone":"UTC"""")
        if (role != null) append(""","rolePreset":"$role"""")
        append("}")
    }

    @Test
    fun `an unknown desired outcome is refused, not silently defaulted`() {
        create(payload(outcome = "banana"))
            .andExpect(status().isBadRequest)
            .andExpect(jsonPath("$.detail").value("desiredOutcome"))
    }

    @Test
    fun `the wrong case is refused too`() {
        // `DesiredOutcome.valueOf` is case-sensitive, so this fell back to
        // CLOSER just as silently as a typo did.
        create(payload(outcome = "closer"))
            .andExpect(status().isBadRequest)
            .andExpect(jsonPath("$.detail").value("desiredOutcome"))
    }

    @Test
    fun `every outcome the product offers is accepted`() {
        // Goal options per REQ-ACT-001. If one of these is refused the
        // pattern and the domain enum have drifted apart.
        for (outcome in listOf("CLOSER", "STRUCTURE", "SERVICE", "ACCOUNTABILITY", "EXPLORE")) {
            create(payload(outcome = outcome)).andExpect(status().isCreated)
        }
    }

    @Test
    fun `an unknown structure level is refused`() {
        create(payload(structure = "banana"))
            .andExpect(status().isBadRequest)
            .andExpect(jsonPath("$.detail").value("structureLevel"))
    }

    @Test
    fun `the three structure levels are accepted`() {
        for (level in listOf("LIGHT", "STEADY", "DEFINED")) {
            create(payload(structure = level)).andExpect(status().isCreated)
        }
    }

    @Test
    fun `an unknown role preset is refused`() {
        create(payload(role = "MONARCH"))
            .andExpect(status().isBadRequest)
            .andExpect(jsonPath("$.detail").value("rolePreset"))
    }

    @Test
    fun `naming no role at all stays allowed`() {
        // Red line: the product must never require this to be answered.
        create(payload(role = null)).andExpect(status().isCreated)
    }
}
