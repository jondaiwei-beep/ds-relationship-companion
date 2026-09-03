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
 * Consequence lifecycle (product/03-domain.md §Consequence):
 * `issued -> done_by_s -> confirmed` or `issued -> waived`.
 *
 * The consequence itself is only ever created by [DispositionService] when a
 * D disposes `punished` — `issued_by` is NOT NULL there and nothing here can
 * create one. This service only advances a consequence someone already
 * issued: the s marks it done, the D confirms or waives it. No scheduler
 * touches this table (invariant 2).
 */
@Service
class ConsequenceLifecycleService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {
    data class ConsequenceView(
        val id: UUID,
        val dynamicId: UUID,
        val issuedBy: UUID,
        val title: String,
        val detail: String?,
        val status: String,
        val issuedAt: Instant,
        val doneAt: Instant?,
        val decidedAt: Instant?,
    )

    /** s marks a consequence they were issued as done. */
    @Transactional
    fun done(actorUserId: UUID, consequenceId: UUID): ConsequenceView {
        val ctx = authorizer.requireSide(authorizer.contextForConsequence(actorUserId, consequenceId), Side.S)
        val n = dsl.query(
            "UPDATE consequences SET status = 'done_by_s', done_at = now() WHERE id = {0} AND status = 'issued'",
            consequenceId,
        ).execute()
        if (n == 0) throw TaskNotActionable("CONSEQUENCE_NOT_ISSUED")
        events.append(ctx.dynamicId, actorUserId, "consequence_done", """{"consequence_id":"$consequenceId"}""")
        events.enqueueOutbox("consequence", consequenceId, "consequence_done", "consequence_done:$consequenceId")
        return get(ctx.dynamicId, consequenceId)
    }

    /** D confirms it was carried out. */
    @Transactional
    fun confirm(actorUserId: UUID, consequenceId: UUID): ConsequenceView = decide(actorUserId, consequenceId, "confirmed")

    /** D lets it go — mercy is a thing a person does, shown as prominently as a confirm. */
    @Transactional
    fun waive(actorUserId: UUID, consequenceId: UUID): ConsequenceView = decide(actorUserId, consequenceId, "waived")

    /** Either `issued` or `done_by_s` may be confirmed or waived — the D need not wait for the s to mark it done first. */
    private fun decide(actorUserId: UUID, consequenceId: UUID, to: String): ConsequenceView {
        val ctx = authorizer.requireSide(authorizer.contextForConsequence(actorUserId, consequenceId), Side.D)
        val n = dsl.query(
            """UPDATE consequences SET status = {1}, decided_at = now()
                WHERE id = {0} AND status IN ('issued', 'done_by_s')""",
            consequenceId, to,
        ).execute()
        if (n == 0) throw TaskNotActionable("CONSEQUENCE_NOT_DECIDABLE")
        events.append(ctx.dynamicId, actorUserId, "consequence_decided", """{"consequence_id":"$consequenceId","status":"$to"}""")
        events.enqueueOutbox("consequence", consequenceId, "consequence_decided", "consequence_decided:$consequenceId")
        return get(ctx.dynamicId, consequenceId)
    }

    @Transactional(readOnly = true)
    fun list(actorUserId: UUID, dynamicId: UUID, status: String? = null): List<ConsequenceView> {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        return dsl.fetch(
            """
            SELECT * FROM consequences
             WHERE dynamic_id = {0} AND (CAST({1} AS text) IS NULL OR status = {1})
             ORDER BY issued_at DESC
            """.trimIndent(),
            dynamicId, status,
        ).map(::view)
    }

    fun get(dynamicId: UUID, consequenceId: UUID): ConsequenceView =
        dsl.fetchOne("SELECT * FROM consequences WHERE id = {0} AND dynamic_id = {1}", consequenceId, dynamicId)
            ?.let(::view) ?: throw NoSuchItem()

    private fun view(r: org.jooq.Record): ConsequenceView = ConsequenceView(
        id = r.get("id", UUID::class.java),
        dynamicId = r.get("dynamic_id", UUID::class.java),
        issuedBy = r.get("issued_by", UUID::class.java),
        title = r.get("title", String::class.java),
        detail = r.get("detail", String::class.java),
        status = r.get("status", String::class.java),
        issuedAt = r.get("issued_at", Instant::class.java),
        doneAt = r.get("done_at", Instant::class.java),
        decidedAt = r.get("decided_at", Instant::class.java),
    )
}
