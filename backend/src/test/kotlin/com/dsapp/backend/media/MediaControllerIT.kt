package com.dsapp.backend.media

import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.mock.web.MockMultipartFile
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.util.UUID

/**
 * Photo proof upload/download: content-sniffed image validation, size limit,
 * and download scoped strictly to active members of the owning dynamic.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class MediaControllerIT {

    @Autowired lateinit var mvc: MockMvc
    @Autowired lateinit var dsl: DSLContext

    private lateinit var member: UUID
    private lateinit var partner: UUID
    private lateinit var outsider: UUID
    private lateinit var dynamicId: UUID
    private lateinit var otherDynamicId: UUID

    // Minimal valid 1x1 PNG.
    private val pngBytes = byteArrayOf(
        0x89.toByte(), 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        0, 0, 0, 0x0D, 'I'.code.toByte(), 'H'.code.toByte(), 'D'.code.toByte(), 'R'.code.toByte(),
        0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 0x1F.toByte(), 0x15.toByte(), 0xC4.toByte(), 0x89.toByte(),
        0, 0, 0, 0x0A, 'I'.code.toByte(), 'D'.code.toByte(), 'A'.code.toByte(), 'T'.code.toByte(),
        0x78.toByte(), 0x9C.toByte(), 0x62, 0, 1, 0, 0, 5, 0, 1,
        0, 0, 0, 0, 'I'.code.toByte(), 'E'.code.toByte(), 'N'.code.toByte(), 'D'.code.toByte(),
    )

    @BeforeEach
    fun seed() {
        member = UUID.randomUUID(); partner = UUID.randomUUID(); outsider = UUID.randomUUID()
        dynamicId = UUID.randomUUID(); otherDynamicId = UUID.randomUUID()
        for (u in listOf(member, partner, outsider)) {
            dsl.query("INSERT INTO users (id,email,display_name) VALUES ({0},{1},'U')", u, "$u@t.local").execute()
        }
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','CLOSER','LIGHT','ACTIVE','UTC')""", dynamicId,
        ).execute()
        dsl.query(
            """INSERT INTO dynamics (id,mode,desired_outcome,structure_level,state,reference_timezone)
               VALUES ({0},'COUPLE','CLOSER','LIGHT','ACTIVE','UTC')""", otherDynamicId,
        ).execute()
        for ((u, r) in listOf(member to "CREATOR", partner to "PARTNER")) {
            dsl.query(
                "INSERT INTO memberships (user_id,dynamic_id,role_context,side,access_state) VALUES ({0},{1},{2},CASE WHEN {2}='CREATOR' THEN 'D' ELSE 'S' END,'ACTIVE')",
                u, dynamicId, r,
            ).execute()
        }
        dsl.query(
            "INSERT INTO memberships (user_id,dynamic_id,role_context,side,access_state) VALUES ({0},{1},'CREATOR','D','ACTIVE')",
            outsider, otherDynamicId,
        ).execute()
    }

    private fun asUser(id: UUID) = jwt().jwt { b: Jwt.Builder -> b.subject(id.toString()) }

    @Test
    fun `an active member uploads and gets an id and url`() {
        val file = MockMultipartFile("file", "photo.png", "image/png", pngBytes)
        mvc.perform(multipart("/v1/dynamics/$dynamicId/media").file(file).with(asUser(member)))
            .andExpect(status().isCreated)
            .andExpect(jsonPath("$.id").exists())
            .andExpect(jsonPath("$.url").value(org.hamcrest.Matchers.startsWith("/v1/media/")))
    }

    @Test
    fun `an active member downloads with correct bytes and content type`() {
        val file = MockMultipartFile("file", "photo.png", "image/png", pngBytes)
        val res = mvc.perform(multipart("/v1/dynamics/$dynamicId/media").file(file).with(asUser(member)))
            .andExpect(status().isCreated)
            .andReturn()
        val id = com.fasterxml.jackson.databind.ObjectMapper().readTree(res.response.contentAsString).get("id").asText()

        val dl = mvc.perform(get("/v1/media/$id").with(asUser(partner)))
            .andExpect(status().isOk)
            .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.header().string("Cache-Control", "private"))
            .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.content().contentType("image/png"))
            .andReturn()
        assert(dl.response.contentAsByteArray.contentEquals(pngBytes))
    }

    @Test
    fun `a non-member of the dynamic is refused with 403`() {
        val file = MockMultipartFile("file", "photo.png", "image/png", pngBytes)
        val res = mvc.perform(multipart("/v1/dynamics/$dynamicId/media").file(file).with(asUser(member)))
            .andExpect(status().isCreated)
            .andReturn()
        val id = com.fasterxml.jackson.databind.ObjectMapper().readTree(res.response.contentAsString).get("id").asText()

        mvc.perform(get("/v1/media/$id").with(asUser(outsider)))
            .andExpect(status().isForbidden)
    }

    @Test
    fun `a member of a different dynamic is refused with 403`() {
        val file = MockMultipartFile("file", "photo.png", "image/png", pngBytes)
        val res = mvc.perform(multipart("/v1/dynamics/$dynamicId/media").file(file).with(asUser(member)))
            .andExpect(status().isCreated)
            .andReturn()
        val id = com.fasterxml.jackson.databind.ObjectMapper().readTree(res.response.contentAsString).get("id").asText()

        mvc.perform(get("/v1/media/$id").with(asUser(outsider)))
            .andExpect(status().isForbidden)
    }

    @Test
    fun `an unknown media id is 404`() {
        mvc.perform(get("/v1/media/${UUID.randomUUID()}").with(asUser(member)))
            .andExpect(status().isNotFound)
    }

    @Test
    fun `a non-image upload is rejected`() {
        val file = MockMultipartFile("file", "notes.txt", "text/plain", "just text".toByteArray())
        mvc.perform(multipart("/v1/dynamics/$dynamicId/media").file(file).with(asUser(member)))
            .andExpect(status().isUnsupportedMediaType)
    }

    @Test
    fun `a file claiming to be a png but is not is rejected (content sniffed)`() {
        val file = MockMultipartFile("file", "fake.png", "image/png", "not really a png".toByteArray())
        mvc.perform(multipart("/v1/dynamics/$dynamicId/media").file(file).with(asUser(member)))
            .andExpect(status().isUnsupportedMediaType)
    }

    @Test
    fun `an oversized upload is rejected`() {
        // Bigger than the 10MB app-level limit but still under the 12MB
        // multipart ceiling, so it reaches MediaService's own check.
        val big = ByteArray(11 * 1024 * 1024)
        pngBytes.copyInto(big)
        val file = MockMultipartFile("file", "big.png", "image/png", big)
        mvc.perform(multipart("/v1/dynamics/$dynamicId/media").file(file).with(asUser(member)))
            .andExpect(status().isPayloadTooLarge)
    }
}
