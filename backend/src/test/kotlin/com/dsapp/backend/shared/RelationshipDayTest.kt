package com.dsapp.backend.shared

import com.dsapp.backend.shared.time.RelationshipDay
import org.junit.jupiter.api.Test
import java.time.Duration
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneId
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/**
 * Relationship-day and DST correctness.
 *
 * Notion 07 §9 classes a wrong relationship day as an **S1 release blocker**,
 * so these are not edge-case curiosities — they are the gate.
 *
 * Pure functions with no database and no JVM default zone.
 */
class RelationshipDayTest {

    private val ny = ZoneId.of("America/New_York")
    private val shanghai = ZoneId.of("Asia/Shanghai")
    private val london = ZoneId.of("Europe/London")
    private val lordHowe = ZoneId.of("Australia/Lord_Howe")
    private val phoenix = ZoneId.of("America/Phoenix")   // no DST

    // ---- day boundary ----

    @Test
    fun `with a 4am boundary, 2am belongs to the PREVIOUS relationship day`() {
        // The couple is still in "Tuesday night" at 02:00 on Wednesday.
        val at2am = LocalDateTime.of(2026, 3, 4, 2, 0).atZone(shanghai).toInstant()
        assertEquals(LocalDate.of(2026, 3, 3), RelationshipDay.dayOf(at2am, shanghai, 240))
    }

    @Test
    fun `exactly at the boundary the new day begins`() {
        val at4am = LocalDateTime.of(2026, 3, 4, 4, 0).atZone(shanghai).toInstant()
        assertEquals(LocalDate.of(2026, 3, 4), RelationshipDay.dayOf(at4am, shanghai, 240))
    }

    @Test
    fun `a zero boundary is plain midnight`() {
        val justAfter = LocalDateTime.of(2026, 3, 4, 0, 1).atZone(shanghai).toInstant()
        assertEquals(LocalDate.of(2026, 3, 4), RelationshipDay.dayOf(justAfter, shanghai, 0))
    }

    // ---- DST gap (spring forward) ----

    @Test
    fun `a local time inside the spring gap shifts forward by the real gap`() {
        // 2026-03-08 02:30 does not exist in New York.
        val resolved = RelationshipDay.resolve(LocalDateTime.of(2026, 3, 8, 2, 30), ny)
        assertEquals(
            LocalDateTime.of(2026, 3, 8, 3, 30).atZone(ny).toInstant(), resolved,
            "a nonexistent local time must land at 03:30 EDT, not be silently dropped",
        )
    }

    @Test
    fun `Lord Howe has a THIRTY minute gap - never hardcode one hour`() {
        // 2026-10-04 02:15 does not exist; the gap is 30 minutes, not 60.
        val resolved = RelationshipDay.resolve(LocalDateTime.of(2026, 10, 4, 2, 15), lordHowe)
        val expected = LocalDateTime.of(2026, 10, 4, 2, 45).atZone(lordHowe).toInstant()
        assertEquals(expected, resolved)
    }

    @Test
    fun `a day boundary inside the gap still yields a usable day start`() {
        val range = RelationshipDay.rangeOf(LocalDate.of(2026, 3, 8), ny, 150) // 02:30
        assertEquals(
            LocalDateTime.of(2026, 3, 8, 3, 30).atZone(ny).toInstant(), range.start,
        )
    }

    // ---- DST fold (fall back) ----

    @Test
    fun `an ambiguous local time takes the FIRST occurrence, so a ritual fires once`() {
        // 2026-11-01 01:30 happens twice in New York.
        val resolved = RelationshipDay.resolve(LocalDateTime.of(2026, 11, 1, 1, 30), ny)
        // The first pass is still EDT (-04:00) => 05:30Z.
        assertEquals(Instant.parse("2026-11-01T05:30:00Z"), resolved)
    }

    // ---- day length ----

