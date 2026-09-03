package com.dsapp.backend.response.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.expectation.domain.OccurrenceState
import com.dsapp.backend.expectation.domain.OccurrenceTransition
import com.dsapp.backend.shared.time.RelationshipDay
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.time.ZoneId
import java.util.UUID

/** What the person is asking for. None of these is a Miss. */
enum class AdjustmentType { DISCUSS, RESCHEDULE, CANT_DO }

/** How the partner answers. */
enum class AdjustmentResolution { CONTINUE, ADJUST, RESCHEDULE, EXCUSE, CANCEL }

class AdjustmentNotPossible(val state: String) :
    RuntimeException("Occurrence is $state; no adjustment can be requested")

class NoOpenAdjustment(val occurrenceId: UUID) :
    RuntimeException("No open adjustment on $occurrenceId")

/** Only the person who asked may take the request back. */
class NotTheRequester(val occurrenceId: UUID) :
    RuntimeException("Only the requester may withdraw the adjustment on $occurrenceId")

/**
 * The adjustment path — Journey D (Notion 02 §5).
 *
 * This is the feature that makes the product survive real life. Asking to
 * discuss, to move something, or to say "not today" must be as ordinary as
 * completing — never a confession.
 *
 * NOTE ON ROLES: requesting an adjustment deliberately does NOT require a
 * particular role. Notion 04 §4 lists these as agency no role can disable, so
 * any active member of the dynamic may ask.
 */
@Service
class AdjustmentService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {
    data class Requested(val adjustmentId: UUID, val occurrenceState: String)
    data class Resolved(val occurrenceState: String, val replacementOccurrenceId: UUID?)
    data class Withdrawn(val occurrenceState: String)

