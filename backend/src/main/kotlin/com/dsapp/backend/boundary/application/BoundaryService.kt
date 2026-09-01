package com.dsapp.backend.boundary.application

import com.dsapp.backend.dynamic.domain.AuthorizationException
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/** Writing over someone else's limit is the one thing this feature cannot allow. */
class NotTheAuthor(val boundaryId: UUID) :
    RuntimeException("Only the person who wrote this boundary may change it")

/** Named separately from NotAMember so a member's stale id is not a 404 on the Dynamic. */
class NoSuchBoundary(val boundaryId: UUID) :
    RuntimeException("No boundary $boundaryId in this dynamic")

/**
 * Boundaries lite — REQ-ACT-002.
 *
 * The requirement said minimal setup collects "Couple/Solo, starting role
 * preset, structure level and boundaries lite". Only the first three were
 * built. For a product defined as a companion for consensual adult D/s
 * couples, that omission is not a missing nice-to-have: an expectation only
 * means something against a stated background of what is not on the table,
 * and the app was asking people to give and receive direction without ever
 * having asked that question.
 *
 * ## Whose list it is
 *
 * A boundary belongs to the person who wrote it. Both members can READ both
 * lists — the whole point is that the other person knows — but only the
 * author may write, change or delete their own. This is red line #4 (agency
 * no role can remove) in the one place where violating it would be most
 * damaging: if the member giving direction could edit the limits of the
 * member receiving it, the feature would become a tool for exactly the harm
 * it exists to prevent. It is enforced here rather than in the UI so that no
 * client bug can breach it.
 *
 * ## Why there is no intensity number
 *
 * Three unranked stances: OFF (not this), ASK (talk to me first), CURIOUS
 * (open to discussing it). A 1–10 scale would be a compliance score wearing a
 * different hat, and 00-overview lists compliance scoring as a non-goal. It
 * would also be false precision about something people are usually still
 * working out.
 *
 * ## What this is not
 *
 * Not a contract and not a consent certificate — 00-overview forbids treating
 * one as the other. It is a shared note two people keep, which is why editing
 * is ordinary and nothing here is ever locked.
 */
@Service
class BoundaryService(private val dsl: DSLContext) {

    enum class Stance { OFF, ASK, CURIOUS }

    data class Boundary(
        val id: UUID,
        val userId: UUID,
        val label: String,
        val stance: Stance,
        val note: String?,
        val mine: Boolean,
        val updatedAt: Instant,
    )

    /**
     * Everything both members have written, the viewer's own included.
     *
     * Ordered so the viewer's list comes first and OFF before ASK before
     * CURIOUS — the firmest thing said is the thing read first.
     */
    fun list(actorUserId: UUID, dynamicId: UUID): List<Boundary> {
        requireMember(actorUserId, dynamicId)
        return dsl.fetch(
            """
            SELECT id, user_id, label, stance, note, updated_at
              FROM boundaries
             WHERE dynamic_id = {0}
             ORDER BY (user_id = {1}) DESC,
                      CASE stance WHEN 'OFF' THEN 0 WHEN 'ASK' THEN 1 ELSE 2 END,
                      lower(label)
            """.trimIndent(),
            dynamicId, actorUserId,
        ).map { r ->
            val owner = r.get("user_id", UUID::class.java)
            Boundary(
                id = r.get("id", UUID::class.java),
                userId = owner,
                label = r.get("label", String::class.java),
                stance = Stance.valueOf(r.get("stance", String::class.java)),
                note = r.get("note", String::class.java),
                mine = owner == actorUserId,
                updatedAt = r.get("updated_at", Instant::class.java),
            )
        }
    }

    /**
     * Adds one, or updates the stance and note if this person already named
     * the same thing.
     *
     * Upsert rather than a 409: someone revisiting a limit they already wrote
     * is the expected case, not an error, and making them delete first would
     * be a worse way to say "you have changed your mind".
     */
    @Transactional
    fun add(
        actorUserId: UUID,
        dynamicId: UUID,
        label: String,
        stance: Stance,
        note: String?,
    ): UUID {
        requireMember(actorUserId, dynamicId)

        val trimmed = label.trim()
        require(trimmed.isNotEmpty() && trimmed.length <= 120) { "label" }
        val cleanNote = note?.trim()?.takeIf { it.isNotEmpty() }
        require(cleanNote == null || cleanNote.length <= 500) { "note" }

        val existing = dsl.fetch(
            """
            SELECT id FROM boundaries
             WHERE dynamic_id = {0} AND user_id = {1} AND lower(label) = lower({2})
            """.trimIndent(),
            dynamicId, actorUserId, trimmed,
        ).firstOrNull()?.get("id", UUID::class.java)

        if (existing != null) {
            dsl.query(
                """
                UPDATE boundaries
                   SET stance = {0}, note = {1}, label = {2}, updated_at = now()
                 WHERE id = {3}
                """.trimIndent(),
                stance.name, cleanNote, trimmed, existing,
            ).execute()
            return existing
        }

        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO boundaries (id, dynamic_id, user_id, label, stance, note)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5})
            """.trimIndent(),
            id, dynamicId, actorUserId, trimmed, stance.name, cleanNote,
        ).execute()
        return id
    }

    /**
     * Removes one of the caller's own.
     *
     * Deleted outright rather than tombstoned. A limit someone has withdrawn
     * should not linger anywhere the other person can still read it — keeping
     * the history would make retracting a limit feel like a matter of record,
     * which is the opposite of the message.
     */
    @Transactional
    fun remove(actorUserId: UUID, dynamicId: UUID, boundaryId: UUID) {
        requireMember(actorUserId, dynamicId)

        val owner = dsl.fetch(
            "SELECT user_id FROM boundaries WHERE id = {0} AND dynamic_id = {1}",
            boundaryId, dynamicId,
        ).firstOrNull()?.get("user_id", UUID::class.java)
            ?: throw NoSuchBoundary(boundaryId)

        if (owner != actorUserId) throw NotTheAuthor(boundaryId)

        dsl.query("DELETE FROM boundaries WHERE id = {0}", boundaryId).execute()
    }

    /**
     * Membership, not role. Both members read and write their own here, and
     * a non-member is answered as though the Dynamic does not exist.
     */
    private fun requireMember(actorUserId: UUID, dynamicId: UUID) {
        val ok = dsl.fetch(
            """
            SELECT 1 FROM memberships
             WHERE dynamic_id = {0} AND user_id = {1} AND access_state = 'ACTIVE'
            """.trimIndent(),
            dynamicId, actorUserId,
        ).isNotEmpty
        if (!ok) throw AuthorizationException.NotAMember()
    }
}
