package com.dsapp.backend.today.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.Side
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/**
 * The D's own side of the day: things to remember, optionally with a
 * reminder. Private to the author — the s never sees these (invariant 7).
 * "add something for the D to do/to remember/to remind" (Obedience review).
 */
@Service
class DNoteService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {
    data class Note(val id: UUID, val body: String, val remindAt: Instant?, val remindedAt: Instant?, val doneAt: Instant?, val createdAt: Instant)

    @Transactional
    fun create(actorUserId: UUID, dynamicId: UUID, body: String, remindAt: Instant?): Note {
        authorizer.requireSide(authorizer.contextForDynamic(actorUserId, dynamicId), Side.D)
        require(body.isNotBlank() && body.length <= 1000) { "body" }
        val id = UUID.randomUUID()
        dsl.query(
            "INSERT INTO d_notes (id, dynamic_id, author_id, body, remind_at) VALUES ({0}, {1}, {2}, {3}, {4})",
            id, dynamicId, actorUserId, body.trim(), remindAt,
        ).execute()
        return get(actorUserId, id)
    }

    @Transactional(readOnly = true)
    fun list(actorUserId: UUID, dynamicId: UUID, includeDone: Boolean = false): List<Note> {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        return dsl.fetch(
            """
            SELECT * FROM d_notes WHERE dynamic_id = {0} AND author_id = {1} AND ({2} OR done_at IS NULL)
             ORDER BY done_at NULLS FIRST, remind_at NULLS LAST, created_at
            """.trimIndent(),
            dynamicId, actorUserId, includeDone,
        ).map(::view)
    }

    @Transactional
    fun done(actorUserId: UUID, noteId: UUID): Note {
        val n = dsl.query(
            "UPDATE d_notes SET done_at = COALESCE(done_at, now()) WHERE id = {0} AND author_id = {1}", noteId, actorUserId,
        ).execute()
        if (n == 0) throw NoSuchItem()
        return get(actorUserId, noteId)
    }

    @Transactional
    fun delete(actorUserId: UUID, noteId: UUID) {
        if (dsl.query("DELETE FROM d_notes WHERE id = {0} AND author_id = {1}", noteId, actorUserId).execute() == 0) throw NoSuchItem()
    }

    /** Called by the tick. One outbox row per note, to its author only. */
    @Transactional
    fun fireDueReminders(now: Instant = Instant.now()): Int {
        val due = dsl.fetch(
            """
            UPDATE d_notes SET reminded_at = {0}
             WHERE remind_at IS NOT NULL AND remind_at <= {0} AND reminded_at IS NULL AND done_at IS NULL
            RETURNING id
            """.trimIndent(),
            now,
        ).map { it.get("id", UUID::class.java) }
        for (id in due) events.enqueueOutbox("d_note", id, "d_note_reminder", "dnote:$id")
        return due.size
    }

    private fun get(actorUserId: UUID, id: UUID): Note =
        dsl.fetchOne("SELECT * FROM d_notes WHERE id = {0} AND author_id = {1}", id, actorUserId)?.let(::view) ?: throw NoSuchItem()

    private fun view(r: org.jooq.Record) = Note(
        r.get("id", UUID::class.java), r.get("body", String::class.java),
        r.get("remind_at", Instant::class.java), r.get("reminded_at", Instant::class.java),
        r.get("done_at", Instant::class.java), r.get("created_at", Instant::class.java),
    )
}