    @Transactional
    fun request(
        actorUserId: UUID,
        occurrenceId: UUID,
        type: AdjustmentType,
        note: String?,
        requestedAt: Instant? = null,
        idempotencyId: UUID,
    ): Requested {
        // Any ACTIVE member may ask — this is agency, not a role privilege.
        val ctx = authorizer.requireRead(
            authorizer.contextForOccurrence(actorUserId, occurrenceId),
        )

        val target = when (type) {
            AdjustmentType.DISCUSS -> OccurrenceState.NEED_TO_DISCUSS
            AdjustmentType.RESCHEDULE -> OccurrenceState.RESCHEDULE_REQUESTED
            AdjustmentType.CANT_DO -> OccurrenceState.EXCUSE_REQUESTED
        }

        // Guarded transition. Legal only from ACTIVE (an occurrence in flight);
        // the graph is the authority on what may follow what.
        val moved = dsl.fetchOne(
            """
            UPDATE occurrences
               SET state = {1}, version = version + 1, updated_at = now()
             WHERE id = {0} AND state = 'ACTIVE'
            RETURNING id, state
            """.trimIndent(),
            occurrenceId, target.name,
        ) ?: throw AdjustmentNotPossible(currentState(occurrenceId))

        val adjustmentId = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO adjustment_requests
                (id, occurrence_id, requester_user_id, type, note, requested_at_time, status)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5}, 'OPEN')
            """.trimIndent(),
            adjustmentId, occurrenceId, actorUserId, type.name, note, requestedAt,
        ).execute()

        events.append(
            ctx.dynamicId, actorUserId, "adjustment_requested",
            """{"occurrence_id":"$occurrenceId","adjustment_id":"$adjustmentId"}""",
        )
        events.enqueueOutbox(
            "occurrence", occurrenceId, "adjustment_requested", "adjustment:$adjustmentId",
        )
        return Requested(adjustmentId, moved.get("state", String::class.java))
    }

    /**
     * The partner answers. Resolution decides where the occurrence lands.
     *
     * RESCHEDULE is the subtle one: the ORIGINAL occurrence is stored as
     * CANCELLED (there is no RESCHEDULED state) and a NEW occurrence is created
     * on the requested relationship day. History is never rewritten
     * (Notion 03 §4) — the original row stays, linked to its replacement.
     */
    @Transactional
    fun resolve(
        actorUserId: UUID,
        occurrenceId: UUID,
        resolution: AdjustmentResolution,
        note: String?,
        newTime: Instant? = null,
        idempotencyId: UUID,
    ): Resolved {
        val ctx = authorizer.requireRead(
            authorizer.contextForOccurrence(actorUserId, occurrenceId),
        )

        val open = dsl.fetchOne(
            "SELECT id FROM adjustment_requests WHERE occurrence_id = {0} AND status = 'OPEN'",
            occurrenceId,
        ) ?: throw NoOpenAdjustment(occurrenceId)
        val adjustmentId = open.get("id", UUID::class.java)

        val target = when (resolution) {
            // Continue and Adjust both return to the active path. The person
            // then completes for real — resolving a discussion must never
            // manufacture a Completion that did not happen.
            AdjustmentResolution.CONTINUE, AdjustmentResolution.ADJUST -> OccurrenceState.ACTIVE
            AdjustmentResolution.EXCUSE -> OccurrenceState.EXCUSED
            AdjustmentResolution.RESCHEDULE, AdjustmentResolution.CANCEL -> OccurrenceState.CANCELLED
        }

        val from = OccurrenceState.valueOf(currentState(occurrenceId))
        require(OccurrenceTransition.isLegal(from, target)) {
            "illegal transition $from -> $target"
        }

        dsl.query(
            """
            UPDATE occurrences SET state = {1}, version = version + 1, updated_at = now()
             WHERE id = {0} AND state = {2}
            """.trimIndent(),
            occurrenceId, target.name, from.name,
        ).execute()

        var replacement: UUID? = null
        if (resolution == AdjustmentResolution.RESCHEDULE) {
            replacement = createReplacement(occurrenceId, ctx.dynamicId, newTime)
        }

        dsl.query(
            """
            UPDATE adjustment_requests
               SET status = 'RESOLVED', resolution = {1}, resolver_user_id = {2},
                   resolution_note = {3}, replacement_occurrence_id = {4},
                   resolved_at = now()
             WHERE id = {0}
            """.trimIndent(),
            adjustmentId, resolution.name, actorUserId, note, replacement,
        ).execute()

        events.append(
            ctx.dynamicId, actorUserId, "adjustment_resolved",
            """{"occurrence_id":"$occurrenceId","adjustment_id":"$adjustmentId"}""",
        )
        events.enqueueOutbox(
            "occurrence", occurrenceId, "adjustment_resolved", "adjustment-resolved:$adjustmentId",
        )
        return Resolved(target.name, replacement)
    }

    /**
     * Take your own request back — the fifth verb.
     *
     * `AllowedActions` has advertised `withdraw` to the person who asked all
     * along, and nothing implemented it, so a NEED_TO_DISCUSS item was a dead
     * end for its own author: visible on Attention and Today, with no way out
     * that did not require the other person to act first.
     *
     * Deliberately not a sixth `AdjustmentResolution`. Journey D's vocabulary
     * is how the OTHER person answers, and it is chosen to avoid framing a
     * request as needing permission. Withdrawing is not an answer to a
     * request; it is the request ending because the person who made it no
     * longer needs it. So it writes `WITHDRAWN` — a status the schema has
     * always allowed and nothing has ever set — with no resolution and no
     * resolver, because nobody resolved anything.
     *
     * Only the requester may do it. Letting the other person withdraw it for
     * them would be exactly the "reject" this vocabulary exists to prevent.
     */
    @Transactional
    fun withdraw(
        actorUserId: UUID,
        occurrenceId: UUID,
    ): Withdrawn {
        val ctx = authorizer.requireRead(
            authorizer.contextForOccurrence(actorUserId, occurrenceId),
        )

        val open = dsl.fetchOne(
            """SELECT id, requester_user_id FROM adjustment_requests
                WHERE occurrence_id = {0} AND status = 'OPEN'""",
            occurrenceId,
        ) ?: throw NoOpenAdjustment(occurrenceId)

        val adjustmentId = open.get("id", UUID::class.java)
        if (open.get("requester_user_id", UUID::class.java) != actorUserId) {
            throw NotTheRequester(occurrenceId)
        }

        // Back to where it was before asking. The work itself was never in
        // question — only whether it needed talking about first.
        val from = OccurrenceState.valueOf(currentState(occurrenceId))
        val target = OccurrenceState.ACTIVE
        require(OccurrenceTransition.isLegal(from, target)) {
            "illegal transition $from -> $target"
        }

        dsl.query(
            """
            UPDATE occurrences SET state = {1}, version = version + 1, updated_at = now()
             WHERE id = {0} AND state = {2}
            """.trimIndent(),
            occurrenceId, target.name, from.name,
        ).execute()

        dsl.query(
            """
            UPDATE adjustment_requests
               SET status = 'WITHDRAWN', resolved_at = now()
             WHERE id = {0} AND status = 'OPEN'
            """.trimIndent(),
            adjustmentId,
        ).execute()

        // A withdrawal is a real thing a person did, so it belongs in the
        // timeline — but it is not `adjustment_resolved`, which would credit
        // the pair with working something out that never got discussed.
        events.append(
            ctx.dynamicId, actorUserId, "adjustment_withdrawn",
            """{"occurrence_id":"$occurrenceId","adjustment_id":"$adjustmentId"}""",
        )
        events.enqueueOutbox(
            "occurrence", occurrenceId, "adjustment_withdrawn",
            "adjustment-withdrawn:$adjustmentId",
        )
        return Withdrawn(target.name)
    }

    /**
     * A new occurrence on the requested day.
     *
     * The original is left in place: rescheduling moves the work, it does not
     * erase the record that it was once expected (Notion 03 §4).
     */
    private fun createReplacement(originalId: UUID, dynamicId: UUID, newTime: Instant?): UUID {
        val orig = dsl.fetchOne(
            "SELECT definition_id FROM occurrences WHERE id = {0}", originalId,
        )!!
        val tz = dsl.fetchOne(
            "SELECT reference_timezone, day_boundary_minutes FROM dynamics WHERE id = {0}",
            dynamicId,
        )!!
        // The relationship day comes from the Dynamic's own zone and boundary,
        // never the server's date.
        val day = RelationshipDay.dayOf(
            instant = newTime ?: Instant.now(),
            zone = ZoneId.of(tz.get("reference_timezone", String::class.java)),
            boundaryMinutes = tz.get("day_boundary_minutes", Int::class.java),
        )

        val newId = UUID.randomUUID()
        // The original is now CANCELLED (terminal), so the partial unique index
        // on non-terminal occurrences per definition/day does not conflict —
        // even when rescheduling within the same day.
        dsl.query(
            """
            INSERT INTO occurrences (id, definition_id, dynamic_id, state, relationship_day, due_at)
            VALUES ({0}, {1}, {2}, 'ACTIVE', {3}, {4})
            """.trimIndent(),
            newId, orig.get("definition_id", UUID::class.java), dynamicId, day, newTime,
        ).execute()
        return newId
    }

    private fun currentState(occurrenceId: UUID): String =
        dsl.fetchOne("SELECT state FROM occurrences WHERE id = {0}", occurrenceId)!!
            .get("state", String::class.java)
}
