package com.dsapp.backend.record.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDate
import java.util.UUID

/**
 * `PrivateNote` (product/03-domain.md): one per person per relationship day,
 * seen only by its author (invariant 8) — never returned to the other member,
 * never in any outbox payload. One row per (dynamic, day, author) — the
 * unique index in V18 makes a second `upsert` overwrite the first rather than
 * create a duplicate.
 */
@Service
class PrivateNoteService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
) {
    /** Empty body deletes the note for that day rather than storing a blank row. */
    @Transactional
    fun upsert(actorUserId: UUID, dynamicId: UUID, day: LocalDate, body: String): String? {
        authorizer.requireActive(authorizer.contextForDynamic(actorUserId, dynamicId))
        val trimmed = body.trim()
        if (trimmed.isEmpty()) {
            dsl.query(
                "DELETE FROM private_notes WHERE dynamic_id = {0} AND day = {1} AND author_id = {2}",
                dynamicId, day, actorUserId,
            ).execute()
            return null
        }
        require(trimmed.length <= 5000) { "body" }
        dsl.query(
            """
            INSERT INTO private_notes (id, dynamic_id, day, author_id, body)
            VALUES ({0}, {1}, {2}, {3}, {4})
            ON CONFLICT (dynamic_id, day, author_id)
            DO UPDATE SET body = EXCLUDED.body, updated_at = now()
            """.trimIndent(),
            UUID.randomUUID(), dynamicId, day, actorUserId, trimmed,
        ).execute()
        return trimmed
    }

    /** The actor's own note for that day only — never the other member's (invariant 8). */
    @Transactional(readOnly = true)
    fun get(actorUserId: UUID, dynamicId: UUID, day: LocalDate): String? {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        return dsl.fetchOne(
            "SELECT body FROM private_notes WHERE dynamic_id = {0} AND day = {1} AND author_id = {2}",
            dynamicId, day, actorUserId,
        )?.get("body", String::class.java)
    }
}
