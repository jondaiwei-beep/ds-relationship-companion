package com.dsapp.backend.identity.api

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Email
import com.dsapp.backend.identity.application.SessionGrant

import com.dsapp.backend.identity.application.AuthService
import com.dsapp.backend.identity.domain.AcceptedResponse
import com.dsapp.backend.identity.domain.AuthResponse
import com.dsapp.backend.identity.domain.ClientType
import com.dsapp.backend.identity.domain.ConsumeMagicLink
import com.dsapp.backend.identity.domain.RefreshRequest
import com.dsapp.backend.identity.domain.RequestMagicLink

import jakarta.servlet.http.HttpServletResponse
import jakarta.validation.Valid
import org.springframework.http.CacheControl
import org.springframework.http.HttpHeaders
import org.springframework.http.ResponseCookie
import org.springframework.http.ResponseEntity
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.CookieValue
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Duration
import java.util.UUID

data class RegisterRequest(
    @field:NotBlank @field:Email val email: String,
    @field:NotBlank val password: String,
    val clientType: String = "ANDROID",
    /** Notion 03 §2: the age gate is confirmed, never inferred. */
    val ageConfirmed: Boolean = false,
)

data class SignInRequest(
    @field:NotBlank @field:Email val email: String,
    @field:NotBlank val password: String,
    val clientType: String = "ANDROID",
)

@RestController
@RequestMapping("/v1/auth")
class AuthController(private val auth: AuthService) {
    @PostMapping("/register")
    fun register(
        @Valid @RequestBody body: RegisterRequest,
    ): ResponseEntity<AuthResponse> = tokenResponse(
        auth.register(
            email = body.email,
            password = body.password,
            clientType = ClientType.valueOf(body.clientType),
            ageConfirmed = body.ageConfirmed,
        ),
        ClientType.valueOf(body.clientType),
    )

    @PostMapping("/sign-in")
    fun signIn(
        @Valid @RequestBody body: SignInRequest,
    ): ResponseEntity<AuthResponse> = tokenResponse(
        auth.signIn(
            email = body.email,
            password = body.password,
            clientType = ClientType.valueOf(body.clientType),
        ),
        ClientType.valueOf(body.clientType),
    )

    @PostMapping("/magic-links")
    fun requestMagicLink(
        @Valid @RequestBody request: RequestMagicLink,
    ): ResponseEntity<AcceptedResponse> {
        auth.requestMagicLink(request)
        return ResponseEntity.accepted()
            .cacheControl(CacheControl.noStore())
            .body(AcceptedResponse())
    }

    @PostMapping("/magic-links/consume")
    fun consume(
        @Valid @RequestBody request: ConsumeMagicLink,
    ): ResponseEntity<AuthResponse> {
        val grant = auth.consume(request)
        return tokenResponse(grant, request.clientType)
    }

    @PostMapping("/refresh")
    fun refresh(
        @CookieValue(name = "__Host-refresh", required = false)
        cookieToken: String?,
        @RequestHeader(name = "X-Refresh-CSRF", required = false)
        csrfToken: String?,
        @RequestBody(required = false)
        request: RefreshRequest?,
    ): ResponseEntity<AuthResponse> {
        val isWeb = cookieToken != null
        val grant = auth.refresh(
            rawRefreshToken = cookieToken ?: request?.refreshToken,
            rawCsrfToken = csrfToken,
        )
        return tokenResponse(
            grant,
            if (isWeb) ClientType.WEB else ClientType.ANDROID,
        )
    }

    @PostMapping("/logout")
    fun logout(
        jwt: Jwt,
        response: HttpServletResponse,
    ): ResponseEntity<Void> {
        auth.logout(
            UUID.fromString(jwt.subject),
            UUID.fromString(jwt.getClaimAsString("sid")),
        )

        response.addHeader(
            HttpHeaders.SET_COOKIE,
            expiredCookie("__Host-refresh", true).toString(),
        )
        response.addHeader(
            HttpHeaders.SET_COOKIE,
            expiredCookie("__Host-refresh-csrf", false).toString(),
        )
        return ResponseEntity.noContent().build()
    }

    private fun tokenResponse(
        grant: SessionGrant,
        clientType: ClientType,
    ): ResponseEntity<AuthResponse> {
        val builder = ResponseEntity.ok()
            .cacheControl(CacheControl.noStore())

        if (clientType == ClientType.WEB) {
            builder.header(
                HttpHeaders.SET_COOKIE,
                refreshCookie(grant.refreshToken).toString(),
                csrfCookie(checkNotNull(grant.csrfToken)).toString(),
            )
        }

        return builder.body(
            auth.response(
                grant,
                includeRefreshToken = clientType == ClientType.ANDROID,
            )
        )
    }

    private fun refreshCookie(value: String): ResponseCookie =
        ResponseCookie.from("__Host-refresh", value)
            .secure(true)
            .httpOnly(true)
            .sameSite("Strict")
            .path("/")
            .maxAge(Duration.ofDays(7))
            .build()

    private fun csrfCookie(value: String): ResponseCookie =
        ResponseCookie.from("__Host-refresh-csrf", value)
            .secure(true)
            .httpOnly(false)
            .sameSite("Strict")
            .path("/")
            .maxAge(Duration.ofDays(7))
            .build()

    private fun expiredCookie(
        name: String,
        httpOnly: Boolean,
    ): ResponseCookie =
        ResponseCookie.from(name, "")
            .secure(true)
            .httpOnly(httpOnly)
            .sameSite("Strict")
            .path("/")
            .maxAge(Duration.ZERO)
            .build()
}
