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
        /** When the receiving person said they had seen it. */
        val receivedAt: Instant? = null,
        val acknowledgement: AcknowledgementView?,
        /**
         * The other person in this dynamic, by name.
         *
         * The client had been hardcoding "Your partner", so every screen in
         * the loop addressed a workflow role rather than a human being. A
         * name is what makes an open loop about this pair.
         */
        val partnerDisplayName: String?,
        /**
         * What the person who completed this wrote for themselves.
         *
         * Null for everyone else — including their partner — and null when
         * nothing was written. It was previously stored and never read back
         * at all, so a private note could be written and then never seen
         * again, by anyone.
         */
        val privateNote: String?,
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
            SELECT o.id, o.state, o.due_at, o.received_at, d.title, d.purpose,
                   c.completed_at,
                   -- Only to the person who wrote it. The design labels this
                   -- "PRIVATE NOTE · ONLY YOU", and the filter is here rather
                   -- than in the caller so no future reader can forget it.
                   CASE WHEN c.actor_user_id = {1} THEN c.note END AS private_note,
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
            receivedAt = r.get("received_at", Instant::class.java),
            partnerDisplayName = r.get("partner_name", String::class.java),
            privateNote = r.get("private_note", String::class.java),
            acknowledgement = ackSentAt?.let {
                AcknowledgementView(
                    type = r.get("ack_type", String::class.java),
                    text = r.get("ack_text", String::class.java),
                    sentAt = it,
                    senderDisplayName = r.get("ack_sender", String::class.java),
                )
            },
            allowedActions = AllowedActions.forOccurrence(
                state, ctx.role, ctx.mayMutate,
                received = r.get("received_at", Instant::class.java) != null,
            ),
        )
    }
}
