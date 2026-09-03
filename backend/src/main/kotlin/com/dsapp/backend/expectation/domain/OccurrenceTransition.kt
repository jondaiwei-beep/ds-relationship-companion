package com.dsapp.backend.expectation.domain

/**
 * The complete legal transition graph — closes OPEN_SPEC_GAPS G-3.
 *
 * Notion 03 §2 lists the states but never defined the full graph. This does,
 * and each refusal below is a product decision rather than an oversight:
 *
 * - `NEED_TO_DISCUSS -> WAITING_ACK` is **forbidden**: WAITING_ACK means a
 *   Completion exists. Allowing it would MANUFACTURE a completion that never
 *   happened, which is the same class of lie as auto-generating partner praise.
 *   Resolving a discussion returns to ACTIVE; the person then completes for real.
 *
 * - `NEEDS_REVIEW -> ACKNOWLEDGED` is **forbidden** for the same reason. A late
 *   completion goes NEEDS_REVIEW -> WAITING_ACK, then a human acknowledges.
 *
 * - `WAITING_ACK -> REVIEWED` is **forbidden**: ACKNOWLEDGED means a completed
 *   occurrence received a human response. REVIEWED is reserved for something
 *   overdue that was looked at. Collapsing them would let "reviewed" masquerade
 *   as "someone responded to you".
 *
 * One invariant runs through the whole graph: no path here is a Miss, a
 * failure, or a punishment. Past due leads to NEEDS_REVIEW and nowhere worse.
 */
object OccurrenceTransition {

    /** No further transition is possible from these. */
    val TERMINAL = setOf(
        OccurrenceState.ACKNOWLEDGED,
        OccurrenceState.REVIEWED,
        OccurrenceState.EXCUSED,
        OccurrenceState.CANCELLED,
    )

    /** An adjustment is open and awaiting the partner's response. */
    val AWAITING_RESOLUTION = setOf(
        OccurrenceState.NEED_TO_DISCUSS,
        OccurrenceState.RESCHEDULE_REQUESTED,
        OccurrenceState.EXCUSE_REQUESTED,
    )

    private val graph: Map<OccurrenceState, Set<OccurrenceState>> = mapOf(
        OccurrenceState.SCHEDULED to setOf(
            OccurrenceState.ACTIVE,
            OccurrenceState.NEEDS_REVIEW,   // overdue sweep
            OccurrenceState.CANCELLED,      // withdrawn before it began
        ),
        OccurrenceState.ACTIVE to setOf(
            OccurrenceState.WAITING_ACK,    // a real Completion was inserted
            OccurrenceState.NEEDS_REVIEW,   // passed its due boundary
            OccurrenceState.NEED_TO_DISCUSS,
            OccurrenceState.RESCHEDULE_REQUESTED,
            OccurrenceState.EXCUSE_REQUESTED,
            OccurrenceState.CANCELLED,
        ),
        // All three adjustment states resolve the same way.
        OccurrenceState.NEED_TO_DISCUSS to setOf(
            OccurrenceState.ACTIVE,         // Continue or Adjust
            OccurrenceState.EXCUSED,        // Excuse
            OccurrenceState.CANCELLED,      // Cancel, or Reschedule (see note)
        ),
        OccurrenceState.RESCHEDULE_REQUESTED to setOf(
            OccurrenceState.ACTIVE, OccurrenceState.EXCUSED, OccurrenceState.CANCELLED,
        ),
        OccurrenceState.EXCUSE_REQUESTED to setOf(
            OccurrenceState.ACTIVE, OccurrenceState.EXCUSED, OccurrenceState.CANCELLED,
        ),
        OccurrenceState.NEEDS_REVIEW to setOf(
            OccurrenceState.WAITING_ACK,    // completed late — still a real completion
            OccurrenceState.ACTIVE,         // Continue or Adjust
            OccurrenceState.EXCUSED,
            OccurrenceState.REVIEWED,
            OccurrenceState.CANCELLED,
        ),
        OccurrenceState.WAITING_ACK to setOf(
            OccurrenceState.ACKNOWLEDGED,   // explicit human acknowledgement ONLY
        ),
    )

    fun isLegal(from: OccurrenceState, to: OccurrenceState): Boolean =
        graph[from]?.contains(to) ?: false

    fun allowedFrom(from: OccurrenceState): Set<OccurrenceState> =
        graph[from] ?: emptySet()

    /**
     * Reschedule stores the original as CANCELLED because no RESCHEDULED state
     * exists, but the UI must render it as "Rescheduled to …" from the
     * adjustment's resolution — never as "Cancelled", which would read as a
     * failure the person caused.
     */
    fun isRescheduledAway(state: OccurrenceState, hasReplacement: Boolean): Boolean =
        state == OccurrenceState.CANCELLED && hasReplacement
}
