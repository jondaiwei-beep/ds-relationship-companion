package com.dsapp.backend.expectation.application

import com.dsapp.backend.dynamic.domain.RoleContext

/**
 * What a person may do with an Occurrence right now.
 *
 * REQ-STATE-001 puts this on the server: "entitlement" is one of the four
 * things a client must never derive. It lives in its own object because two
 * read models answer with it — the Occurrence detail and Today — and a second
 * copy of these rules would drift. Today used to offer all four partner
 * actions unconditionally, so a partner looking at an expectation they had
 * asked to discuss was shown Complete / Discuss / New time / Can't do when the
 * only thing they could actually do was withdraw the request.
 */
object AllowedActions {
    fun forOccurrence(
        state: String,
        role: RoleContext,
        mayMutate: Boolean,
        received: Boolean = true,
    ): List<String> {
        if (!mayMutate) return emptyList()
        // Receiving comes before everything else on the receiving side. Offered
        // only while unreceived; completing without receiving is still allowed
        // — the action is a courtesy of the dynamic, not a gate.
        val receive = if (!received && role == RoleContext.PARTNER &&
            state in setOf("ACTIVE", "NEEDS_REVIEW")) listOf("receive") else emptyList()
        return receive + when (state) {
            // Adjustment is always offered alongside completion — it is a normal
            // path, not a failure (red line #3, Notion 02 §5).
            "ACTIVE" -> if (role == RoleContext.PARTNER) {
                listOf("complete", "discuss", "reschedule", "cant_do")
            } else emptyList()
            "WAITING_ACK" -> if (role == RoleContext.CREATOR) {
                listOf("acknowledge", "praise", "comment")
            } else emptyList()
            // An open adjustment awaits the OTHER person's answer. Journey D
            // fixes the vocabulary: Continue / Adjust / Reschedule / Excuse /
            // Cancel — never "approve" or "reject", which would frame asking
            // as a request for permission.
            "NEED_TO_DISCUSS", "RESCHEDULE_REQUESTED", "EXCUSE_REQUESTED" ->
                if (role == RoleContext.CREATOR) {
                    listOf("continue", "adjust", "reschedule", "excuse", "cancel")
                } else listOf("withdraw")
            // Past due is only ever a prompt to look, never a penalty.
            "NEEDS_REVIEW" -> if (role == RoleContext.PARTNER) {
                listOf("complete", "discuss", "reschedule", "cant_do")
            } else listOf("review", "excuse", "reschedule")
            else -> emptyList()
        }
    }
}
