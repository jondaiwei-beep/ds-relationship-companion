package com.dsapp.backend.activation.application

import com.dsapp.backend.activation.domain.DesiredOutcome
import com.dsapp.backend.activation.domain.StarterContent
import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.RoleContext
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import com.dsapp.backend.today.application.DynamicDays
import com.dsapp.backend.today.application.OccurrenceGenerator
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
 * The default is exactly **1 Ritual + 1 Expectation**. A second Expectation
 * exists only as a suggestion the creator may add. Both land as `tasks`.
 */
@Service
class StarterRhythmService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
    private val generator: OccurrenceGenerator,
    private val days: DynamicDays,
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

    data class Started(val ritualTaskId: UUID, val expectationTaskId: UUID)

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
     * "Start this rhythm" — two recurring daily tasks (the ritual at a local
     * wall-clock time, the expectation by end of relationship day). The
     * creator may override any title before starting.
     *
     * Idempotent by construction: a Dynamic that already has tasks is left
     * alone, so a double-tap cannot produce two starting rhythms.
     */
    @Transactional
    fun start(
        actorUserId: UUID,
        dynamicId: UUID,
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

        val ritualId = insertTask(dynamicId, ritualTitle ?: ritual.title, ritual.purpose, ritualLocalTime, actorUserId, 1)
        val expectationId = insertTask(dynamicId, expectationTitle ?: expectation.title, expectation.purpose, null, actorUserId, 2)
        if (includeSecondExpectation) {
            val second = StarterContent.optionalSecondExpectation(outcome, apart)
            insertTask(dynamicId, second.title, second.purpose, null, actorUserId, 3)
        }
        // Today exists from the first minute, not from the next tick.
        generator.generate(dynamicId, days.today(dynamicId))

        events.append(
            ctx.dynamicId, actorUserId, "starter_rhythm_started",
            """{"ritual_task_id":"$ritualId","expectation_task_id":"$expectationId"}""",
        )
        return Started(ritualId, expectationId)
    }

    private fun alreadyStarted(dynamicId: UUID): Boolean =
        dsl.fetchOne("SELECT 1 FROM tasks WHERE dynamic_id = {0} LIMIT 1", dynamicId) != null

    private fun outcomeOf(dynamicId: UUID): DesiredOutcome {
        val raw = dsl.fetchOne(
            "SELECT desired_outcome FROM dynamics WHERE id = {0}", dynamicId,
        )!!.get("desired_outcome", String::class.java)
        return runCatching { DesiredOutcome.valueOf(raw) }.getOrDefault(DesiredOutcome.CLOSER)
    }

    private fun apartOf(dynamicId: UUID): Boolean = dsl.fetchOne(
        "SELECT long_distance FROM dynamics WHERE id = {0}", dynamicId,
    )!!.get("long_distance", Boolean::class.java)

    private fun insertTask(
        dynamicId: UUID, title: String, purpose: String, dueTime: LocalTime?, creator: UUID, position: Int,
    ): UUID {
        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO tasks (id, dynamic_id, title, detail, kind, schedule, due_time, created_by, status, position)
            VALUES ({0}, {1}, {2}, {3}, 'recurring', '{"type":"daily"}'::jsonb, {4}, {5}, 'active', {6})
            """.trimIndent(),
            id, dynamicId, title, purpose, dueTime, creator, position,
        ).execute()
        return id
    }
}
