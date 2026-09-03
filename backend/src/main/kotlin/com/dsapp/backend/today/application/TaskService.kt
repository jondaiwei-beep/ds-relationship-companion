package com.dsapp.backend.today.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.Side
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import com.dsapp.backend.today.domain.Proof
import com.dsapp.backend.today.domain.TaskKind
import com.fasterxml.jackson.databind.ObjectMapper
import org.jooq.DSLContext
import org.jooq.JSONB
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.time.LocalTime
import java.util.UUID

/**
 * Tasks — the 规矩 (product/03-domain.md §Task).
 *
 * A D writes a task and it is live. An s writes one and it is `proposed`
 * until the D accepts. In a dynamic with nobody on the D side yet (solo, or
 * the partner has not joined) the writer's own tasks are live: a person
 * alone must still be able to use the app (invariant 10).
 */
@Service
class TaskService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
    private val generator: OccurrenceGenerator,
    private val days: DynamicDays,
    private val mapper: ObjectMapper,
) {
    data class NewTask(
        val title: String,
        val detail: String? = null,
        val kind: TaskKind = TaskKind.recurring,
        val schedule: Map<String, Any?>? = if (kind == TaskKind.recurring) mapOf("type" to "daily") else null,
        val timesPerDay: Int = 1,
        val dueTime: LocalTime? = null,
        val dueAt: Instant? = null,
        val proof: Proof = Proof.check,
        val pointsEarn: Int = 0,
        val requiresDPresent: Boolean = false,
        val unit: String? = null,
    )

    /** Partial update — every field null means "leave unchanged". */
    data class TaskPatch(
        val title: String? = null,
        val detail: String? = null,
        val kind: TaskKind? = null,
        val schedule: Map<String, Any?>? = null,
        val timesPerDay: Int? = null,
        val dueTime: LocalTime? = null,
        val dueAt: Instant? = null,
        val proof: Proof? = null,
        val pointsEarn: Int? = null,
        val requiresDPresent: Boolean? = null,
        val unit: String? = null,
    )

    data class TaskView(
        val id: UUID,
        val title: String,
        val detail: String?,
        val kind: String,
        val schedule: Map<String, Any?>?,
        val timesPerDay: Int,
        val dueTime: LocalTime?,
        val dueAt: Instant?,
        val proof: String,
        val pointsEarn: Int,
        val requiresDPresent: Boolean,
        val pausedUntil: Instant?,
        val unit: String?,
        val createdBy: UUID,
        val status: String,
        val position: Int,
    )

    @Transactional
    fun create(actorUserId: UUID, dynamicId: UUID, t: NewTask): TaskView {
        // Setup rights: a D may write the first rules before the partner joins.
        val ctx = authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        if (!ctx.maySetUp) throw com.dsapp.backend.dynamic.domain.AuthorizationException.DynamicNotActive(ctx.dynamicState)
        require(t.title.isNotBlank() && t.title.length <= 120) { "title" }
        require(t.timesPerDay in 1..12) { "timesPerDay" }
        require(t.pointsEarn in 0..1000) { "pointsEarn" }
        val schedule = if (t.kind == TaskKind.recurring) {
            requireNotNull(t.schedule) { "schedule" }.also { generator.parseSchedule(mapper.writeValueAsString(it)) }
        } else null

        val status = if (ctx.side == Side.D || !hasDSide(dynamicId)) "active" else "proposed"
        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO tasks (id, dynamic_id, title, detail, kind, schedule, times_per_day, due_time, due_at,
                               proof, points_earn, requires_d_present, unit, created_by, status, position)
            VALUES ({0}, {1}, {2}, {3}, {4}, CAST({5} AS jsonb), {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14},
                    (SELECT COALESCE(MAX(position), 0) + 1 FROM tasks WHERE dynamic_id = {1}))
            """.trimIndent(),
            id, dynamicId, t.title.trim(), t.detail, t.kind.name,
            schedule?.let { mapper.writeValueAsString(it) },
            t.timesPerDay, t.dueTime, t.dueAt, t.proof.name, t.pointsEarn, t.requiresDPresent, t.unit,
            actorUserId, status,
        ).execute()
        events.append(dynamicId, actorUserId, "task_created", """{"task_id":"$id","status":"$status"}""")
        if (status == "active") materialize(dynamicId, id, t.kind)
        if (status == "proposed") {
            events.enqueueOutbox("task", id, "task_proposed", "task_proposed:$id")
        }
        return get(dynamicId, id)
    }

    /**
     * Edit a task. D only — an s who wants a change proposes a new task
     * instead (same asymmetry as create). Allowed on `active`/`proposed`/
     * `paused` tasks; `archived` tasks are done and cannot be reopened this
     * way (invariant 5: history stays, but it does not come back to life).
     *
     * A schedule/dueTime/timesPerDay change never touches an occurrence
     * that has already been decided — only today's still-`open` occurrences
     * for this task are regenerated, so someone's answered day never
     * silently changes shape under them.
     */
    @Transactional
    fun update(actorUserId: UUID, dynamicId: UUID, taskId: UUID, p: TaskPatch): TaskView {
        authorizer.requireSide(authorizer.contextForDynamic(actorUserId, dynamicId), Side.D)

        val current = dsl.fetchOne(
            "SELECT kind, status, schedule, times_per_day, due_time FROM tasks WHERE id = {0} AND dynamic_id = {1}",
            taskId, dynamicId,
        ) ?: throw NoSuchItem()
        val status = current.get("status", String::class.java)
        if (status == "archived") throw TaskNotActionable("TASK_ARCHIVED")

        p.title?.let { require(it.isNotBlank() && it.length <= 120) { "title" } }
        p.timesPerDay?.let { require(it in 1..12) { "timesPerDay" } }
        p.pointsEarn?.let { require(it in 0..1000) { "pointsEarn" } }

        val newKind = p.kind ?: TaskKind.valueOf(current.get("kind", String::class.java))
        val scheduleTouched = p.kind != null || p.schedule != null
        val newScheduleJson: String? = if (p.schedule != null) {
            mapper.writeValueAsString(p.schedule).also { generator.parseSchedule(it) }
        } else if (p.kind != null) {
            // kind changed but no explicit schedule given: keep the invariant honest.
            if (newKind == TaskKind.recurring) {
                current.get("schedule", JSONB::class.java)?.data()
                    ?: throw IllegalArgumentException("schedule")
            } else null
        } else null
        if (newKind == TaskKind.recurring) {
            val effective = newScheduleJson ?: current.get("schedule", JSONB::class.java)?.data()
            requireNotNull(effective) { "schedule" }
        }

        dsl.query(
            """
            UPDATE tasks SET
                title = COALESCE({2}, title),
                detail = CASE WHEN {3} THEN {4} ELSE detail END,
                kind = COALESCE({5}, kind),
                schedule = CASE WHEN {6} THEN CAST({7} AS jsonb) ELSE schedule END,
                times_per_day = COALESCE({8}, times_per_day),
                due_time = CASE WHEN {9} THEN {10} ELSE due_time END,
                due_at = CASE WHEN {11} THEN {12} ELSE due_at END,
                proof = COALESCE({13}, proof),
                points_earn = COALESCE({14}, points_earn),
                requires_d_present = COALESCE({15}, requires_d_present),
                unit = CASE WHEN {16} THEN {17} ELSE unit END,
                updated_at = now()
            WHERE id = {0} AND dynamic_id = {1}
            """.trimIndent(),
            taskId, dynamicId,
            p.title,
            p.detail != null, p.detail,
            p.kind?.name,
            (p.kind != null || p.schedule != null), newScheduleJson,
            p.timesPerDay,
            p.dueTime != null, p.dueTime,
            p.dueAt != null, p.dueAt,
            p.proof?.name,
            p.pointsEarn,
            p.requiresDPresent,
            p.unit != null, p.unit,
        ).execute()

        events.append(dynamicId, actorUserId, "task_updated", """{"task_id":"$taskId"}""")

        // Schedule/dueTime/timesPerDay change: regenerate only today's still-open
        // occurrences — decided ones (delivered/missed/etc.) are left alone.
        val scheduleShaped = scheduleTouched || p.timesPerDay != null || p.dueTime != null
        if (scheduleShaped && status != "proposed") {
            val today = days.today(dynamicId)
            dsl.query(
                "DELETE FROM occurrences WHERE task_id = {0} AND day = {1} AND outcome = 'open' AND disposition = 'none'",
                taskId, today,
            ).execute()
            if (status == "active") generator.generate(dynamicId, today)
        }

        return get(dynamicId, taskId)
    }

    /** The D takes an s proposal live. */
    @Transactional
    fun accept(actorUserId: UUID, dynamicId: UUID, taskId: UUID): TaskView {
        authorizer.requireSide(authorizer.contextForDynamic(actorUserId, dynamicId), Side.D)
        val row = dsl.fetchOne(
            """UPDATE tasks SET status = 'active', updated_at = now()
                WHERE id = {0} AND dynamic_id = {1} AND status = 'proposed' RETURNING kind""",
            taskId, dynamicId,
        ) ?: throw TaskNotActionable("TASK_NOT_PROPOSED")
        events.append(dynamicId, actorUserId, "task_accepted", """{"task_id":"$taskId"}""")
        events.enqueueOutbox("task", taskId, "task_accepted", "task_accepted:$taskId")
        materialize(dynamicId, taskId, TaskKind.valueOf(row.get("kind", String::class.java)))
        return get(dynamicId, taskId)
    }

    /**
     * The D declines an s proposal — same shape as archive, kept as its own
     * command so the client can show "declined" rather than "archived" and a
     * future version can attach a reason without overloading archive.
     */
    @Transactional
    fun decline(actorUserId: UUID, dynamicId: UUID, taskId: UUID) {
        authorizer.requireSide(authorizer.contextForDynamic(actorUserId, dynamicId), Side.D)
        val n = dsl.query(
            "UPDATE tasks SET status = 'archived', updated_at = now() WHERE id = {0} AND dynamic_id = {1} AND status = 'proposed'",
            taskId, dynamicId,
        ).execute()
        if (n == 0) throw TaskNotActionable("TASK_NOT_PROPOSED")
        events.append(dynamicId, actorUserId, "task_declined", """{"task_id":"$taskId"}""")
    }

    /**
     * Archive. The D may archive anything; an s only their own proposal.
     * Today's still-open occurrences go with it — nothing else is touched,
     * history stays (invariant 5).
     */
    @Transactional
    fun archive(actorUserId: UUID, dynamicId: UUID, taskId: UUID) {
        val ctx = authorizer.requireActive(authorizer.contextForDynamic(actorUserId, dynamicId))
        val updated = if (ctx.side == Side.D) dsl.query(
            "UPDATE tasks SET status = 'archived', updated_at = now() WHERE id = {0} AND dynamic_id = {1} AND status <> 'archived'",
            taskId, dynamicId,
        ).execute() else dsl.query(
            """UPDATE tasks SET status = 'archived', updated_at = now()
                WHERE id = {0} AND dynamic_id = {1} AND status = 'proposed' AND created_by = {2}""",
            taskId, dynamicId, actorUserId,
        ).execute()
        if (updated == 0) throw TaskNotActionable("TASK_NOT_ARCHIVABLE")
        dsl.query(
            "DELETE FROM occurrences WHERE task_id = {0} AND outcome IN ('open', 'paused') AND disposition = 'none' AND day >= {1}",
            taskId, days.today(dynamicId),
        ).execute()
        events.append(dynamicId, actorUserId, "task_archived", """{"task_id":"$taskId"}""")
    }

    /** Pause until [until] (null = indefinitely). Today's open occurrences turn `paused`: no debt. */
    @Transactional
    fun pause(actorUserId: UUID, dynamicId: UUID, taskId: UUID, until: Instant?) {
        authorizer.requireSide(authorizer.contextForDynamic(actorUserId, dynamicId), Side.D)
        val far = until ?: Instant.parse("9999-12-31T00:00:00Z")
        val n = dsl.query(
            "UPDATE tasks SET paused_until = {2}, updated_at = now() WHERE id = {0} AND dynamic_id = {1} AND status = 'active'",
            taskId, dynamicId, far,
        ).execute()
        if (n == 0) throw TaskNotActionable("TASK_NOT_ACTIVE")
        sweepOutcome(taskId, actorUserId, from = "open", to = "paused", day = days.today(dynamicId))
        events.append(dynamicId, actorUserId, "task_paused", """{"task_id":"$taskId"}""")
    }

    @Transactional
    fun unpause(actorUserId: UUID, dynamicId: UUID, taskId: UUID) {
        authorizer.requireSide(authorizer.contextForDynamic(actorUserId, dynamicId), Side.D)
        val n = dsl.query(
            "UPDATE tasks SET paused_until = NULL, updated_at = now() WHERE id = {0} AND dynamic_id = {1} AND status = 'active'",
            taskId, dynamicId,
        ).execute()
        if (n == 0) throw TaskNotActionable("TASK_NOT_ACTIVE")
        sweepOutcome(taskId, actorUserId, from = "paused", to = "open", day = days.today(dynamicId))
        events.append(dynamicId, actorUserId, "task_unpaused", """{"task_id":"$taskId"}""")
    }

    @Transactional(readOnly = true)
    fun list(actorUserId: UUID, dynamicId: UUID, includeArchived: Boolean = false): List<TaskView> {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        return dsl.fetch(
            """
            SELECT * FROM tasks WHERE dynamic_id = {0} AND ({1} OR status <> 'archived')
             ORDER BY position, created_at
            """.trimIndent(),
            dynamicId, includeArchived,
        ).map(::view)
    }

    fun get(dynamicId: UUID, taskId: UUID): TaskView =
        dsl.fetchOne("SELECT * FROM tasks WHERE id = {0} AND dynamic_id = {1}", taskId, dynamicId)
            ?.let(::view) ?: throw NoSuchItem()

    // ---- internals ---------------------------------------------------------

    /** A new live task shows up today, not tomorrow. */
    private fun materialize(dynamicId: UUID, taskId: UUID, kind: TaskKind) {
        when (kind) {
            TaskKind.one_off -> generator.ensureOneOff(taskId)
            TaskKind.open -> Unit
            else -> generator.generate(dynamicId, days.today(dynamicId))
        }
    }

    private fun sweepOutcome(taskId: UUID, by: UUID, from: String, to: String, day: java.time.LocalDate) {
        val ids = dsl.fetch(
            """UPDATE occurrences SET outcome = {3}, outcome_at = now(), version = version + 1, updated_at = now()
                WHERE task_id = {0} AND day >= {1} AND outcome = {2} RETURNING id""",
            taskId, day, from, to,
        ).map { it.get("id", UUID::class.java) }
        for (id in ids) dsl.query(
            "INSERT INTO occurrence_history (id, occurrence_id, by_user_id, axis, from_value, to_value) VALUES ({0}, {1}, {2}, 'outcome', {3}, {4})",
            UUID.randomUUID(), id, by, from, to,
        ).execute()
    }

    private fun hasDSide(dynamicId: UUID): Boolean = dsl.fetchOne(
        "SELECT 1 FROM memberships WHERE dynamic_id = {0} AND side = 'D' AND access_state = 'ACTIVE'", dynamicId,
    ) != null

    @Suppress("UNCHECKED_CAST")
    private fun view(r: org.jooq.Record): TaskView = TaskView(
        id = r.get("id", UUID::class.java),
        title = r.get("title", String::class.java),
        detail = r.get("detail", String::class.java),
        kind = r.get("kind", String::class.java),
        schedule = r.get("schedule", JSONB::class.java)?.let { mapper.readValue(it.data(), Map::class.java) as Map<String, Any?> },
        timesPerDay = r.get("times_per_day", Int::class.java),
        dueTime = r.get("due_time", LocalTime::class.java),
        dueAt = r.get("due_at", Instant::class.java),
        proof = r.get("proof", String::class.java),
        pointsEarn = r.get("points_earn", Int::class.java),
        requiresDPresent = r.get("requires_d_present", Boolean::class.java),
        pausedUntil = r.get("paused_until", Instant::class.java),
        unit = r.get("unit", String::class.java),
        createdBy = r.get("created_by", UUID::class.java),
        status = r.get("status", String::class.java),
        position = r.get("position", Int::class.java),
    )
}
