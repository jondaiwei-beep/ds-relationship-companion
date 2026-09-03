package com.dsapp.backend.notifications.api

import com.dsapp.backend.notifications.application.NotificationMuteSettingsService
import com.dsapp.backend.notifications.application.NotificationQueryService
import com.dsapp.backend.shared.api.actorId
import org.springframework.http.CacheControl
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.time.Instant
import java.util.UUID

data class MarkReadRequest(val ids: List<UUID>? = null, val allBefore: Instant? = null)

data class UpdateNotificationMuteSettings(
    val neutralLockscreen: Boolean? = null,
    val deliverDigestHours: Int? = null,
    /** True when the caller wants `deliverDigestHours` explicitly cleared to null. */
    val clearDeliverDigestHours: Boolean = false,
    val mutedTypes: Set<String>? = null,
)

/** A member's own notification inbox and per-type mute/digest preferences. Addressed as `/v1/me/...`. */
@RestController
@RequestMapping("/v1/me")
class NotificationController(
    private val notifications: NotificationQueryService,
    private val muteSettings: NotificationMuteSettingsService,
) {

    @GetMapping("/notifications")
    fun list(
        @AuthenticationPrincipal jwt: Jwt,
        @RequestParam(required = false) since: Instant?,
        @RequestParam(required = false, defaultValue = "50") limit: Int,
    ): ResponseEntity<Any> {
        val result = notifications.list(jwt.actorId(), since, limit)
        return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(
            mapOf(
                "items" to result.items,
                "unreadCount" to result.unreadCount,
            ),
        )
    }

    @GetMapping("/notifications/unread-count")
    fun unreadCount(@AuthenticationPrincipal jwt: Jwt): ResponseEntity<Any> =
        ResponseEntity.ok().cacheControl(CacheControl.noStore())
            .body(mapOf("unreadCount" to notifications.unreadCount(jwt.actorId())))

    @PostMapping("/notifications/read")
    fun markRead(
        @AuthenticationPrincipal jwt: Jwt,
        @RequestBody(required = false) body: MarkReadRequest?,
    ): ResponseEntity<Any> {
        val updated = notifications.markRead(jwt.actorId(), body?.ids, body?.allBefore)
        return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(mapOf("updated" to updated))
    }

    @GetMapping("/notification-mute-settings")
    fun getMuteSettings(@AuthenticationPrincipal jwt: Jwt): ResponseEntity<Any> =
        ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(muteSettings.forUser(jwt.actorId()))

    @PutMapping("/notification-mute-settings")
    fun updateMuteSettings(
        @AuthenticationPrincipal jwt: Jwt,
        @RequestBody body: UpdateNotificationMuteSettings,
    ): ResponseEntity<Any> = ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(
        muteSettings.update(
            userId = jwt.actorId(),
            neutralLockscreen = body.neutralLockscreen,
            deliverDigestHours = if (body.clearDeliverDigestHours) null else body.deliverDigestHours,
            deliverDigestHoursSet = body.clearDeliverDigestHours || body.deliverDigestHours != null,
            mutedTypes = body.mutedTypes,
        ),
    )
}
