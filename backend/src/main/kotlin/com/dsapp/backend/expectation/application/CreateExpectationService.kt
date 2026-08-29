package com.dsapp.backend.expectation.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.RoleContext
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import com.dsapp.backend.shared.time.RelationshipDay
import java.time.Instant
import java.time.ZoneId
import java.util.UUID

/**
 * Creates one basic Expectation and its first Occurrence.
 *
 * M1 scope: `kind = TASK`, no recurrence. Ritual recurrence and Check-in arrive
 * in Milestone 2 (Notion 06 §13.3) — the slice deliberately runs on ONE basic
 * Expectation so the human-response loop is proven before the engine grows.
 */
@Service
class CreateExpectationService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {
    data class Created(val definitionId: UUID, val occurrenceId: UUID)

    @Transactional
    fun create(
        actorUserId: UUID,
        dynamicId: UUID,
        title: String,
        purpose: String?,
        assigneeUserId: UUID,
        dueAt: Instant?,
    ): Created {
        authorizer.requireSetUp(
            authorizer.contextForDynamic(actorUserId, dynamicId),
            RoleContext.CREATOR,
        )

        // The relationship day MUST come from the Dynamic's own timezone and
        // day boundary. CURRENT_DATE would use the database server's date,
        // which is the classic wrong-day defect (Notion 07 §9, S1 blocker).
        val tz = dsl.fetchOne(
            "SELECT reference_timezone, day_boundary_minutes FROM dynamics WHERE id = {0}",
            dynamicId,
        )!!
        val relationshipDay = RelationshipDay.dayOf(
            instant = dueAt ?: Instant.now(),
            zone = ZoneId.of(tz.get("reference_timezone", String::class.java)),
            boundaryMinutes = tz.get("day_boundary_minutes", Int::class.java),
        )

        val definitionId = UUID.randomUUID()
        val occurrenceId = UUID.randomUUID()

        dsl.query(
            """
            INSERT INTO expectation_definitions
                (id, dynamic_id, kind, title, purpose, creator_user_id, assignee_user_id, visibility)
            VALUES ({0}, {1}, 'TASK', {2}, {3}, {4}, {5}, 'SHARED')
            """.trimIndent(),
            definitionId, dynamicId, title, purpose, actorUserId, assigneeUserId,
        ).execute()

        // M1 activates immediately so the slice can run without the scheduler.
        // Milestone 2 replaces this with day-boundary-aware generation.
        dsl.query(
            """
            INSERT INTO occurrences (id, definition_id, dynamic_id, state, relationship_day, due_at)
            VALUES ({0}, {1}, {2}, 'ACTIVE', {3}, {4})
            """.trimIndent(),
            occurrenceId, definitionId, dynamicId, relationshipDay, dueAt,
        ).execute()

        events.append(
            dynamicId, actorUserId, "occurrence_activated",
            """{"definition_id":"$definitionId","occurrence_id":"$occurrenceId"}""",
        )
        events.enqueueOutbox("occurrence", occurrenceId, "occurrence_activated", "activated:$occurrenceId")
        return Created(definitionId, occurrenceId)
    }
}
