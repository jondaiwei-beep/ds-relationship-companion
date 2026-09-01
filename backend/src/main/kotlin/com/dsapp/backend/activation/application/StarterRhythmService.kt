package com.dsapp.backend.activation.application

import com.dsapp.backend.activation.domain.DesiredOutcome
import com.dsapp.backend.activation.domain.StarterContent
import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.RoleContext
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalTime
import java.util.UUID

/**
 * Starter Rhythm — Notion 02 §A3, 05 §4.
 *
 * "Here's a starting rhythm. Keep what feels right. Replace anything that
 * doesn't." The point is to answer *how do we begin* before the couple has to
 * learn any software, and to do it without the first day arriving already full.
 *
 * The default is exactly **1 Ritual + 1 Expectation + 1 Check-in framing**. A
 * second Expectation exists only as a suggestion the creator may add.
 */
@Service
class StarterRhythmService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {
    data class Proposed(
        val ritualTitle: String,
        val ritualPurpose: String,
        val expectationTitle: String,
        val expectationPurpose: String,
        val checkInFraming: String,
        /** Offered, not included. The creator opts in. */
        val optionalSecondTitle: String,
        val optionalSecondPurpose: String,
    )

    data class Started(
        val ritualDefinitionId: UUID,
        val expectationDefinitionId: UUID,
        val recurrenceId: UUID,
    )

    /** What we would suggest — nothing is written yet. */
    @Transactional(readOnly = true)
    fun propose(actorUserId: UUID, dynamicId: UUID): Proposed {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        val outcome = outcomeOf(dynamicId)
        val apart = apartOf(dynamicId)

        val ritual = StarterContent.ritualFor(outcome, apart)
        val expectation = StarterContent.expectationFor(outcome, apart)
        val second = StarterContent.optionalSecondExpectation(outcome, apart)

        return Proposed(
            ritualTitle = ritual.title,
            ritualPurpose = ritual.purpose,
            expectationTitle = expectation.title,
            expectationPurpose = expectation.purpose,
            // Rotating the framing keeps the first check-in from feeling like a form.
            checkInFraming = StarterContent.checkInFramings[
                dynamicId.hashCode().mod(StarterContent.checkInFramings.size)
            ],
            optionalSecondTitle = second.title,
            optionalSecondPurpose = second.purpose,
        )
    }

    /**
     * "Start this rhythm" — creates the Ritual (with recurrence) and the
     * Expectation. The creator may override any title before starting.
     *
     * Idempotent by construction: a Dynamic that already has definitions is
     * left alone, so a double-tap cannot produce two starting rhythms.
     */
    @Transactional
    fun start(
        actorUserId: UUID,
        dynamicId: UUID,
        assigneeUserId: UUID,
        ritualTitle: String? = null,
        expectationTitle: String? = null,
        ritualLocalTime: LocalTime = LocalTime.of(20, 30),
        includeSecondExpectation: Boolean = false,
    ): Started {
        // Setup rights: a COUPLE dynamic is still PENDING_PARTNER at this point.
        val ctx = authorizer.requireSetUp(
            authorizer.contextForDynamic(actorUserId, dynamicId), RoleContext.CREATOR,
        )
        check(!alreadyStarted(dynamicId)) { "this dynamic already has a rhythm" }

        val outcome = outcomeOf(dynamicId)
        val apart = apartOf(dynamicId)
        val ritual = StarterContent.ritualFor(outcome, apart)
        val expectation = StarterContent.expectationFor(outcome, apart)

        val ritualId = insertDefinition(
            dynamicId, "RITUAL", ritualTitle ?: ritual.title, ritual.purpose,
            actorUserId, assigneeUserId,
        )
        val expectationId = insertDefinition(
            dynamicId, "TASK", expectationTitle ?: expectation.title, expectation.purpose,
            actorUserId, assigneeUserId,
        )

        // The Ritual recurs daily at a local wall-clock time in the Dynamic's
        // own zone (Notion 04 §9 — never a bare UTC offset).
        val timezone = dsl.fetchOne(
            "SELECT reference_timezone FROM dynamics WHERE id = {0}", dynamicId,
        )!!.get("reference_timezone", String::class.java)

        val recurrenceId = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO expectation_recurrences
                (id, definition_id, frequency, local_time, timezone)
            VALUES ({0}, {1}, 'DAILY', {2}, {3})
            """.trimIndent(),
            recurrenceId, ritualId, ritualLocalTime, timezone,
        ).execute()

        if (includeSecondExpectation) {
            val second = StarterContent.optionalSecondExpectation(outcome, apart)
            insertDefinition(dynamicId, "TASK", second.title, second.purpose,
                actorUserId, assigneeUserId)
        }

        events.append(
            ctx.dynamicId, actorUserId, "starter_rhythm_started",
            """{"ritual_definition_id":"$ritualId","expectation_definition_id":"$expectationId"}""",
        )
        return Started(ritualId, expectationId, recurrenceId)
    }

    private fun alreadyStarted(dynamicId: UUID): Boolean =
        dsl.fetchOne(
            "SELECT 1 FROM expectation_definitions WHERE dynamic_id = {0} LIMIT 1", dynamicId,
        ) != null

    private fun outcomeOf(dynamicId: UUID): DesiredOutcome {
        val raw = dsl.fetchOne(
            "SELECT desired_outcome FROM dynamics WHERE id = {0}", dynamicId,
        )!!.get("desired_outcome", String::class.java)
        return runCatching { DesiredOutcome.valueOf(raw) }.getOrDefault(DesiredOutcome.CLOSER)
    }

    private fun apartOf(dynamicId: UUID): Boolean = dsl.fetchOne(
        "SELECT long_distance FROM dynamics WHERE id = {0}", dynamicId,
    )!!.get("long_distance", Boolean::class.java)

    private fun insertDefinition(
        dynamicId: UUID, kind: String, title: String, purpose: String,
        creator: UUID, assignee: UUID,
    ): UUID {
        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO expectation_definitions
                (id, dynamic_id, kind, title, purpose, creator_user_id, assignee_user_id, visibility)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, 'SHARED')
            """.trimIndent(),
            id, dynamicId, kind, title, purpose, creator, assignee,
        ).execute()
        return id
    }
}
