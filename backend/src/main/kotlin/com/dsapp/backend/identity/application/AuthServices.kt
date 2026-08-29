package com.dsapp.backend.identity.application

import com.dsapp.backend.identity.domain.AuthProperties

import com.dsapp.backend.identity.domain.AccessTokenIssuer
import com.dsapp.backend.identity.domain.ApiException
import com.dsapp.backend.identity.domain.AuthResponse
import com.dsapp.backend.identity.domain.ClientType
import com.dsapp.backend.identity.domain.ConsumeMagicLink
import com.dsapp.backend.identity.domain.Continuation
import com.dsapp.backend.identity.domain.InviteState
import com.dsapp.backend.identity.domain.OpaqueTokens
import com.dsapp.backend.identity.domain.RequestMagicLink

import org.jooq.DSLContext
import org.jooq.impl.DSL
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import java.net.URLEncoder
import java.nio.charset.StandardCharsets
import java.time.OffsetDateTime
import java.util.UUID

interface MagicLinkSender {
    fun send(email: String, url: String)
}

data class SessionGrant(
    val userId: UUID,
    val sessionId: UUID,
    val refreshToken: String,
    val csrfToken: String?,
    val continuation: Continuation?,
)

@Service
class AuthService(
    private val dsl: DSLContext,
    private val tokens: OpaqueTokens,
    private val accessTokens: AccessTokenIssuer,
    private val properties: AuthProperties,
    private val magicLinkSender: MagicLinkSender,
    private val passwordEncoder: org.springframework.security.crypto.password.PasswordEncoder,
) {
    fun requestMagicLink(request: RequestMagicLink) {
        val email = tokens.normalizeEmail(request.email)
        val token = tokens.magic()
        val tokenHash = tokens.hash(token)
        val verifierHash = tokens.decodeChallenge(request.codeChallenge)

        val inviteId = request.inviteToken
            ?.takeIf(tokens::validInvite)
            ?.let { raw ->
                dsl.fetchOne(
                    "select id from invites where token_hash = ?",
                    tokens.hash(raw),
                )?.get("id", UUID::class.java)
            }

        dsl.query(
            """
            insert into magic_link_tokens (
                id, flow_id, normalized_email, token_hash, verifier_hash,
                continuation_invite_id, state, created_at, expires_at
            )
            values (
                ?, ?, ?, ?, ?, ?, 'PENDING',
                clock_timestamp(), clock_timestamp() + interval '10 minutes'
            )
            """.trimIndent(),
            UUID.randomUUID(),
            request.flowId,
            email,
            tokenHash,
            verifierHash,
            inviteId,
        ).execute()

        // Fragment values are not sent in the initial HTTP request or Referer.
        val url = "${properties.webBaseUrl}/auth/callback" +
            "#ml=${encode(token)}&flow=${request.flowId}"

        try {
            magicLinkSender.send(email, url)
        } catch (exception: Exception) {
            dsl.query(
                """
                update magic_link_tokens
                   set state = 'REVOKED', revoked_at = clock_timestamp()
                 where token_hash = ? and state = 'PENDING'
                """.trimIndent(),
                tokenHash,
            ).execute()

            // Preserve the generic client response; alert internally.
        }
    }

    fun consume(request: ConsumeMagicLink): SessionGrant {
        if (!tokens.validMagic(request.token)) {
            throw ApiException(HttpStatus.UNAUTHORIZED, "INVALID_OR_EXPIRED_MAGIC_LINK")
        }

        val tokenHash = tokens.hash(request.token)
        val verifierHash = tokens.hash(request.codeVerifier)

        val grant = dsl.transactionResult { configuration ->
            val tx = DSL.using(configuration)

            tx.query(
                """
                update magic_link_tokens
                   set state = 'EXPIRED', expired_at = clock_timestamp()
                 where token_hash = ?
                   and state = 'PENDING'
                   and expires_at <= clock_timestamp()
                """.trimIndent(),
                tokenHash,
            ).execute()

            val magic = tx.fetchOne(
                """
                update magic_link_tokens
                   set state = 'CONSUMED', consumed_at = clock_timestamp()
                 where token_hash = ?
                   and flow_id = ?
                   and verifier_hash = ?
                   and state = 'PENDING'
                   and expires_at > clock_timestamp()
                returning id, normalized_email, continuation_invite_id
                """.trimIndent(),
                tokenHash,
                request.flowId,
                verifierHash,
            ) ?: return@transactionResult null

            val email = magic.get("normalized_email", String::class.java)
            val inviteId = magic.get("continuation_invite_id", UUID::class.java)

            val user = tx.fetchOne(
                """
                insert into users (
                    id, email, display_name, timezone, notification_preview,
                    account_state, created_at, updated_at
                )
                values (
                    ?, ?, ?, 'UTC', 'NEUTRAL', 'ACTIVE',
                    clock_timestamp(), clock_timestamp()
                )
                on conflict ((lower(btrim(email)))) do update
                    set email = excluded.email
                returning id, account_state
                """.trimIndent(),
                UUID.randomUUID(),
                email,
                defaultDisplayName(email),
            ) ?: error("user upsert returned no row")

            if (user.get("account_state", String::class.java) != "ACTIVE") {
                throw ApiException(HttpStatus.FORBIDDEN, "ACCOUNT_NOT_ACTIVE")
            }

            val userId = user.get("id", UUID::class.java)

            // Once one link succeeds, other outstanding links for that email die.
            tx.query(
                """
                update magic_link_tokens
                   set state = 'REVOKED', revoked_at = clock_timestamp()
                 where normalized_email = ?
                   and token_hash <> ?
                   and state = 'PENDING'
                """.trimIndent(),
                email,
                tokenHash,
            ).execute()

            createSession(tx, userId, request.clientType, inviteId)
        } ?: throw ApiException(
            HttpStatus.UNAUTHORIZED,
            "INVALID_OR_EXPIRED_MAGIC_LINK",
        )

        return grant
    }

    fun refresh(
        rawRefreshToken: String?,
        rawCsrfToken: String?,
    ): SessionGrant {
        if (rawRefreshToken == null || !tokens.validRefresh(rawRefreshToken)) {
            throw ApiException(HttpStatus.UNAUTHORIZED, "INVALID_REFRESH_TOKEN")
        }

        val refreshHash = tokens.hash(rawRefreshToken)

        val grant: SessionGrant? = dsl.transactionResult { configuration ->
            val tx = DSL.using(configuration)
            val row = tx.fetchOne(
                """
                select
                    rt.id as refresh_id,
                    rt.state as refresh_state,
                    rt.expires_at as refresh_expires_at,
                    s.id as session_id,
                    s.user_id,
                    s.client_type,
                    s.csrf_token_hash,
                    s.continuation_invite_id,
                    s.idle_expires_at,
                    s.absolute_expires_at,
                    s.revoked_at
                from refresh_tokens rt
                join auth_sessions s on s.id = rt.session_id
                where rt.token_hash = ?
                for update of rt, s
                """.trimIndent(),
                refreshHash,
            ) ?: return@transactionResult null

            val sessionId = row.get("session_id", UUID::class.java)
            val refreshId = row.get("refresh_id", UUID::class.java)
            val userId = row.get("user_id", UUID::class.java)
            val clientType = ClientType.valueOf(
                row.get("client_type", String::class.java)
            )
            val now = OffsetDateTime.now()
            val refreshExpiresAt =
                row.get("refresh_expires_at", OffsetDateTime::class.java)
            val idleExpiresAt =
                row.get("idle_expires_at", OffsetDateTime::class.java)
            val absoluteExpiresAt =
                row.get("absolute_expires_at", OffsetDateTime::class.java)

            if (row.get("revoked_at", OffsetDateTime::class.java) != null ||
                now >= refreshExpiresAt ||
                now >= idleExpiresAt ||
                now >= absoluteExpiresAt
            ) {
                revokeSession(tx, sessionId, "EXPIRED")
                return@transactionResult null
            }

            if (row.get("refresh_state", String::class.java) != "ACTIVE") {
                // An already-rotated token indicates replay. Kill the family.
                revokeSession(tx, sessionId, "REFRESH_TOKEN_REUSE")
                return@transactionResult null
            }

            if (clientType == ClientType.WEB) {
                val storedCsrf = row.get("csrf_token_hash", ByteArray::class.java)
                val presentedCsrf = rawCsrfToken?.let(tokens::hash)
                if (presentedCsrf == null ||
                    !tokens.constantTimeEquals(storedCsrf, presentedCsrf)
                ) {
                    return@transactionResult null
                }
            }

            val changed = tx.query(
                """
                update refresh_tokens
                   set state = 'ROTATED', rotated_at = clock_timestamp()
                 where id = ? and state = 'ACTIVE'
                """.trimIndent(),
                refreshId,
            ).execute()

            if (changed != 1) {
                revokeSession(tx, sessionId, "REFRESH_TOKEN_REUSE")
                return@transactionResult null
            }

            val nextRefresh = tokens.refresh()
            val nextCsrf =
                if (clientType == ClientType.WEB) tokens.verifier() else null

            val session = tx.fetchOne(
                """
                update auth_sessions
                   set last_used_at = clock_timestamp(),
                       idle_expires_at = least(
                           absolute_expires_at,
                           clock_timestamp() + interval '7 days'
                       ),
                       csrf_token_hash = ?
                 where id = ?
                   and revoked_at is null
                returning idle_expires_at
                """.trimIndent(),
                nextCsrf?.let(tokens::hash),
                sessionId,
            ) ?: return@transactionResult null

            tx.query(
                """
                insert into refresh_tokens (
                    id, session_id, parent_token_id, token_hash,
                    state, issued_at, expires_at
                )
                values (
                    ?, ?, ?, ?, 'ACTIVE', clock_timestamp(), ?
                )
                """.trimIndent(),
                UUID.randomUUID(),
                sessionId,
                refreshId,
                tokens.hash(nextRefresh),
                session.get("idle_expires_at", OffsetDateTime::class.java),
            ).execute()

            SessionGrant(
                userId = userId,
                sessionId = sessionId,
                refreshToken = nextRefresh,
                csrfToken = nextCsrf,
                continuation = continuation(
                    tx,
                    row.get("continuation_invite_id", UUID::class.java),
                ),
            )
        }

        return grant ?: throw ApiException(
            HttpStatus.UNAUTHORIZED,
            "INVALID_REFRESH_TOKEN",
        )
    }

    fun logout(userId: UUID, sessionId: UUID) {
        dsl.query(
            """
            update auth_sessions
               set revoked_at = coalesce(revoked_at, clock_timestamp()),
                   revoked_reason = coalesce(revoked_reason, 'USER_LOGOUT')
             where id = ? and user_id = ?
            """.trimIndent(),
            sessionId,
            userId,
        ).execute()
    }

    fun response(grant: SessionGrant, includeRefreshToken: Boolean): AuthResponse =
        AuthResponse(
            accessToken = accessTokens.issue(grant.userId, grant.sessionId),
            accessTokenExpiresInSeconds = 300,
            refreshToken = grant.refreshToken.takeIf { includeRefreshToken },
            continuation = grant.continuation,
        )

    /**
     * Sign up with an email and a password — Journey A, the ordinary door.
     *
     * Magic links stay, but they cannot be the only way in: a person on a
     * phone has to leave the app, find a mail client and come back, and the
     * first wall is where most people stop.
     *
     * The age gate is confirmed here rather than inferred (Notion 03 §2).
     * This is the first flow where a person states it directly.
     */
    fun register(
        email: String,
        password: String,
        clientType: ClientType,
        ageConfirmed: Boolean,
    ): SessionGrant {
        if (!ageConfirmed) {
            throw ApiException(HttpStatus.BAD_REQUEST, "AGE_NOT_CONFIRMED")
        }
        requireUsablePassword(password)

        // The unique index normalises with lower(btrim(email)), so anything
        // less here lets " a@b.com " past the duplicate check and into an
        // index violation — a 500 where the product means COULD_NOT_REGISTER.
        val normalized = tokens.normalizeEmail(email)

        return dsl.transactionResult { configuration ->
            val tx = DSL.using(configuration)
            val existing = tx.fetchOne(
                "select id, password_hash from users where lower(btrim(email)) = ?",
                normalized,
            )
            if (existing != null) {
                // Never disclose whether an address is registered — that
                // turns sign-up into an account-existence oracle for an
                // intimate product.
                throw ApiException(HttpStatus.CONFLICT, "COULD_NOT_REGISTER")
            }

            val userId = UUID.randomUUID()
            tx.query(
                """
                insert into users (
                    id, email, display_name, password_hash, timezone,
                    notification_preview, age_gate_confirmed_at
                )
                values (?, ?, ?, ?, 'UTC', 'NEUTRAL', clock_timestamp())
                """.trimIndent(),
                userId, normalized, defaultDisplayName(normalized),
                passwordEncoder.encode(password),
            ).execute()

            createSession(tx, userId, clientType, inviteId = null)
        }
    }

    /** Sign in with an email and a password. */
    fun signIn(
        email: String,
        password: String,
        clientType: ClientType,
    ): SessionGrant = dsl.transactionResult { configuration ->
        val tx = DSL.using(configuration)
        // A leading space is what a phone keyboard or a paste produces. It
        // must not read as a different person.
        val row = tx.fetchOne(
            "select id, password_hash from users where lower(btrim(email)) = ?",
            tokens.normalizeEmail(email),
        )
        val hash = row?.get("password_hash", String::class.java)

        // One message for "no such account", "no password set" and "wrong
        // password". Distinguishing them tells an attacker — or a partner
        // holding the phone — which addresses have accounts here.
        if (row == null || hash == null ||
            !passwordEncoder.matches(password, hash)
        ) {
            throw ApiException(HttpStatus.UNAUTHORIZED, "INVALID_CREDENTIALS")
        }

        createSession(
            tx, row.get("id", UUID::class.java), clientType, inviteId = null,
        )
    }

    /**
     * Long enough to be worth having, with no composition rules.
     *
     * Character-class requirements push people toward predictable
     * substitutions and a written-down password, which is worse on a shared
     * device than a long phrase they can remember.
     */
    private fun requireUsablePassword(password: String) {
        if (password.length < 10) {
            throw ApiException(HttpStatus.BAD_REQUEST, "PASSWORD_TOO_SHORT")
        }
        if (password.length > 256) {
            throw ApiException(HttpStatus.BAD_REQUEST, "PASSWORD_TOO_LONG")
        }
    }

    private fun createSession(
        tx: DSLContext,
        userId: UUID,
        clientType: ClientType,
        inviteId: UUID?,
    ): SessionGrant {
        val sessionId = UUID.randomUUID()
        val refreshToken = tokens.refresh()
        val csrfToken =
            if (clientType == ClientType.WEB) tokens.verifier() else null

        tx.query(
            """
            insert into auth_sessions (
                id, user_id, client_type, continuation_invite_id,
                csrf_token_hash, created_at, last_used_at,
                idle_expires_at, absolute_expires_at
            )
            values (
                ?, ?, ?, ?, ?, clock_timestamp(), clock_timestamp(),
                clock_timestamp() + interval '7 days',
                clock_timestamp() + interval '30 days'
            )
            """.trimIndent(),
            sessionId,
            userId,
            clientType.name,
            inviteId,
            csrfToken?.let(tokens::hash),
        ).execute()

        tx.query(
            """
            insert into refresh_tokens (
                id, session_id, parent_token_id, token_hash,
                state, issued_at, expires_at
            )
            values (
                ?, ?, null, ?, 'ACTIVE', clock_timestamp(),
                clock_timestamp() + interval '7 days'
            )
            """.trimIndent(),
            UUID.randomUUID(),
            sessionId,
            tokens.hash(refreshToken),
        ).execute()

        return SessionGrant(
            userId = userId,
            sessionId = sessionId,
            refreshToken = refreshToken,
            csrfToken = csrfToken,
            continuation = continuation(tx, inviteId),
        )
    }

    private fun continuation(
        tx: DSLContext,
        inviteId: UUID?,
    ): Continuation? {
        if (inviteId == null) return null

        expireInvite(tx, inviteId)
        val state = tx.fetchOne(
            "select state from invites where id = ?",
            inviteId,
        )?.get("state", String::class.java) ?: return null

        return Continuation(
            kind = "INVITE",
            inviteId = inviteId,
            state = InviteState.valueOf(state),
        )
    }

    private fun expireInvite(tx: DSLContext, inviteId: UUID) {
        tx.query(
            """
            update invites
               set state = 'EXPIRED', expired_at = clock_timestamp()
             where id = ?
               and state = 'PENDING'
               and expires_at <= clock_timestamp()
            """.trimIndent(),
            inviteId,
        ).execute()
    }

    private fun revokeSession(
        tx: DSLContext,
        sessionId: UUID,
        reason: String,
    ) {
        tx.query(
            """
            update auth_sessions
               set revoked_at = coalesce(revoked_at, clock_timestamp()),
                   revoked_reason = coalesce(revoked_reason, ?)
             where id = ?
            """.trimIndent(),
            reason,
            sessionId,
        ).execute()
    }

    private fun defaultDisplayName(email: String): String =
        email.substringBefore('@').take(80).ifBlank { "Member" }

    private fun encode(value: String): String =
        URLEncoder.encode(value, StandardCharsets.UTF_8)
}
