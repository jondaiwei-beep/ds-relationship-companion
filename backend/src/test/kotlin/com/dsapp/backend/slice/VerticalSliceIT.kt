package com.dsapp.backend.slice

import com.fasterxml.jackson.databind.ObjectMapper
import org.jooq.DSLContext
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import java.util.UUID
import kotlin.test.assertEquals

/**
 * THE M1 VERTICAL SLICE, over real HTTP (Notion 06 §12):
 *
 *   creator -> create Dynamic -> generate Invite -> partner Joins ->
 *   one Expectation -> partner Completes -> creator human-Acknowledges ->
 *   partner sees the response
 *
 * This is the link that must work before any page expansion begins.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class VerticalSliceIT {

    @Autowired lateinit var mvc: MockMvc
    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var mapper: ObjectMapper

    private fun user(name: String): UUID {
        val id = UUID.randomUUID()
        dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},{2})",
            id, "$id@t.local", name).execute()
        return id
    }

    private fun asUser(id: UUID) = jwt().jwt { b: Jwt.Builder -> b.subject(id.toString()) }

    @Test
    fun `full human response loop over HTTP`() {
        val creator = user("Alex")
        val partner = user("Jamie")

        // 1. Creator builds a minimal Dynamic (Journey A2).
        val dyn = mvc.perform(
            post("/v1/dynamics").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"mode":"COUPLE","desiredOutcome":"CLOSER","structureLevel":"LIGHT","referenceTimezone":"America/New_York"}"""),
        ).andExpect(status().isCreated).andReturn().response.contentAsString
        val dynamicId = mapper.readTree(dyn)["dynamicId"].asText()

        // 2. Creator generates a web invite (Journey A4).
        val inv = mvc.perform(
            post("/v1/dynamics/$dynamicId/invites").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString()),
        ).andExpect(status().isCreated).andReturn().response.contentAsString
        val token = mapper.readTree(inv)["token"].asText()

        // 3. Partner resolves it ANONYMOUSLY in the browser before signing in.
        mvc.perform(
            post("/v1/invites/resolve").contentType(MediaType.APPLICATION_JSON)
                .content("""{"token":"$token"}"""),
        ).andExpect(status().isOk)
            .andExpect(jsonPath("$.state").value("PENDING"))
            .andExpect(jsonPath("$.inviterDisplayName").value("Alex"))

        // 4. Partner joins (Journey A5).
        mvc.perform(
            post("/v1/invites/join").with(asUser(partner))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"token":"$token"}"""),
        ).andExpect(status().isCreated)

        // 5. Creator sets ONE basic Expectation.
        val exp = mvc.perform(
            post("/v1/dynamics/$dynamicId/expectations").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"title":"Prepare the evening space","purpose":"A small act of care.","assigneeUserId":"$partner"}"""),
        ).andExpect(status().isCreated).andReturn().response.contentAsString
        val occurrenceId = mapper.readTree(exp)["occurrenceId"].asText()

        // 6. Partner sees it, and is offered adjustment alongside completion.
        mvc.perform(get("/v1/occurrences/$occurrenceId").with(asUser(partner)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.state").value("ACTIVE"))
            .andExpect(jsonPath("$.allowedActions").value(
                org.hamcrest.Matchers.hasItems("complete", "discuss", "reschedule", "cant_do"),
            ))

        // 7. Partner completes -> WAITING_ACK, and NOT acknowledged.
        mvc.perform(
            post("/v1/occurrences/$occurrenceId/complete").with(asUser(partner))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON).content("""{"note":"Done."}"""),
        ).andExpect(status().isCreated)

        mvc.perform(get("/v1/occurrences/$occurrenceId").with(asUser(partner)))
            .andExpect(jsonPath("$.state").value("WAITING_ACK"))
            .andExpect(jsonPath("$.acknowledgement").doesNotExist())

        // 8. Creator sends a HUMAN acknowledgement.
        mvc.perform(
            post("/v1/occurrences/$occurrenceId/acknowledgements").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"type":"PRAISE","text":"I noticed the care you put into this."}"""),
        ).andExpect(status().isCreated)

        // 9. Partner sees a response that is visibly from a real person.
        mvc.perform(get("/v1/occurrences/$occurrenceId").with(asUser(partner)))
            .andExpect(jsonPath("$.state").value("ACKNOWLEDGED"))
            .andExpect(jsonPath("$.acknowledgement.text").value("I noticed the care you put into this."))
            .andExpect(jsonPath("$.acknowledgement.senderDisplayName").value("Alex"))

        // First Connected Dynamic Day is now recordable from domain events alone.
        val types = dsl.fetch(
            "SELECT event_type FROM relationship_events WHERE dynamic_id = CAST({0} AS uuid) ORDER BY occurred_at",
            dynamicId,
        ).map { it.get("event_type", String::class.java) }
        assertEquals(
            listOf("dynamic_created", "invite_created", "member_joined",
                   "occurrence_activated", "completion_submitted", "acknowledgement_sent"),
            types,
        )
    }

    @Test
    fun `an acknowledgement with empty text is rejected`() {
        // Red line #1/#2: only an explicit human Send creates an Acknowledgement.
        val creator = user("Alex")
        val partner = user("Jamie")
        val dyn = mvc.perform(
            post("/v1/dynamics").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"mode":"COUPLE","desiredOutcome":"STRUCTURE","structureLevel":"LIGHT","referenceTimezone":"UTC"}"""),
        ).andReturn().response.contentAsString
        val dynamicId = mapper.readTree(dyn)["dynamicId"].asText()

        val inv = mvc.perform(
            post("/v1/dynamics/$dynamicId/invites").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString()),
        ).andExpect(status().isCreated).andReturn().response.contentAsString
        val token = mapper.readTree(inv)["token"].asText()

        mvc.perform(
            post("/v1/invites/join").with(asUser(partner))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON).content("""{"token":"$token"}"""),
        ).andExpect(status().isCreated)

        val exp = mvc.perform(
            post("/v1/dynamics/$dynamicId/expectations").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"title":"x","assigneeUserId":"$partner"}"""),
        ).andReturn().response.contentAsString
        val occurrenceId = mapper.readTree(exp)["occurrenceId"].asText()

        // The occurrence must actually reach WAITING_ACK first. Without this the
        // request is refused for the WRONG reason (state, not content) — which is
        // exactly how a missing @Valid survived: the assertion passed green while
        // the red line was completely unguarded.
        mvc.perform(
            post("/v1/occurrences/$occurrenceId/complete").with(asUser(partner))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON).content("""{"note":"Done."}"""),
        ).andExpect(status().isCreated)

        // Whitespace-only is not a human response.
        mvc.perform(
            post("/v1/occurrences/$occurrenceId/acknowledgements").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON).content("""{"type":"PRAISE","text":"  "}"""),
        ).andExpect(status().isBadRequest)

        // Neither is the empty string.
        mvc.perform(
            post("/v1/occurrences/$occurrenceId/acknowledgements").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON).content("""{"type":"PRAISE","text":""}"""),
        ).andExpect(status().isBadRequest)

        // Still waiting: no phantom acknowledgement landed.
        mvc.perform(get("/v1/occurrences/$occurrenceId").with(asUser(partner)))
            .andExpect(jsonPath("$.state").value("WAITING_ACK"))
            .andExpect(jsonPath("$.acknowledgement").doesNotExist())
    }

    @Test
    fun `a non-member gets 404, never a hint that the occurrence exists`() {
        val creator = user("Alex")
        val stranger = user("Stranger")
        val dyn = mvc.perform(
            post("/v1/dynamics").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"mode":"SOLO","desiredOutcome":"CLOSER","structureLevel":"LIGHT","referenceTimezone":"UTC"}"""),
        ).andReturn().response.contentAsString
        val dynamicId = mapper.readTree(dyn)["dynamicId"].asText()
        val exp = mvc.perform(
            post("/v1/dynamics/$dynamicId/expectations").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"title":"private thing","assigneeUserId":"$creator"}"""),
        ).andReturn().response.contentAsString
        val occurrenceId = mapper.readTree(exp)["occurrenceId"].asText()

        mvc.perform(get("/v1/occurrences/$occurrenceId").with(asUser(stranger)))
            .andExpect(status().isNotFound)
    }

    @Test
    fun `retrying complete with the same idempotency key does not double-complete`() {
        val creator = user("Alex")
        val partner = user("Jamie")
        val dyn = mvc.perform(
            post("/v1/dynamics").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"mode":"COUPLE","desiredOutcome":"CLOSER","structureLevel":"LIGHT","referenceTimezone":"UTC"}"""),
        ).andReturn().response.contentAsString
        val dynamicId = mapper.readTree(dyn)["dynamicId"].asText()
        val inv = mvc.perform(
            post("/v1/dynamics/$dynamicId/invites").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString()),
        ).andReturn().response.contentAsString
        val token = mapper.readTree(inv)["token"].asText()
        mvc.perform(
            post("/v1/invites/join").with(asUser(partner))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON).content("""{"token":"$token"}"""),
        ).andExpect(status().isCreated)
        val exp = mvc.perform(
            post("/v1/dynamics/$dynamicId/expectations").with(asUser(creator))
                .header("Idempotency-Key", UUID.randomUUID().toString())
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"title":"t","assigneeUserId":"$partner"}"""),
        ).andReturn().response.contentAsString
        val occurrenceId = mapper.readTree(exp)["occurrenceId"].asText()

        // Same key twice — a flaky network retry, not a second action.
        val key = UUID.randomUUID().toString()
        repeat(2) {
            mvc.perform(
                post("/v1/occurrences/$occurrenceId/complete").with(asUser(partner))
                    .header("Idempotency-Key", key)
                    .contentType(MediaType.APPLICATION_JSON).content("""{"note":"Done."}"""),
            ).andExpect(status().isCreated)
        }

        val n = dsl.fetchOne(
            "SELECT count(*) FROM occurrence_completions WHERE occurrence_id = CAST({0} AS uuid)",
            occurrenceId,
        )!!.get(0, Int::class.java)
        assertEquals(1, n, "a retry must not create a second completion")
    }
}
