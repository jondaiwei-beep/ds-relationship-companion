package com.dsapp.backend.expectation

import com.dsapp.backend.expectation.domain.OccurrenceState
import com.dsapp.backend.expectation.domain.OccurrenceTransition
import org.junit.jupiter.api.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/**
 * The legal transition graph — closes OPEN_SPEC_GAPS G-3.
 *
 * The forbidden edges matter more than the allowed ones: each one is a product
 * decision about what the system may claim happened.
 */
class OccurrenceTransitionTest {

    @Test
    fun `NEED_TO_DISCUSS can NEVER jump straight to WAITING_ACK`() {
        // WAITING_ACK means a Completion exists. Allowing this edge would
        // manufacture a completion that never happened — the same class of lie
        // as auto-generating partner praise (red line #1/#2).
        assertFalse(OccurrenceTransition.isLegal(
            OccurrenceState.NEED_TO_DISCUSS, OccurrenceState.WAITING_ACK))
        // Resolving a discussion returns to ACTIVE; the person completes for real.
        assertTrue(OccurrenceTransition.isLegal(
            OccurrenceState.NEED_TO_DISCUSS, OccurrenceState.ACTIVE))
    }

    @Test
    fun `NEEDS_REVIEW can NEVER jump straight to ACKNOWLEDGED`() {
        assertFalse(OccurrenceTransition.isLegal(
            OccurrenceState.NEEDS_REVIEW, OccurrenceState.ACKNOWLEDGED))
        // A late completion is still a real completion.
        assertTrue(OccurrenceTransition.isLegal(
            OccurrenceState.NEEDS_REVIEW, OccurrenceState.WAITING_ACK))
    }

    @Test
    fun `WAITING_ACK can NEVER become REVIEWED`() {
        // Otherwise "reviewed" could masquerade as "someone responded to you".
        assertFalse(OccurrenceTransition.isLegal(
            OccurrenceState.WAITING_ACK, OccurrenceState.REVIEWED))
        assertTrue(OccurrenceTransition.isLegal(
            OccurrenceState.WAITING_ACK, OccurrenceState.ACKNOWLEDGED))
    }

    @Test
    fun `overdue leads only to NEEDS_REVIEW - never to anything punitive`() {
        // Red line #3. ACTIVE and SCHEDULED are the only states an overdue
        // sweep touches, and NEEDS_REVIEW is the only destination.
        assertTrue(OccurrenceTransition.isLegal(
            OccurrenceState.ACTIVE, OccurrenceState.NEEDS_REVIEW))
        assertTrue(OccurrenceTransition.isLegal(
            OccurrenceState.SCHEDULED, OccurrenceState.NEEDS_REVIEW))
    }

    @Test
    fun `terminal states admit nothing further`() {
        for (t in OccurrenceTransition.TERMINAL) {
            assertTrue(OccurrenceTransition.allowedFrom(t).isEmpty(), "$t should be terminal")
        }
    }

    @Test
    fun `NEED_TO_DISCUSS is deliberately NOT terminal`() {
        // An open discussion must still block a duplicate occurrence for the
        // same definition and day (matches the V1 partial unique index).
        assertFalse(OccurrenceState.NEED_TO_DISCUSS in OccurrenceTransition.TERMINAL)
        assertTrue(OccurrenceTransition.allowedFrom(OccurrenceState.NEED_TO_DISCUSS).isNotEmpty())
    }

    @Test
    fun `every adjustment state resolves the same way`() {
        val expected = setOf(OccurrenceState.ACTIVE, OccurrenceState.EXCUSED, OccurrenceState.CANCELLED)
        for (s in OccurrenceTransition.AWAITING_RESOLUTION) {
            assertTrue(OccurrenceTransition.allowedFrom(s).containsAll(expected),
                "$s must support Continue/Adjust, Excuse and Cancel/Reschedule")
        }
    }

    @Test
    fun `a rescheduled original is distinguishable from a plain cancellation`() {
        assertTrue(OccurrenceTransition.isRescheduledAway(OccurrenceState.CANCELLED, hasReplacement = true))
        assertFalse(OccurrenceTransition.isRescheduledAway(OccurrenceState.CANCELLED, hasReplacement = false))
    }
}
