package com.dsapp.backend.shared

import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.web.client.TestRestTemplate
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.RequestEntity
import org.springframework.http.ResponseEntity
import org.springframework.test.context.ActiveProfiles
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * A request that fails its own validation must answer 400, never 401.
 *
 * Spring FORWARDs a failed request to `/error` to render the body. If that
 * forward is itself subject to `anyRequest().authenticated()`, the security
 * entry point replaces the 400 with `401 UNAUTHORIZED` — and every client in
 * this product reads 401 as "the session ended", clears it, and shows the
 * authorization-loss surface. A mistyped email would sign someone out.
 *
 * Found by running the real server rather than the service directly: unit
 * tests that call `AuthService` bypass controller validation entirely.
 *
 * Runs on a real port, because the bug was about what a real container does
 * with a failed request. Removing `ApiErrorHandler.onInvalidBody` makes every
 * test here fail, which is the check that matters: without a handler, Spring
 * forwards to /error, the security chain re-authorizes that forward, and the
 * 400 comes back as 401.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class RequestValidationIT {

    @Autowired lateinit var rest: TestRestTemplate

    private fun register(body: String): ResponseEntity<String> = rest.exchange(
        RequestEntity.post("/v1/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .body(body),
        String::class.java,
    )

    @Test
    fun `a malformed email is a bad request, not a lost session`() {
        val response =
            register("""{"email":"not-an-email","password":"a quiet evening","ageConfirmed":true}""")

        assertEquals(HttpStatus.BAD_REQUEST, response.statusCode)
        assertTrue(response.body!!.contains("INVALID_REQUEST"), response.body!!)
        assertTrue(response.body!!.contains("email"), response.body!!)
    }

    @Test
    fun `the offending field is named so the form can point at it`() {
        val response =
            register("""{"email":"ok@test.local","password":"","ageConfirmed":true}""")

        assertEquals(HttpStatus.BAD_REQUEST, response.statusCode)
        assertTrue(response.body!!.contains("password"), response.body!!)
    }

    @Test
    fun `an unparseable body is also a bad request`() {
        val response = register("""{"email":}""")

        assertEquals(HttpStatus.BAD_REQUEST, response.statusCode)
        assertTrue(response.body!!.contains("INVALID_REQUEST"), response.body!!)
    }

    @Test
    fun `a missing required field is a bad request`() {
        val response = register("""{}""")

        assertEquals(HttpStatus.BAD_REQUEST, response.statusCode)
        assertTrue(response.body!!.contains("INVALID_REQUEST"), response.body!!)
    }

    @Test
    fun `a genuinely unauthenticated request still answers 401`() {
        // The fix must not turn the security boundary off.
        val response = rest.getForEntity("/v1/dynamics", String::class.java)

        assertEquals(HttpStatus.UNAUTHORIZED, response.statusCode)
        assertTrue(response.body!!.contains("UNAUTHORIZED"), response.body!!)
    }
}
