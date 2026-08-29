package com.dsapp.backend.identity

import com.dsapp.backend.identity.application.NotificationSettingsService
import org.jooq.DSLContext
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull

/** A member's own notification settings — Notion 04 §5. */
@SpringBootTest
@ActiveProfiles("test")
class NotificationSettingsIT {

    @Autowired lateinit var dsl: DSLContext
    @Autowired lateinit var settings: NotificationSettingsService

    private lateinit var me: UUID
    private lateinit var other: UUID

    @BeforeEach
    fun seed() {
        me = UUID.randomUUID()
        other = UUID.randomUUID()
        for (id in listOf(me, other)) {
            dsl.query(
                "INSERT INTO users (id, email, timezone) VALUES ({0}, {1}, {2})",
                id, "$id@test.local", "Asia/Shanghai",
            ).execute()
        }
    }

    @Test
    fun `a new member is neutral by default and has no quiet hours`() {
        val s = settings.forUser(me)
        // Red line #5: privacy never widens implicitly, so the safe value is
        // the default rather than something the user must go and switch on.
        assertEquals("NEUTRAL", s.notificationPreview)
        assertNull(s.quietHoursStartMin)
        assertNull(s.quietHoursEndMin)
    }

    @Test
    fun `quiet hours can be set and cleared`() {
        val set = settings.update(me, null, 22 * 60, 7 * 60)
        assertEquals(22 * 60, set.quietHoursStartMin)
        assertEquals(7 * 60, set.quietHoursEndMin)

        // Clearing is explicit: passing neither bound turns the window off,
        // rather than leaving a stale one silently in force.
        val cleared = settings.update(me, null, null, null)
        assertNull(cleared.quietHoursStartMin)
        assertNull(cleared.quietHoursEndMin)
    }

    @Test
    fun `half a window is refused`() {
        // A start with no end would suppress nothing while looking set.
        assertFailsWith<NotificationSettingsService.InvalidSettings> {
            settings.update(me, null, 22 * 60, null)
        }
        assertFailsWith<NotificationSettingsService.InvalidSettings> {
            settings.update(me, null, null, 7 * 60)
        }
    }

    @Test
    fun `a zero-length window is refused rather than guessed`() {
        // It reads as both "never quiet" and "always quiet". Guessing wrong
        // means a notification at 3am, or none ever.
        assertFailsWith<NotificationSettingsService.InvalidSettings> {
            settings.update(me, null, 22 * 60, 22 * 60)
        }
    }

    @Test
    fun `preview richness is limited to the two known values`() {
        assertEquals("RICH", settings.update(me, "RICH", null, null).notificationPreview)
        assertFailsWith<NotificationSettingsService.InvalidSettings> {
            settings.update(me, "EVERYTHING", null, null)
        }
    }

    @Test
    fun `changing my settings never touches anyone else`() {
        settings.update(me, "RICH", 22 * 60, 7 * 60)

        // Settings belong to the User, and the caller's id comes from the JWT
        // — there is no shape of request that reaches another person's.
        val theirs = settings.forUser(other)
        assertEquals("NEUTRAL", theirs.notificationPreview)
        assertNull(theirs.quietHoursStartMin)
    }
}
