package com.dsapp.backend.identity.domain

import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import org.springframework.http.HttpStatus
import org.springframework.security.oauth2.jose.jws.SignatureAlgorithm
import org.springframework.security.oauth2.jwt.JwtClaimsSet
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.JwtEncoderParameters
import org.springframework.security.oauth2.jwt.JwsHeader
import org.springframework.stereotype.Component
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import java.security.MessageDigest
import java.security.SecureRandom
import java.time.Clock
import java.time.Duration
import java.util.Base64
import java.util.Locale
import java.util.UUID

enum class ClientType { ANDROID, WEB }
enum class InviteState { PENDING, ACCEPTED, EXPIRED, REVOKED, INVALID }

data class RequestMagicLink(
    @field:Email val email: String,
    @field:NotNull val flowId: UUID,
    @field:NotBlank val codeChallenge: String,
    val inviteToken: String? = null,
)

data class ConsumeMagicLink(
    @field:NotBlank val token: String,
    @field:NotNull val flowId: UUID,
    @field:NotBlank val codeVerifier: String,
    @field:NotNull val clientType: ClientType,
)

data class RefreshRequest(val refreshToken: String?)
data class AcceptedResponse(val accepted: Boolean = true)

data class Continuation(
    val kind: String,
    val inviteId: UUID,
    val state: InviteState,
)

data class AuthResponse(
    val accessToken: String,
    val accessTokenExpiresInSeconds: Long,
    val refreshToken: String?,
    val continuation: Continuation?,
)

data class ResolveInviteRequest(@field:NotBlank val token: String)

data class InviteView(
    val inviteId: UUID?,
    val state: InviteState,
    val intendedRoleContext: String?,
    val expiresAt: String?,
)

data class AcceptInviteRequest(
    val token: String? = null,
    val inviteId: UUID? = null,
)

data class AcceptInviteResponse(
    val inviteId: UUID?,
    val state: InviteState,
    val membershipGranted: Boolean,
)

class ApiException(
    val status: HttpStatus,
    val code: String,
) : RuntimeException(code)

@RestControllerAdvice
class AuthApiErrorHandler {
    @ExceptionHandler(ApiException::class)
    fun handle(exception: ApiException) =
        org.springframework.http.ResponseEntity
            .status(exception.status)
            .body(mapOf("code" to exception.code))
}

@Component
class OpaqueTokens {
    private val random = SecureRandom()
    private val encoder = Base64.getUrlEncoder().withoutPadding()
    private val decoder = Base64.getUrlDecoder()

    fun magic(): String = generate("ml1.")
    fun refresh(): String = generate("rt1.")
    fun verifier(): String = encoder.encodeToString(randomBytes())

    fun hash(value: String): ByteArray =
        MessageDigest.getInstance("SHA-256")
            .digest(value.toByteArray(Charsets.US_ASCII))

    fun hashHex(value: String): String =
        hash(value).joinToString("") { "%02x".format(it) }

    fun decodeChallenge(value: String): ByteArray {
        val decoded = runCatching { decoder.decode(value) }
            .getOrElse { throw ApiException(HttpStatus.BAD_REQUEST, "INVALID_CHALLENGE") }
        if (decoded.size != 32) {
            throw ApiException(HttpStatus.BAD_REQUEST, "INVALID_CHALLENGE")
        }
        return decoded
    }

    fun validInvite(value: String): Boolean = valid(value, "iv1.")
    fun validMagic(value: String): Boolean = valid(value, "ml1.")
    fun validRefresh(value: String): Boolean = valid(value, "rt1.")

    fun constantTimeEquals(left: ByteArray, right: ByteArray): Boolean =
        MessageDigest.isEqual(left, right)

    fun normalizeEmail(value: String): String =
        value.trim().lowercase(Locale.ROOT)

    private fun generate(prefix: String): String =
        prefix + encoder.encodeToString(randomBytes())

    private fun randomBytes(): ByteArray =
        ByteArray(32).also(random::nextBytes)

    private fun valid(value: String, prefix: String): Boolean {
        if (!value.startsWith(prefix)) return false
        val body = value.removePrefix(prefix)
        if (body.length != 43) return false
        return runCatching { decoder.decode(body).size == 32 }.getOrDefault(false)
    }
}

@Component
class AccessTokenIssuer(
    private val encoder: JwtEncoder,
    private val properties: AuthProperties,
) {
    private val clock: Clock = Clock.systemUTC()
    private val lifetime = Duration.ofMinutes(5)

    fun issue(userId: UUID, sessionId: UUID): String {
        val now = clock.instant()
        val claims = JwtClaimsSet.builder()
            .issuer(properties.issuer)
            .audience(listOf(properties.audience))
            .subject(userId.toString())
            .id(UUID.randomUUID().toString())
            .issuedAt(now)
            .notBefore(now.minusSeconds(5))
            .expiresAt(now.plus(lifetime))
            .claim("sid", sessionId.toString())
            .build()

        val header = JwsHeader.with(SignatureAlgorithm.RS256)
            .keyId(properties.keyId)
            .build()

        return encoder.encode(JwtEncoderParameters.from(header, claims)).tokenValue
    }
}
