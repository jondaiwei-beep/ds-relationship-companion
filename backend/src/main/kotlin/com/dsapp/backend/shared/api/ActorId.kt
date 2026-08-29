package com.dsapp.backend.shared.api

import org.springframework.security.oauth2.jwt.Jwt
import java.util.UUID

/** The authenticated user id, from the JWT subject. Never from a request body. */
fun Jwt.actorId(): UUID = UUID.fromString(subject)