    @Test
    fun `a spring-forward relationship day is 23 hours`() {
        // The transition is at 02:00 on 03-08. With a 04:00 boundary that
        // moment sits inside the day that STARTED on 03-07, so 03-07 is the
        // short one. Getting this off by a day is precisely the wrong-day
        // defect Notion 07 §9 blocks a release on.
        assertEquals(
            Duration.ofHours(23),
            RelationshipDay.lengthOf(LocalDate.of(2026, 3, 7), ny, 240),
        )
        // At a midnight boundary the short day is 03-08 itself.
        assertEquals(
            Duration.ofHours(23),
            RelationshipDay.lengthOf(LocalDate.of(2026, 3, 8), ny, 0),
        )
    }

    @Test
    fun `a fall-back relationship day is 25 hours`() {
        assertEquals(
            Duration.ofHours(25),
            RelationshipDay.lengthOf(LocalDate.of(2026, 10, 31), ny, 240),
        )
        assertEquals(
            Duration.ofHours(25),
            RelationshipDay.lengthOf(LocalDate.of(2026, 11, 1), ny, 0),
        )
    }

    @Test
    fun `an ordinary day is 24 hours`() {
        assertEquals(
            Duration.ofHours(24),
            RelationshipDay.lengthOf(LocalDate.of(2026, 6, 15), ny, 240),
        )
    }

    // ---- wall-clock preservation ----

    @Test
    fun `a ritual at 2030 stays at 2030 local across DST, though its UTC time moves`() {
        val before = RelationshipDay.resolve(LocalDateTime.of(2026, 3, 1, 20, 30), ny)
        val after = RelationshipDay.resolve(LocalDateTime.of(2026, 3, 15, 20, 30), ny)

        // Same wall clock for the human...
        assertEquals(20, before.atZone(ny).hour)
        assertEquals(20, after.atZone(ny).hour)
        // ...but a different UTC instant, which is exactly why storing a bare
        // UTC offset would be wrong (Notion 04 §9).
        assertEquals(1, before.atZone(ZoneId.of("UTC")).hour - after.atZone(ZoneId.of("UTC")).hour)
    }

    // ---- zones without DST ----

    @Test
    fun `a zone without DST behaves identically all year`() {
        for (month in listOf(1, 3, 6, 11)) {
            assertEquals(
                Duration.ofHours(24),
                RelationshipDay.lengthOf(LocalDate.of(2026, month, 15), phoenix, 240),
            )
        }
    }

    // ---- skipped calendar dates ----

    @Test
    fun `a date that does not exist in a zone is detectable`() {
        // Samoa skipped 2011-12-30 entirely when it crossed the date line.
        val apia = ZoneId.of("Pacific/Apia")
        assertFalse(RelationshipDay.dateExists(LocalDate.of(2011, 12, 30), apia))
        assertTrue(RelationshipDay.dateExists(LocalDate.of(2011, 12, 31), apia))
    }

    // ---- environment independence ----

    @Test
    fun `results never depend on the JVM default timezone`() {
        val instant = Instant.parse("2026-03-04T18:00:00Z")
        val original = java.util.TimeZone.getDefault()
        val seen = mutableSetOf<LocalDate>()
        try {
            for (tz in listOf("UTC", "America/Los_Angeles", "Asia/Tokyo", "Europe/London")) {
                java.util.TimeZone.setDefault(java.util.TimeZone.getTimeZone(tz))
                seen += RelationshipDay.dayOf(instant, ny, 240)
            }
        } finally {
            java.util.TimeZone.setDefault(original)
        }
        assertEquals(1, seen.size, "the JVM default zone must never influence the result")
    }

    // ---- the required matrix (Notion 07 §6) ----

    @Test
    fun `the required timezone matrix all resolve consistently`() {
        // LA, NY, London, plus a non-DST zone; both 00:00 and 04:00 boundaries.
        val zones = listOf(ZoneId.of("America/Los_Angeles"), ny, london, phoenix)
        for (zone in zones) {
            for (boundary in listOf(0, 240)) {
                val day = LocalDate.of(2026, 6, 15)
                val range = RelationshipDay.rangeOf(day, zone, boundary)
                assertTrue(range.start < range.endInclusive, "$zone/$boundary produced an empty day")
                // A moment inside the range must classify back to the same day.
                val mid = range.start.plus(Duration.ofHours(6))
                assertEquals(day, RelationshipDay.dayOf(mid, zone, boundary), "$zone/$boundary")
            }
        }
    }
}
