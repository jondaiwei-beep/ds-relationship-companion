package com.dsapp.backend.expectation.domain

/**
 * Occurrence lifecycle — Notion 03 §2.
 *
 * The server is the sole authority for this value (Notion 03 §8). Clients never
 * derive it from timestamps or local cache.
 */
enum class OccurrenceState {
    SCHEDULED,
    ACTIVE,

    /**
     * A Completion exists; awaiting a human Acknowledgement.
     *
     * Invariant: Completion != Acknowledgement. These never collapse
     * into one state, and only an explicit human Send advances past this.
     */
    WAITING_ACK,
    ACKNOWLEDGED,

    /**
     * Past due. Invariant: this is the ONLY destination for an
     * overdue occurrence. Never punishment, never a consequence.
     */
    NEEDS_REVIEW,
    REVIEWED,

    // Adjustment side paths. Invariant: none of these is a "miss".
    NEED_TO_DISCUSS,
    RESCHEDULE_REQUESTED,
    EXCUSE_REQUESTED,
    EXCUSED,
    CANCELLED;

    /**
     * Terminal states admit no further transition.
     *
     * NOTE (OPEN_SPEC_GAPS G-3): the full legal transition graph is not yet
     * specified in Notion 03. NEED_TO_DISCUSS is deliberately NOT terminal here —
     * a discussion should be able to resolve back onto an active path. The V1
     * uniqueness index currently disagrees; reconcile when G-3 is resolved.
     */
    val isTerminal: Boolean
        get() = this in setOf(ACKNOWLEDGED, REVIEWED, EXCUSED, CANCELLED)
}
