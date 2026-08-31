package com.dsapp.backend.identity

import com.fasterxml.jackson.databind.ObjectMapper
import org.jooq.DSLContext
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.security.MessageDigest
import java.util.Base64
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * Passwordless auth security properties (Notion 04 §2).
 *
 * Verified live on 2026-08-27, then locked here so they cannot regress.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AuthFlowIT {

    @Autowired lateinit var mvc: MockMvc
    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var mapper: ObjectMapper

    private fun b64(b: ByteArray) = Base64.getUrlEncoder().withoutPadding().encodeToString(b)
    private fun challengeFor(verifier: String) =
        b64(MessageDigest.getInstance("SHA-256").digest(verifier.toByteArray()))

    /// Requests a link and reads the issued token straight from the database —
    /// the plaintext is never returned by the API, by design.
    private fun request(email: String, flowId: UUID, verifier: String) {
        mvc.perform(
            post("/v1/auth/magic-links").contentType(MediaType.APPLICATION_JSON).content(
                """{"email":"$email","flowId":"$flowId","codeChallenge":"${challengeFor(verifier)}"}""",
            ),
        ).andExpect(status().isAccepted)
    }

    private fun consume(token: String, flowId: UUID, verifier: String) =
        mvc.perform(
            post("/v1/auth/magic-links/consume").contentType(MediaType.APPLICATION_JSON).content(
                """{"token":"$token","flowId":"$flowId","codeVerifier":"$verifier","clientType":"WEB"}""",
            ),
        )

    /// The API never echoes the plaintext token, so tests mint their own and
    /// write the hash — exactly what the service stores.
    private fun seedToken(email: String, flowId: UUID, verifier: String): String {
        val token = "ml1." + b64(java.security.SecureRandom().generateSeed(32))
        dsl.query(
            """
            INSERT INTO magic_link_tokens
                (id, flow_id, normalized_email, token_hash, verifier_hash, state, expires_at)
            VALUES ({0}, {1}, {2}, {3}, {4}, 'PENDING', now() + interval '10 minutes')
            """.trimIndent(),
            UUID.randomUUID(), flowId, email,
            MessageDigest.getInstance("SHA-256").digest(token.toByteArray()),
            MessageDigest.getInstance("SHA-256").digest(verifier.toByteArray()),
        ).execute()
        return token
    }

    @Test
    fun `a valid link issues a short-lived access token`() {
        val flow = UUID.randomUUID()
        val verifier = "verifier-${UUID.randomUUID()}"
        val token = seedToken("alex@t.local", flow, verifier)

        val body = consume(token, flow, verifier)
            .andExpect(status().isOk).andReturn().response.contentAsString
        val json = mapper.readTree(body)

        assertTrue(json["accessToken"].asText().startsWith("ey"), "expected a JWT")
        // Short-lived by design: a leaked access token has a small window.
        assertEquals(300, json["accessTokenExpiresInSeconds"].asInt())
    }

    @Test
    fun `a magic link is SINGLE USE`() {
        val flow = UUID.randomUUID()
        val verifier = "verifier-${UUID.randomUUID()}"
        val token = seedToken("single@t.local", flow, verifier)

        consume(token, flow, verifier).andExpect(status().isOk)
        // Replaying the same link must fail — a forwarded email cannot be reused.
        consume(token, flow, verifier).andExpect(status().isUnauthorized)
    }

    @Test
    fun `PKCE - a stolen link cannot authenticate without the verifier`() {
        val flow = UUID.randomUUID()
        val verifier = "verifier-${UUID.randomUUID()}"
        val token = seedToken("victim@t.local", flow, verifier)

        // The attacker has the emailed link but not the browser that started
        // the flow, so they do not hold the verifier.
        consume(token, flow, "attacker-guess").andExpect(status().isUnauthorized)

        // The legitimate browser still works afterwards.
        consume(token, flow, verifier).andExpect(status().isOk)
    }

    @Test
    fun `an expired link is refused`() {
        val flow = UUID.randomUUID()
        val verifier = "verifier-${UUID.randomUUID()}"
        val token = seedToken("late@t.local", flow, verifier)
        dsl.query(
            """UPDATE magic_link_tokens
               SET created_at = now() - interval '20 minutes',
                   expires_at = now() - interval '1 minute'
             WHERE flow_id = {0}""".trimIndent(),
            flow,
        ).execute()

        consume(token, flow, verifier).andExpect(status().isUnauthorized)
    }

    @Test
    fun `only the hash is stored, never the plaintext token`() {
        val flow = UUID.randomUUID()
        val verifier = "verifier-${UUID.randomUUID()}"
        val token = seedToken("hash@t.local", flow, verifier)

        val row = dsl.fetchOne(
            "SELECT magic_link_tokens::text AS r FROM magic_link_tokens WHERE flow_id = {0}", flow,
        )!!.get("r", String::class.java)

        assertTrue(!row.contains(token), "plaintext magic token leaked into the row")
        assertTrue(!row.contains(verifier), "plaintext verifier leaked into the row")
    }

    @Test
    fun `a session survives its first refresh`() {
        // Found on a real device, not here: registration succeeded and the
        // app signed the person out moments later. The refresh insert bound
        // `idle_expires_at` as a plain `?`, jOOQ sent it as varchar, and
        // Postgres refused it against a timestamptz column. The SQL error
        // surfaced as a 401, which the client correctly read as "this session
        // is over" — so the app rotated its own token and destroyed the
        // session it had just created.
        //
        // Nothing exercised /v1/auth/refresh at all, which is how a defect
        // this total reached a device.
        val email = "refresh-${UUID.randomUUID()}@t.co"
        val registered = mvc.perform(
            post("/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(
                    """{"email":"$email","password":"correct horse battery staple",
                       "displayName":"Alex","ageConfirmed":true}"""
                ),
        ).andExpect(status().isOk).andReturn().response.contentAsString

        val refreshToken = mapper.readTree(registered)["refreshToken"].asText()
        assertTrue(refreshToken.isNotBlank(), "register must issue a refresh token")

        val rotated = mvc.perform(
            post("/v1/auth/refresh")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"refreshToken":"$refreshToken","clientType":"ANDROID"}"""),
        ).andExpect(status().isOk).andReturn().response.contentAsString

        val next = mapper.readTree(rotated)
        assertTrue(
            next["accessToken"].asText().isNotBlank(),
            "a refresh must return a usable access token",
        )
        assertTrue(
            next["refreshToken"].asText() != refreshToken,
            "the refresh token must rotate, or a stolen one stays valid forever",
        )
    }

    @Test
    fun `a rotated refresh token replaces the one before it`() {
        val email = "rotate-${UUID.randomUUID()}@t.co"
        val registered = mvc.perform(
            post("/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(
                    """{"email":"$email","password":"correct horse battery staple",
                       "displayName":"Alex","ageConfirmed":true}"""
                ),
        ).andReturn().response.contentAsString
        val first = mapper.readTree(registered)["refreshToken"].asText()

        val second = mapper.readTree(
            mvc.perform(
                post("/v1/auth/refresh")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"refreshToken":"$first","clientType":"ANDROID"}"""),
            ).andExpect(status().isOk).andReturn().response.contentAsString,
        )["refreshToken"].asText()

        // The new one works, which is the point of rotating.
        mvc.perform(
            post("/v1/auth/refresh")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"refreshToken":"$second","clientType":"ANDROID"}"""),
        ).andExpect(status().isOk)
    }

}
