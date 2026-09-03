package com.dsapp.backend.identity.infrastructure

import com.dsapp.backend.identity.domain.AuthProperties

import com.dsapp.backend.identity.application.AuthService

import com.nimbusds.jose.jwk.JWKSet
import com.nimbusds.jose.jwk.RSAKey
import com.nimbusds.jose.jwk.source.JWKSource
import com.nimbusds.jose.proc.SecurityContext
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.http.MediaType
import org.springframework.security.config.Customizer
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator
import org.springframework.security.oauth2.core.OAuth2Error
import org.springframework.security.oauth2.core.OAuth2TokenValidator
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult
import org.springframework.security.oauth2.jose.jws.SignatureAlgorithm
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.JwtValidators
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder
import org.springframework.security.web.SecurityFilterChain
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource
import java.security.KeyFactory
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.interfaces.RSAPrivateKey
import java.security.interfaces.RSAPublicKey
import java.security.spec.PKCS8EncodedKeySpec
import java.security.spec.X509EncodedKeySpec
import java.util.Base64

@Configuration
class SecurityConfig(
    private val properties: AuthProperties,
    private val environment: org.springframework.core.env.Environment,
) {
    /** BCrypt at the Spring default cost. */
    @Bean
    fun passwordEncoder(): org.springframework.security.crypto.password.PasswordEncoder =
        org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder()

    @Bean
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
        // Staging has no email sender, so the client completes the magic-link
        // round trip itself. The endpoint returns a credential, so it is
        // permitted ONLY when the staging profile is genuinely active — the
        // controller behind it does not exist otherwise either.
        val staging = environment.activeProfiles.contains("staging")
        http
            .cors { it.configurationSource(corsConfigurationSource()) }
            // All authenticated business APIs use Authorization: Bearer.
            // Refresh-cookie CSRF is checked explicitly in AuthService.
            .csrf { it.disable() }
            .sessionManagement {
                it.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            }
            .authorizeHttpRequests {
                it.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                it.requestMatchers(HttpMethod.POST, "/v1/auth/register").permitAll()
                it.requestMatchers(HttpMethod.POST, "/v1/auth/sign-in").permitAll()
                it.requestMatchers(HttpMethod.POST, "/v1/auth/magic-links").permitAll()
                it.requestMatchers(HttpMethod.POST, "/v1/auth/magic-links/consume").permitAll()
                it.requestMatchers(HttpMethod.POST, "/v1/auth/refresh").permitAll()
                it.requestMatchers(HttpMethod.POST, "/v1/invites/resolve").permitAll()
                it.requestMatchers("/actuator/health").permitAll()
                // Which optional surfaces are on. No user data, no
                // relationship content — readable before a session exists so
                // the sign-in screen can honour the same switches.
                it.requestMatchers(HttpMethod.GET, "/v1/features").permitAll()
                if (staging) {
                    it.requestMatchers(HttpMethod.GET, "/v1/staging/**").permitAll()
                }
                // M0 exit criterion: the API contract must be inspectable so
                // drift is caught. The spec describes shapes only — no data.
                it.requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                it.anyRequest().authenticated()
            }
            .oauth2ResourceServer {
                it.jwt(Customizer.withDefaults())
                it.authenticationEntryPoint { _, response, _ ->
                    response.status = 401
                    response.contentType = MediaType.APPLICATION_JSON_VALUE
                    response.writer.write("""{"code":"UNAUTHORIZED"}""")
                }
            }
            .exceptionHandling {
                it.accessDeniedHandler { _, response, _ ->
                    response.status = 403
                    response.contentType = MediaType.APPLICATION_JSON_VALUE
                    response.writer.write("""{"code":"FORBIDDEN"}""")
                }
            }

        return http.build()
    }

    @Bean
    fun jwtEncoder(): JwtEncoder {
        val key = RSAKey.Builder(publicKey())
            .privateKey(privateKey())
            .keyID(properties.keyId)
            .build()

        val keySet = JWKSet(key)
        val source = JWKSource<SecurityContext> { selector, _ ->
            selector.select(keySet)
        }
        return NimbusJwtEncoder(source)
    }

    @Bean
    fun jwtDecoder(): JwtDecoder {
        val decoder = NimbusJwtDecoder.withPublicKey(publicKey())
            .signatureAlgorithm(SignatureAlgorithm.RS256)
            .build()

        val issuerValidator = JwtValidators.createDefaultWithIssuer(properties.issuer)
        val audienceValidator = OAuth2TokenValidator<Jwt> { jwt ->
            if (jwt.audience.contains(properties.audience)) {
                OAuth2TokenValidatorResult.success()
            } else {
                OAuth2TokenValidatorResult.failure(
                    OAuth2Error("invalid_token", "Required audience is missing", null)
                )
            }
        }

        decoder.setJwtValidator(
            DelegatingOAuth2TokenValidator(issuerValidator, audienceValidator)
        )
        return decoder
    }

    @Bean
    fun corsConfigurationSource(): CorsConfigurationSource {
        val configuration = CorsConfiguration().apply {
            allowedOrigins = properties.allowedOrigins
            allowedMethods = listOf("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
            allowedHeaders = listOf(
                "Authorization",
                "Content-Type",
                "Idempotency-Key",
                "X-Refresh-CSRF",
            )
            allowCredentials = true
            maxAge = 3600
        }

        return UrlBasedCorsConfigurationSource().apply {
            registerCorsConfiguration("/**", configuration)
        }
    }

    /**
     * Dev/test convenience: when no keys are configured, generate an ephemeral
     * RSA keypair once per JVM so the app boots without secrets.
     *
     * Tokens signed by an ephemeral key die with the process — that is the
     * intended behaviour locally. Production MUST set
     * `dsapp.auth.private-key-base64` / `public-key-base64`, and
     * [requireProductionKeys] enforces that.
     */
    private val ephemeralKeyPair: KeyPair by lazy {
        val log = org.slf4j.LoggerFactory.getLogger(SecurityConfig::class.java)
        log.warn(
            "No RSA keys configured — generating an EPHEMERAL keypair. " +
                "All sessions are invalidated on restart. Never use this in production.",
        )
        KeyPairGenerator.getInstance("RSA").apply { initialize(2048) }.generateKeyPair()
    }

    private fun publicKey(): RSAPublicKey {
        if (properties.publicKeyBase64.isBlank()) {
            return ephemeralKeyPair.public as RSAPublicKey
        }
        val bytes = Base64.getDecoder().decode(properties.publicKeyBase64)
        return KeyFactory.getInstance("RSA")
            .generatePublic(X509EncodedKeySpec(bytes)) as RSAPublicKey
    }

    private fun privateKey(): RSAPrivateKey {
        if (properties.privateKeyBase64.isBlank()) {
            return ephemeralKeyPair.private as RSAPrivateKey
        }
        val bytes = Base64.getDecoder().decode(properties.privateKeyBase64)
        return KeyFactory.getInstance("RSA")
            .generatePrivate(PKCS8EncodedKeySpec(bytes)) as RSAPrivateKey
    }
}
