package com.dsapp.backend.today.application

import com.fasterxml.jackson.annotation.JsonProperty
import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.points.application.PointsService
import org.jooq.DSLContext
import org.jooq.Record
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.math.BigDecimal
import java.time.Instant
import java.time.LocalDate
import java.util.UUID

/**
 * The 今天 tab, both faces (product/04-screens.md). One payload; the client
 * picks the face from `side`. Reading today also makes sure today exists —
 * the scheduler is a convenience, not a dependency.
 */
@Service
class TodayQueryService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val days: DynamicDays,
    private val generator: OccurrenceGenerator,
    private val closer: DayCloser,
    private val points: PointsService,
) {
    data class ConsequenceView(val id: UUID, val title: String, val detail: String?, val status: String, val issuedAt: Instant)

    data class OccurrenceView(
        val id: UUID,
        val taskId: UUID,
        val title: String,
        val detail: String?,
        val kind: String,
        val proof: String,
        val pointsEarn: Int,
        val requiresDPresent: Boolean,
        val day: LocalDate,
        val slot: Int,
        val dueAt: Instant?,
        val outcome: String,
        val outcomeAt: Instant?,
        val outcomeNote: String?,
        val proofKind: String?,
        val proofRef: String?,
        val proposedTime: Instant?,
        val value: BigDecimal?,
        val unit: String?,
        val disposition: String,
        val dispositionAt: Instant?,
        val dispositionNote: String?,
        val consequence: ConsequenceView?,
        val makeUpDay: LocalDate?,
        val makeUpOf: UUID?,
        val seenAt: Instant?,
        val version: Int,
    )

    data class OpenTaskView(val id: UUID, val title: String, val detail: String?, val proof: String, val pointsEarn: Int)

    data class TodayView(
        val dynamicId: UUID,
        val mode: String,
        val day: LocalDate,
        val timezone: String,
        val dayBoundaryMinutes: Int,
        val side: String,
        val items: List<OccurrenceView>,
        val openTasks: List<OpenTaskView>,
        /** The s side's balance — the number both faces show. */
        val balance: Int,
        val daysTogether: Int,
        /** D face: things said by the s that the D has not yet answered, all days. */
        val needsMe: Int,
        val partnerDisplayName: String?,
        /** D「我不在」until this instant, or null when the D is present. */
        @get:JsonProperty("dAwayUntil") val dAwayUntil: Instant?,
        /** How the s addresses the D, and vice versa. Null means "use the display name". */
        val honorificForD: String?,
        val honorificForS: String?,
        val safeword: String?,
    )

    @Transactional
    fun today(actorUserId: UUID, dynamicId: UUID, requested: LocalDate? = null): TodayView {
        val ctx = authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        val settings = days.settings(dynamicId)
        val today = settings.dayOf(Instant.now())
        val day = requested ?: today
        if (day == today && ctx.mayMutate) {
            generator.generate(dynamicId, today)
            closer.closeBefore(dynamicId, today)
        }
        val items = fetchItems("o.dynamic_id = {0} AND o.day = {1} ORDER BY o.due_at NULLS LAST, t.position, o.slot", dynamicId, day)
        val openTasks = dsl.fetch(
            "SELECT id, title, detail, proof, points_earn FROM tasks WHERE dynamic_id = {0} AND kind = 'open' AND status = 'active' ORDER BY position",
            dynamicId,
        ).map { OpenTaskView(it.get("id", UUID::class.java), it.get("title", String::class.java), it.get("detail", String::class.java), it.get("proof", String::class.java), it.get("points_earn", Int::class.java)) }
        val sUser = sSideUser(dynamicId) ?: actorUserId
        val partner = dsl.fetchOne(
            """SELECT u.display_name FROM memberships m JOIN users u ON u.id = m.user_id
                WHERE m.dynamic_id = {0} AND m.user_id <> {1} AND m.access_state = 'ACTIVE' LIMIT 1""",
            dynamicId, actorUserId,
        )?.get("display_name", String::class.java)
        val extras = dsl.fetchOne(
            "SELECT mode, d_away_until, honorific_for_d, honorific_for_s, safeword FROM dynamics WHERE id = {0}",
            dynamicId,
        )
        return TodayView(
            dynamicId = dynamicId,
            mode = extras?.get("mode", String::class.java) ?: "SOLO",
            day = day,
            timezone = settings.zone.id,
            dayBoundaryMinutes = settings.boundaryMinutes,
            side = ctx.side.name,
            items = items,
            openTasks = openTasks,
            balance = points.balanceOf(dynamicId, sUser),
            daysTogether = points.daysTogether(actorUserId, dynamicId),
            needsMe = dsl.fetchOne(
                "SELECT count(*) AS n FROM occurrences WHERE dynamic_id = {0} AND outcome NOT IN ('open','paused') AND disposition = 'none'",
                dynamicId,
            )!!.get("n", Int::class.java),
            partnerDisplayName = partner,
            dAwayUntil = extras?.get("d_away_until", Instant::class.java),
            honorificForD = extras?.get("honorific_for_d", String::class.java),
            honorificForS = extras?.get("honorific_for_s", String::class.java),
            safeword = extras?.get("safeword", String::class.java),
        )
    }

    /** D face list: everything the s has said that has no answer yet, oldest first. */
    @Transactional(readOnly = true)
    fun needsMe(actorUserId: UUID, dynamicId: UUID, limit: Int = 50): List<OccurrenceView> {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        return fetchItems(
            "o.dynamic_id = {0} AND o.outcome NOT IN ('open','paused') AND o.disposition = 'none' ORDER BY o.outcome_at NULLS LAST, o.day LIMIT {1}",
            dynamicId, limit,
        )
    }

    @Transactional(readOnly = true)
    fun occurrence(actorUserId: UUID, occurrenceId: UUID): OccurrenceView {
        authorizer.requireRead(authorizer.contextForOccurrence(actorUserId, occurrenceId))
        return fetchItems("o.id = {0}", occurrenceId).firstOrNull() ?: throw NoSuchItem()
    }

    private fun fetchItems(where: String, vararg args: Any): List<OccurrenceView> = dsl.fetch(
        """
        SELECT o.*, t.title, t.detail, t.kind, t.proof, t.points_earn, t.requires_d_present, t.unit,
               c.title AS c_title, c.detail AS c_detail, c.status AS c_status, c.issued_at AS c_issued_at
          FROM occurrences o
          JOIN tasks t ON t.id = o.task_id
          LEFT JOIN consequences c ON c.id = o.consequence_id
         WHERE $where
        """.trimIndent(),
        *args,
    ).map(::view)

    private fun sSideUser(dynamicId: UUID): UUID? = dsl.fetchOne(
        "SELECT user_id FROM memberships WHERE dynamic_id = {0} AND side = 'S' AND access_state = 'ACTIVE' LIMIT 1", dynamicId,
    )?.get("user_id", UUID::class.java)

    private fun view(r: Record): OccurrenceView {
        val cid = r.get("consequence_id", UUID::class.java)
        return OccurrenceView(
            id = r.get("id", UUID::class.java),
            taskId = r.get("task_id", UUID::class.java),
            title = r.get("title", String::class.java),
            detail = r.get("detail", String::class.java),
            kind = r.get("kind", String::class.java),
            proof = r.get("proof", String::class.java),
            pointsEarn = r.get("points_earn", Int::class.java),
            requiresDPresent = r.get("requires_d_present", Boolean::class.java),
            day = r.get("day", LocalDate::class.java),
            slot = r.get("slot", Int::class.java),
            dueAt = r.get("due_at", Instant::class.java),
            outcome = r.get("outcome", String::class.java),
            outcomeAt = r.get("outcome_at", Instant::class.java),
            outcomeNote = r.get("outcome_note", String::class.java),
            proofKind = r.get("proof_kind", String::class.java),
            proofRef = r.get("proof_ref", String::class.java),
            proposedTime = r.get("proposed_time", Instant::class.java),
            value = r.get("value", BigDecimal::class.java),
            unit = r.get("unit", String::class.java),
            disposition = r.get("disposition", String::class.java),
            dispositionAt = r.get("disposition_at", Instant::class.java),
            dispositionNote = r.get("disposition_note", String::class.java),
            consequence = cid?.let {
                ConsequenceView(it, r.get("c_title", String::class.java), r.get("c_detail", String::class.java),
                    r.get("c_status", String::class.java), r.get("c_issued_at", Instant::class.java))
            },
            makeUpDay = r.get("make_up_day", LocalDate::class.java),
            makeUpOf = r.get("make_up_of", UUID::class.java),
            seenAt = r.get("seen_at", Instant::class.java),
            version = r.get("version", Int::class.java),
        )
    }
}
