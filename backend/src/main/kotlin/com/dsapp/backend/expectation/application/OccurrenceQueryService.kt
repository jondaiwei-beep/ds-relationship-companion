package com.dsapp.backend.expectation.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.RoleContext
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/**
 * Authoritative read of an Occurrence.
 *
 * Notion 03 §8: the client takes current business state from here. It never
 * derives `missed` / `acknowledged` from timestamps or local cache.
 */
@Service
class OccurrenceQueryService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
) {
    data class AcknowledgementView(
        val type: String,
        val text: String,
        val sentAt: Instant,
        /** Always a real person. The system never authors this (red line #1). */
        val senderDisplayName: String?,
    )

    data class OccurrenceView(
        val id: UUID,
        val title: String,
        val purpose: String?,
        val state: String,
        val dueAt: Instant?,
        val completedAt: Instant?,
        val acknowledgement: AcknowledgementView?,
        /**
         * The other person in this dynamic, by name.
         *
         * The client had been hardcoding "Your partner", so every screen in
         * the loop addressed a workflow role rather than a human being. A
         * name is what makes an open loop about this pair.
         */
        val partnerDisplayName: String?,
        /** UX convenience only — the command endpoint still authorizes. */
        val allowedActions: List<String>,
    )

    @Transactional(readOnly = true)
    fun get(actorUserId: UUID, occurrenceId: UUID): OccurrenceView {
        val ctx = authorizer.requireRead(
            authorizer.contextForOccurrence(actorUserId, occurrenceId),
        )

        val r = dsl.fetchOne(
            """
            SELECT o.id, o.state, o.due_at, d.title, d.purpose,
                   c.completed_at,
                   a.type AS ack_type, a.text AS ack_text, a.sent_at AS ack_sent_at,
                   au.display_name AS ack_sender,
                   (SELECT u.display_name
                      FROM memberships m
                      JOIN users u ON u.id = m.user_id
                     WHERE m.dynamic_id = o.dynamic_id
                       AND m.user_id <> {1}
                       AND m.access_state = 'ACTIVE'
                     LIMIT 1) AS partner_name
              FROM occurrences o
              JOIN expectation_definitions d ON d.id = o.definition_id
              LEFT JOIN occurrence_completions c ON c.occurrence_id = o.id
              LEFT JOIN acknowledgements a ON a.occurrence_id = o.id
              LEFT JOIN users au ON au.id = a.sender_user_id
             WHERE o.id = {0}
            """.trimIndent(),
            occurrenceId, actorUserId,
        )!!

        val state = r.get("state", String::class.java)
        val ackSentAt = r.get("ack_sent_at", Instant::class.java)

        return OccurrenceView(
            id = r.get("id", UUID::class.java),
            title = r.get("title", String::class.java),
            purpose = r.get("purpose", String::class.java),
            state = state,
            dueAt = r.get("due_at", Instant::class.java),
            completedAt = r.get("completed_at", Instant::class.java),
            partnerDisplayName = r.get("partner_name", String::class.java),
            acknowledgement = ackSentAt?.let {
                AcknowledgementView(
                    type = r.get("ack_type", String::class.java),
                    text = r.get("ack_text", String::class.java),
                    sentAt = it,
                    senderDisplayName = r.get("ack_sender", String::class.java),
                )
            },
            allowedActions = allowedActions(state, ctx.role, ctx.mayMutate),
        )
    }

    private fun allowedActions(state: String, role: RoleContext, mayMutate: Boolean): List<String> {
        if (!mayMutate) return emptyList()
        return when (state) {
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
