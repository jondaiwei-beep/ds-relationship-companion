package com.dsapp.backend.identity.domain

import org.springframework.boot.context.properties.ConfigurationProperties

/**
 * Auth configuration (ADR-0001; Notion 04 §2).
 *
 * RS256 keys are supplied as base64 DER via environment variables — never
 * committed. Dev defaults are generated at startup when absent; production
 * must set them explicitly.
 */
@ConfigurationProperties(prefix = "dsapp.auth")
data class AuthProperties(
    /** JWT `iss`. */
    val issuer: String = "https://api.dsapp.local",
    /** JWT `aud`. */
    val audience: String = "dsapp-clients",
    /** JWK `kid`, so keys can be rotated without invalidating every token. */
    val keyId: String = "dsapp-dev",
    /** Base64 PKCS#8 RSA private key. Empty in dev -> ephemeral keypair. */
    val privateKeyBase64: String = "",
    /** Base64 X.509 RSA public key. Empty in dev -> ephemeral keypair. */
    val publicKeyBase64: String = "",
    /** Web companion origin, used to build magic-link and invite URLs. */
    val webBaseUrl: String = "http://localhost:8090",
    /**
     * CORS allow-list for the Flutter Web companion.
     *
     * Dev defaults cover a locally served release build (8090) and
     * `flutter run -d chrome` (5000). Production MUST set this explicitly to
     * the real origin — a wildcard would let any site call the API with a
     * user's credentials.
     */
    val allowedOrigins: List<String> = listOf(
        "http://localhost:8090",
        "http://localhost:5000",
    ),
)
