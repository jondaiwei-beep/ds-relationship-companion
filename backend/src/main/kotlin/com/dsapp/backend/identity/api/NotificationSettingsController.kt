package com.dsapp.backend.identity.api

import com.dsapp.backend.identity.application.NotificationSettingsService
import com.dsapp.backend.shared.api.actorId
import jakarta.validation.Valid
import org.springframework.http.CacheControl
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

data class UpdateNotificationSettings(
    val notificationPreview: String? = null,
    val quietHoursStartMin: Int? = null,
    val quietHoursEndMin: Int? = null,
)

/**
 * A member's own notification settings.
 *
 * Addressed as `/v1/me/...`: the subject is always the caller. There is no
 * path parameter for a user id, so no request can even be shaped to read or
 * change somebody else's quiet hours.
 */
@RestController
@RequestMapping("/v1/me")
class NotificationSettingsController(
    private val settings: NotificationSettingsService,
) {
    @GetMapping("/notification-settings")
    fun get(@AuthenticationPrincipal jwt: Jwt): ResponseEntity<Any> =
        ResponseEntity.ok()
            .cacheControl(CacheControl.noStore())
            .body(settings.forUser(jwt.actorId()))

    @PostMapping("/notification-settings")
    fun update(
        @AuthenticationPrincipal jwt: Jwt,
        @Valid @RequestBody body: UpdateNotificationSettings,
    ): ResponseEntity<Any> = ResponseEntity.ok()
        .cacheControl(CacheControl.noStore())
        .body(
            settings.update(
                userId = jwt.actorId(),
                notificationPreview = body.notificationPreview,
                quietHoursStartMin = body.quietHoursStartMin,
                quietHoursEndMin = body.quietHoursEndMin,
            ),
        )
}
