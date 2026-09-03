package com.dsapp.backend.record.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import com.dsapp.backend.today.application.NoSuchItem
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.time.LocalDate
import java.util.UUID

/**
 * `DayComment` (product/03-domain.md): a line either side can leave on a
 * relationship day — a plea, a note about the punishment, a single line.
 * Both sides may write; both sides see it; nobody may edit it, only delete
 * their own, and the delete leaves a trace (`deleted_at`) rather than
 * disappearing without one.
 */
@Service
class DayCommentService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {
    data class Comment(val id: UUID, val dynamicId: UUID, val day: LocalDate, val authorId: UUID, val body: String, val createdAt: Instant)

    @Transactional
    fun add(actorUserId: UUID, dynamicId: UUID, day: LocalDate, body: String): Comment {
        authorizer.requireActive(authorizer.contextForDynamic(actorUserId, dynamicId))
        val trimmed = body.trim()
        require(trimmed.isNotEmpty() && trimmed.length <= 2000) { "body" }

        val id = UUID.randomUUID()
        val row = dsl.fetchOne(
            """
            INSERT INTO day_comments (id, dynamic_id, day, author_id, body)
            VALUES ({0}, {1}, {2}, {3}, {4})
            RETURNING created_at
            """.trimIndent(),
            id, dynamicId, day, actorUserId, trimmed,
        )!!
        val createdAt = row.get("created_at", Instant::class.java)

        events.append(dynamicId, actorUserId, "day_comment_added", """{"comment_id":"$id","day":"$day"}""")
        events.enqueueOutbox("day_comment", id, "day_comment", "comment:$id")

        return Comment(id, dynamicId, day, actorUserId, trimmed, createdAt)
    }

    /** Own comments only — soft delete, so the trail stays. */
    @Transactional
    fun delete(actorUserId: UUID, commentId: UUID) {
        val n = dsl.query(
            "UPDATE day_comments SET deleted_at = now() WHERE id = {0} AND author_id = {1} AND deleted_at IS NULL",
            commentId, actorUserId,
        ).execute()
        if (n == 0) throw NoSuchItem()
    }
}
