package com.dsapp.backend.dynamic.domain

/**
 * Authorization failure.
 *
 * Notion 03 §7 / 06 §3: authorization is ALWAYS server-side. A hidden client
 * button is never evidence that an endpoint will not be called.
 */
sealed class AuthorizationException(message: String) : RuntimeException(message) {

    /** Actor holds no membership, or has LEFT/been BLOCKED. */
    class NotAMember : AuthorizationException("Actor is not an active member of this dynamic")

    /** Wrong role for this command. */
    class WrongRole(required: RoleContext, actual: RoleContext) :
        AuthorizationException("Command requires $required, actor holds $actual")

    /** Dynamic is not ACTIVE, so mutations are refused. */
    class DynamicNotActive(state: DynamicState) :
        AuthorizationException("Dynamic is $state; mutations require ACTIVE")
}
