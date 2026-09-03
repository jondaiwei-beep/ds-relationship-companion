package com.dsapp.backend.notifications.application

import com.dsapp.backend.delivery.domain.EventCopy
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

/**
 * Per-type notification muting and digest cadence — distinct from the
 * device-level quiet-hours/lockscreen-richness settings on `users`
 * ([com.dsapp.backend.identity.application.NotificationSettingsService]).
 *
 * Muting never suppresses server-side delivery or the stored row (Notion 04
 * §7/§8 discipline: the record must never be dropped) — it is purely a
 * client-side signal, exposed back so the client can decide not to alert.
 */
@Service
class NotificationMuteSettingsService(private val dsl: DSLContext) {

    class InvalidSettings(message: String) : IllegalArgumentException(message)

    data class Settings(
        val neutralLockscreen: Boolean,
        val deliverDigestHours: Int?,
        val mutedTypes: Set<String>,
    )

    @Transactional(readOnly = true)
    fun forUser(userId: UUID): Settings {
        val r = dsl.fetchOne(
            "SELECT neutral_lockscreen, deliver_digest_hours, muted_types FROM notification_settings WHERE user_id = {0}",
            userId,
        ) ?: return Settings(neutralLockscreen = false, deliverDigestHours = null, mutedTypes = emptySet())
        return Settings(
            neutralLockscreen = r.get("neutral_lockscreen", Boolean::class.java),
            deliverDigestHours = r.get("deliver_digest_hours", Int::class.javaObjectType),
            mutedTypes = (r.get("muted_types", Array<String>::class.java) ?: emptyArray()).toSet(),
        )
    }

    @Transactional
    fun update(
        userId: UUID,
        neutralLockscreen: Boolean?,
        deliverDigestHours: Int?,
        deliverDigestHoursSet: Boolean,
        mutedTypes: Set<String>?,
    ): Settings {
        if (deliverDigestHours != null && deliverDigestHours <= 0) {
            throw InvalidSettings("deliverDigestHours must be positive")
        }
        val unknown = mutedTypes?.filterNot { it in EventCopy.knownEventTypes }
        if (!unknown.isNullOrEmpty()) {
            throw InvalidSettings("unknown event type(s): ${unknown.joinToString()}")
        }

        val current = forUser(userId)
        val nextNeutral = neutralLockscreen ?: current.neutralLockscreen
        val nextDigest = if (deliverDigestHoursSet) deliverDigestHours else current.deliverDigestHours
        val nextMuted = mutedTypes ?: current.mutedTypes

        dsl.query(
            """
            INSERT INTO notification_settings (user_id, neutral_lockscreen, deliver_digest_hours, muted_types)
            VALUES ({0}, {1}, {2}, {3})
            ON CONFLICT (user_id) DO UPDATE
                SET neutral_lockscreen = {1}, deliver_digest_hours = {2}, muted_types = {3}
            """.trimIndent(),
            userId, nextNeutral, nextDigest, nextMuted.toTypedArray(),
        ).execute()

        return forUser(userId)
    }
}
