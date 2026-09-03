package com.dsapp.backend.record.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.today.application.DynamicDays
import com.dsapp.backend.today.application.RelationshipStreaks
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.time.LocalDate
import java.time.YearMonth
import java.util.UUID

/**
 * 记录 — the calendar, the day timeline, plain facts, and the streak numbers
 * (product/02-surfaces.md Tab 3, product/03-domain.md). Everything here is
 * read-only; the writes live in [DayCommentService] and [PrivateNoteService].
 *
 * Privacy (invariant 8): a `PrivateNote` or `DNote` is never returned for
 * anyone but its author. This service never even joins `d_notes` — the day
 * timeline has no D-note kind — and only ever fetches the *actor's own*
 * private note.
 */
@Service
class RecordQueryService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val days: DynamicDays,
    private val streaks: RelationshipStreaks,
) {
    data class MonthCell(
        val day: LocalDate,
        val due: Int,
        val delivered: Int,
        val flagged: Int,
        val missed: Int,
        val undisposed: Int,
        val comments: Int,
        val hasPrivateNote: Boolean,
    )

    data class OutcomeEntry(
        val occurrenceId: UUID, val taskId: UUID, val taskTitle: String,
        val toValue: String, val note: String?, val proofKind: String?, val proofRef: String?,
    )

    data class DispositionEntry(
        val occurrenceId: UUID, val taskId: UUID, val taskTitle: String,
        val toValue: String, val note: String?,
        val consequenceTitle: String?, val makeUpDay: LocalDate?,
    )

    data class CommentEntry(val id: UUID, val authorId: UUID, val body: String)

    data class PointsEntry(val id: UUID, val reason: String, val amount: Int, val note: String?, val actorUserId: UUID?)

    data class RedemptionEntry(val id: UUID, val rewardId: UUID, val rewardTitle: String, val givenByUserId: UUID?, val subjectUserId: UUID)

    /** One timeline entry. Exactly one of the typed payloads is non-null, matching [kind]. */
    data class TimelineEntry(
        val at: Instant,
        val kind: String, // outcome | disposition | comment | points | redemption
        val outcome: OutcomeEntry? = null,
        val disposition: DispositionEntry? = null,
        val comment: CommentEntry? = null,
        val points: PointsEntry? = null,
        val redemption: RedemptionEntry? = null,
    )

    data class DayView(
        val day: LocalDate,
        val timeline: List<TimelineEntry>,
        val comments: List<CommentEntry>,
        val myPrivateNote: String?,
    )

    data class FactsView(
        val from: LocalDate,
        val to: LocalDate,
        val delivered: Int,
        val late: Int,
        val flagged: Int,
        val missed: Int,
        val letGo: Int,
        val praised: Int,
        val madeUp: Int,
        val punished: Int,
        val comments: Int,
        val pointsEarned: Int,
        val pointsDeducted: Int,
        val redemptions: Int,
    )

    data class SummaryView(val daysTogether: Int, val currentStreak: Int)

    @Transactional(readOnly = true)
    fun month(actorUserId: UUID, dynamicId: UUID, month: YearMonth): List<MonthCell> {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        val from = month.atDay(1)
        val to = month.atEndOfMonth()

        val occRows = dsl.fetch(
            """
            SELECT day,
                   count(*) FILTER (WHERE outcome <> 'paused') AS due,
                   count(*) FILTER (WHERE outcome IN ('delivered', 'delivered_late')) AS delivered,
                   count(*) FILTER (WHERE outcome IN ('cant_do', 'new_time_requested', 'discuss_requested')) AS flagged,
                   count(*) FILTER (WHERE outcome = 'missed') AS missed,
                   count(*) FILTER (WHERE outcome NOT IN ('open', 'paused') AND disposition = 'none') AS undisposed
              FROM occurrences
             WHERE dynamic_id = {0} AND day BETWEEN {1} AND {2}
             GROUP BY day
            """.trimIndent(),
            dynamicId, from, to,
        ).associateBy(
            { it.get("day", LocalDate::class.java) },
        ) { it }

        val commentCounts = dsl.fetch(
            """
            SELECT day, count(*) AS n FROM day_comments
             WHERE dynamic_id = {0} AND day BETWEEN {1} AND {2} AND deleted_at IS NULL
             GROUP BY day
            """.trimIndent(),
            dynamicId, from, to,
        ).associate { it.get("day", LocalDate::class.java) to it.get("n", Int::class.java) }

        val privateNoteDays = dsl.fetch(
            "SELECT day FROM private_notes WHERE dynamic_id = {0} AND author_id = {1} AND day BETWEEN {2} AND {3}",
            dynamicId, actorUserId, from, to,
        ).map { it.get("day", LocalDate::class.java) }.toSet()

        val allDays = (occRows.keys + commentCounts.keys + privateNoteDays).sorted()
        return allDays.map { day ->
            val r = occRows[day]
            MonthCell(
                day = day,
                due = r?.get("due", Int::class.java) ?: 0,
                delivered = r?.get("delivered", Int::class.java) ?: 0,
                flagged = r?.get("flagged", Int::class.java) ?: 0,
                missed = r?.get("missed", Int::class.java) ?: 0,
                undisposed = r?.get("undisposed", Int::class.java) ?: 0,
                comments = commentCounts[day] ?: 0,
                hasPrivateNote = day in privateNoteDays,
            )
        }
    }

    @Transactional(readOnly = true)
    fun day(actorUserId: UUID, dynamicId: UUID, day: LocalDate): DayView {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        val range = days.settings(dynamicId).rangeOf(day)

        val entries = mutableListOf<TimelineEntry>()

        // outcome + disposition, from occurrence_history — one row per axis change.
        dsl.fetch(
            """
            SELECT h.at, h.axis, h.to_value, h.note, h.by_user_id,
                   o.id AS occurrence_id, o.task_id, o.proof_kind, o.proof_ref,
                   o.make_up_day, t.title AS task_title,
                   c.title AS consequence_title
              FROM occurrence_history h
              JOIN occurrences o ON o.id = h.occurrence_id
              JOIN tasks t ON t.id = o.task_id
              LEFT JOIN consequences c ON c.id = o.consequence_id
             WHERE o.dynamic_id = {0} AND o.day = {1}
             ORDER BY h.at
            """.trimIndent(),
            dynamicId, day,
        ).forEach { r ->
            val axis = r.get("axis", String::class.java)
            val at = r.get("at", Instant::class.java)
            if (axis == "outcome") {
                entries += TimelineEntry(
                    at = at, kind = "outcome",
                    outcome = OutcomeEntry(
                        occurrenceId = r.get("occurrence_id", UUID::class.java),
                        taskId = r.get("task_id", UUID::class.java),
                        taskTitle = r.get("task_title", String::class.java),
                        toValue = r.get("to_value", String::class.java),
                        note = r.get("note", String::class.java),
                        proofKind = r.get("proof_kind", String::class.java),
                        proofRef = r.get("proof_ref", String::class.java),
                    ),
                )
            } else {
                entries += TimelineEntry(
                    at = at, kind = "disposition",
                    disposition = DispositionEntry(
                        occurrenceId = r.get("occurrence_id", UUID::class.java),
                        taskId = r.get("task_id", UUID::class.java),
                        taskTitle = r.get("task_title", String::class.java),
                        toValue = r.get("to_value", String::class.java),
                        note = r.get("note", String::class.java),
                        consequenceTitle = r.get("consequence_title", String::class.java),
                        makeUpDay = r.get("make_up_day", LocalDate::class.java),
                    ),
                )
            }
        }

        val comments = dsl.fetch(
            "SELECT id, author_id, body, created_at FROM day_comments WHERE dynamic_id = {0} AND day = {1} AND deleted_at IS NULL ORDER BY created_at",
            dynamicId, day,
        ).map {
            val c = CommentEntry(it.get("id", UUID::class.java), it.get("author_id", UUID::class.java), it.get("body", String::class.java))
            entries += TimelineEntry(at = it.get("created_at", Instant::class.java), kind = "comment", comment = c)
            c
        }

        dsl.fetch(
            "SELECT id, reason, amount, note, actor_user_id, created_at FROM point_entries WHERE dynamic_id = {0} AND created_at >= {1} AND created_at < {2} ORDER BY created_at",
            dynamicId, range.start, range.endInclusive,
        ).forEach {
            entries += TimelineEntry(
                at = it.get("created_at", Instant::class.java), kind = "points",
                points = PointsEntry(
                    it.get("id", UUID::class.java), it.get("reason", String::class.java), it.get("amount", Int::class.java),
                    it.get("note", String::class.java), it.get("actor_user_id", UUID::class.java),
                ),
            )
        }

        dsl.fetch(
            """
            SELECT rr.id, rr.reward_id, r.title AS reward_title, rr.given_by_user_id, rr.subject_user_id, rr.created_at
              FROM reward_redemptions rr JOIN rewards r ON r.id = rr.reward_id
             WHERE rr.dynamic_id = {0} AND rr.created_at >= {1} AND rr.created_at < {2}
             ORDER BY rr.created_at
            """.trimIndent(),
            dynamicId, range.start, range.endInclusive,
        ).forEach {
            entries += TimelineEntry(
                at = it.get("created_at", Instant::class.java), kind = "redemption",
                redemption = RedemptionEntry(
                    it.get("id", UUID::class.java), it.get("reward_id", UUID::class.java), it.get("reward_title", String::class.java),
                    it.get("given_by_user_id", UUID::class.java), it.get("subject_user_id", UUID::class.java),
                ),
            )
        }

        entries.sortBy { it.at }

        val myNote = dsl.fetchOne(
            "SELECT body FROM private_notes WHERE dynamic_id = {0} AND day = {1} AND author_id = {2}",
            dynamicId, day, actorUserId,
        )?.get("body", String::class.java)

        return DayView(day = day, timeline = entries, comments = comments, myPrivateNote = myNote)
    }

    @Transactional(readOnly = true)
    fun facts(actorUserId: UUID, dynamicId: UUID, from: LocalDate, to: LocalDate): FactsView {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        require(!to.isBefore(from)) { "to" }
        val range = days.settings(dynamicId).rangeOf(from).start..days.settings(dynamicId).rangeOf(to).endInclusive

        val occ = dsl.fetchOne(
            """
            SELECT
                count(*) FILTER (WHERE outcome = 'delivered') AS delivered,
                count(*) FILTER (WHERE outcome = 'delivered_late') AS late,
                count(*) FILTER (WHERE outcome IN ('cant_do', 'new_time_requested', 'discuss_requested')) AS flagged,
                count(*) FILTER (WHERE outcome = 'missed') AS missed,
                count(*) FILTER (WHERE disposition = 'let_go') AS let_go,
                count(*) FILTER (WHERE disposition = 'praised') AS praised,
                count(*) FILTER (WHERE disposition = 'make_up') AS made_up,
                count(*) FILTER (WHERE disposition = 'punished') AS punished
              FROM occurrences
             WHERE dynamic_id = {0} AND day BETWEEN {1} AND {2}
            """.trimIndent(),
            dynamicId, from, to,
        )!!

        val comments = dsl.fetchOne(
            "SELECT count(*) AS n FROM day_comments WHERE dynamic_id = {0} AND day BETWEEN {1} AND {2} AND deleted_at IS NULL",
            dynamicId, from, to,
        )!!.get("n", Int::class.java)

        val points = dsl.fetchOne(
            """
            SELECT
                COALESCE(SUM(amount) FILTER (WHERE amount > 0), 0) AS earned,
                COALESCE(-SUM(amount) FILTER (WHERE amount < 0), 0) AS deducted
              FROM point_entries
             WHERE dynamic_id = {0} AND created_at >= {1} AND created_at < {2}
            """.trimIndent(),
            dynamicId, range.start, range.endInclusive,
        )!!

        val redemptions = dsl.fetchOne(
            "SELECT count(*) AS n FROM reward_redemptions WHERE dynamic_id = {0} AND created_at >= {1} AND created_at < {2}",
            dynamicId, range.start, range.endInclusive,
        )!!.get("n", Int::class.java)

        return FactsView(
            from = from, to = to,
            delivered = occ.get("delivered", Int::class.java),
            late = occ.get("late", Int::class.java),
            flagged = occ.get("flagged", Int::class.java),
            missed = occ.get("missed", Int::class.java),
            letGo = occ.get("let_go", Int::class.java),
            praised = occ.get("praised", Int::class.java),
            madeUp = occ.get("made_up", Int::class.java),
            punished = occ.get("punished", Int::class.java),
            comments = comments,
            pointsEarned = points.get("earned", Int::class.java),
            pointsDeducted = points.get("deducted", Int::class.java),
            redemptions = redemptions,
        )
    }

    @Transactional(readOnly = true)
    fun summary(actorUserId: UUID, dynamicId: UUID): SummaryView {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        return SummaryView(
            daysTogether = streaks.daysTogether(dynamicId),
            currentStreak = streaks.currentStreak(dynamicId),
        )
    }
}
