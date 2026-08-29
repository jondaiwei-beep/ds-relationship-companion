package com.dsapp.backend.identity

import com.dsapp.backend.identity.application.AuthService
import com.dsapp.backend.identity.domain.ApiException
import com.dsapp.backend.identity.domain.ClientType
import org.jooq.DSLContext
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * Email + password sign-up.
 *
 * A magic link cannot be the only door: on a phone it means leaving the app,
 * finding a mail client and coming back, and the first wall is where most
 * people stop.
 */
@SpringBootTest
@ActiveProfiles("test")
class PasswordAuthIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var auth: AuthService

    private fun email() = "pw-${System.nanoTime()}@test.local"

    @Test
    fun `a person can register and immediately have a session`() {
        val grant = auth.register(
            email = email(),
            password = "a quiet evening",
            clientType = ClientType.ANDROID,
            ageConfirmed = true,
        )
        assertNotNull(grant.refreshToken)
        assertNotNull(grant.userId)
    }

    @Test
    fun `registering confirms the age gate rather than inferring it`() {
        val e = email()
        val grant = auth.register(
            email = e, password = "a quiet evening",
            clientType = ClientType.ANDROID, ageConfirmed = true,
        )
        // Notion 03 §2 — a User property that is stated, never assumed.
        val at = dsl.fetchOne(
            "select age_gate_confirmed_at from users where id = {0}", grant.userId,
        )!!.get(0)
        assertNotNull(at)
    }

    @Test
    fun `an unconfirmed age gate is refused`() {
        assertFailsWith<ApiException> {
            auth.register(
                email = email(), password = "a quiet evening",
                clientType = ClientType.ANDROID, ageConfirmed = false,
            )
        }
    }

    @Test
    fun `the password is never stored in the clear`() {
        val secret = "a quiet evening together"
        val grant = auth.register(
            email = email(), password = secret,
            clientType = ClientType.ANDROID, ageConfirmed = true,
        )
        val hash = dsl.fetchOne(
            "select password_hash from users where id = {0}", grant.userId,
        )!!.get("password_hash", String::class.java)

        assertTrue(hash.startsWith("\$2"), "expected a bcrypt hash, got: $hash")
        assertTrue(!hash.contains(secret))
    }

    @Test
    fun `signing in works and a wrong password does not`() {
        val e = email()
        auth.register(
            email = e, password = "a quiet evening",
            clientType = ClientType.ANDROID, ageConfirmed = true,
        )
        assertNotNull(
            auth.signIn(e, "a quiet evening", ClientType.ANDROID).refreshToken,
        )
        assertFailsWith<ApiException> {
            auth.signIn(e, "a quiet evenings", ClientType.ANDROID)
        }
    }

    @Test
    fun `email is not case sensitive`() {
        val e = "Mixed-${System.nanoTime()}@Test.Local"
        auth.register(
            email = e, password = "a quiet evening",
            clientType = ClientType.ANDROID, ageConfirmed = true,
        )
        // Someone typing their own address with different capitalisation is
        // not a different person.
        assertNotNull(
            auth.signIn(e.lowercase(), "a quiet evening", ClientType.ANDROID),
        )
    }

    @Test
    fun `the same error hides whether an address is registered`() {
        val known = email()
        auth.register(
            email = known, password = "a quiet evening",
            clientType = ClientType.ANDROID, ageConfirmed = true,
        )

        // For an intimate product, distinguishing "no such account" from
        // "wrong password" turns sign-in into an oracle: anyone holding the
        // phone could test whether a given address has an account here.
        val unknown = assertFailsWith<ApiException> {
            auth.signIn("nobody-${System.nanoTime()}@test.local", "x".repeat(12),
                ClientType.ANDROID)
        }
        val wrongPassword = assertFailsWith<ApiException> {
            auth.signIn(known, "definitely not it", ClientType.ANDROID)
        }
        assertEquals(unknown.message, wrongPassword.message)
    }

    @Test
    fun `registering an existing address does not confirm it exists`() {
        val e = email()
        auth.register(
            email = e, password = "a quiet evening",
            clientType = ClientType.ANDROID, ageConfirmed = true,
        )
        val again = assertFailsWith<ApiException> {
            auth.register(
                email = e, password = "another quiet evening",
                clientType = ClientType.ANDROID, ageConfirmed = true,
            )
        }
        // Never "that email is taken".
        assertTrue(!again.message!!.lowercase().contains("exist"))
        assertTrue(!again.message!!.lowercase().contains("taken"))
    }

    @Test
    fun `a short password is refused, and length is the only rule`() {
        assertFailsWith<ApiException> {
            auth.register(
                email = email(), password = "short",
                clientType = ClientType.ANDROID, ageConfirmed = true,
            )
        }
        // No character-class rules: they push people toward predictable
        // substitutions and a written-down password, which is worse on a
        // shared device than a long phrase they can remember.
        assertNotNull(
            auth.register(
                email = email(), password = "all lowercase words no digits",
                clientType = ClientType.ANDROID, ageConfirmed = true,
            ),
        )
    }

    @Test
    fun `a magic-link account has no password and cannot be signed into with one`() {
        val e = email()
        dsl.query(
            "insert into users (id, email, timezone) values (gen_random_uuid(), {0}, 'UTC')",
            e,
        ).execute()
        val hash = dsl.fetchOne(
            "select password_hash from users where email = {0}", e,
        )!!.get("password_hash", String::class.java)
        assertNull(hash)

        assertFailsWith<ApiException> {
            auth.signIn(e, "anything at all", ClientType.ANDROID)
        }
    }

    @Test
    fun `a stray space does not create a second account for the same person`() {
        val e = email()
        auth.register(
            email = e, password = "a quiet evening",
            clientType = ClientType.ANDROID, ageConfirmed = true,
        )

        // The unique index normalises with lower(btrim(email)). A duplicate
        // check that only lowercases lets this through, and the insert then
        // fails on the index — a 500 where the product means to say
        // COULD_NOT_REGISTER.
        val failure = assertFailsWith<ApiException> {
            auth.register(
                email = " $e ", password = "a quiet evening",
                clientType = ClientType.ANDROID, ageConfirmed = true,
            )
        }
        assertEquals("COULD_NOT_REGISTER", failure.code)
    }

    @Test
    fun `a stray space does not lock someone out of their own account`() {
        val e = email()
        auth.register(
            email = e, password = "a quiet evening",
            clientType = ClientType.ANDROID, ageConfirmed = true,
        )

        // A leading space is what a phone keyboard or a paste produces. It
        // must not read as a different person.
        val grant = auth.signIn(
            email = " $e", password = "a quiet evening",
            clientType = ClientType.ANDROID,
        )
        assertNotNull(grant.userId)
    }
}
