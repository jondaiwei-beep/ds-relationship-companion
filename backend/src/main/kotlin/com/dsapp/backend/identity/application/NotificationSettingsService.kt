package com.dsapp.backend.identity.application

import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

/**
 * The member's own notification settings (Notion 04 §5).
 *
 * These belong to the **User**, never to a Membership: a person's quiet hours
 * and lockscreen privacy follow them across every dynamic, and no partner or
 * role may set or see them.
 */
@Service
class NotificationSettingsService(private val dsl: DSLContext) {

    data class Settings(
        val timezone: String,
        /** NEUTRAL or RICH. Neutral is the default (red line #5). */
        val notificationPreview: String,
        /** Minutes past local midnight, or null when quiet hours are off. */
        val quietHoursStartMin: Int?,
        val quietHoursEndMin: Int?,
    )

    class InvalidSettings(message: String) : IllegalArgumentException(message)

    @Transactional(readOnly = true)
    fun forUser(userId: UUID): Settings {
        val r = dsl.fetchOne(
            """
            SELECT timezone, notification_preview,
                   quiet_hours_start_min, quiet_hours_end_min
              FROM users WHERE id = {0}
            """.trimIndent(),
            userId,
        ) ?: throw InvalidSettings("no such user")

        return Settings(
            timezone = r.get("timezone", String::class.java),
            notificationPreview = r.get("notification_preview", String::class.java),
            quietHoursStartMin = r.get("quiet_hours_start_min", Int::class.javaObjectType),
            quietHoursEndMin = r.get("quiet_hours_end_min", Int::class.javaObjectType),
        )
    }

    /**
     * Only the member themself may call this — the caller's id comes from the
     * JWT, never from the request body, so there is no user to impersonate.
     *
     * Quiet hours are stored as a pair or not at all: half a window has no
     * meaning, and a partially-set window would silently suppress nothing.
     */
    @Transactional
    fun update(
        userId: UUID,
        notificationPreview: String?,
        quietHoursStartMin: Int?,
        quietHoursEndMin: Int?,
    ): Settings {
        if (notificationPreview != null &&
            notificationPreview !in setOf("NEUTRAL", "RICH")
        ) {
            throw InvalidSettings("notificationPreview must be NEUTRAL or RICH")
        }
        if ((quietHoursStartMin == null) != (quietHoursEndMin == null)) {
            throw InvalidSettings("quiet hours need both a start and an end, or neither")
        }
        for (m in listOfNotNull(quietHoursStartMin, quietHoursEndMin)) {
            if (m !in 0..1439) throw InvalidSettings("minutes must be within a day")
        }
        // A window that starts and ends at the same minute is ambiguous: it
        // reads as both "never quiet" and "always quiet". Rejected rather
        // than guessed, because guessing wrong means a notification lands at
        // 3am or never lands at all.
        if (quietHoursStartMin != null && quietHoursStartMin == quietHoursEndMin) {
            throw InvalidSettings("quiet hours cannot start and end at the same minute")
        }

        dsl.query(
            """
            UPDATE users
               SET notification_preview = COALESCE({1}, notification_preview),
                   quiet_hours_start_min = {2},
                   quiet_hours_end_min = {3},
                   updated_at = now()
             WHERE id = {0}
            """.trimIndent(),
            userId, notificationPreview, quietHoursStartMin, quietHoursEndMin,
        ).execute()

        return forUser(userId)
    }
}
