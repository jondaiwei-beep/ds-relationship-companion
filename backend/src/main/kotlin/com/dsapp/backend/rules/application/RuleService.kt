package com.dsapp.backend.rules.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.Side
import com.dsapp.backend.timeline.application.RelationshipEventWriter
import com.dsapp.backend.today.application.NoSuchItem
import com.dsapp.backend.today.application.TaskNotActionable
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

/**
 * Rule — 常设规矩 (product/03-domain.md §Rule). Standing agreements: 称呼,
 * 跪迎, 禁慾, 着装, 汇报方式… Unlike Task, a Rule never generates an
 * occurrence; it just sits in the 规矩 tab as something that is true.
 *
 * D writes and edits directly. An s may only propose (`status='proposed'`)
 * until the D accepts — same shape as Task's proposal path.
 */
@Service
class RuleService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val events: RelationshipEventWriter,
) {
    val groups = listOf("protocol", "ritual", "restriction", "appearance", "reporting", "other")

    data class RuleView(
        val id: UUID,
        val title: String,
        val body: String?,
        val group: String,
        val createdBy: UUID,
        val status: String,
        val position: Int,
        val createdAt: Instant,
        val updatedAt: Instant,
    )

    data class NewRule(val title: String, val body: String? = null, val group: String = "other")
    data class RuleEdit(val title: String? = null, val body: String? = null, val group: String? = null, val position: Int? = null)

    /** D writes -> active. s writes -> proposed, unless nobody is on the D side yet (invariant 9). */
    @Transactional
    fun create(actorUserId: UUID, dynamicId: UUID, r: NewRule): RuleView {
        val ctx = authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        if (!ctx.maySetUp) throw com.dsapp.backend.dynamic.domain.AuthorizationException.DynamicNotActive(ctx.dynamicState)
        val title = r.title.trim()
        require(title.isNotEmpty() && title.length <= 120) { "title" }
        require(r.body == null || r.body.length <= 2000) { "body" }
        require(r.group in groups) { "group" }

        val status = if (ctx.side == Side.D || !hasDSide(dynamicId)) "active" else "proposed"
        val id = UUID.randomUUID()
        dsl.query(
            """
            INSERT INTO rules (id, dynamic_id, title, body, "group", created_by, status, position)
            VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6},
                    (SELECT COALESCE(MAX(position), 0) + 1 FROM rules WHERE dynamic_id = {1}))
            """.trimIndent(),
            id, dynamicId, title, r.body?.trim()?.takeIf { it.isNotEmpty() }, r.group, actorUserId, status,
        ).execute()
        events.append(dynamicId, actorUserId, "rule_created", """{"rule_id":"$id","status":"$status"}""")
        if (status == "proposed") {
            events.enqueueOutbox("rule", id, "rule_proposed", "rule_proposed:$id")
        }
        return get(dynamicId, id)
    }

    /** D only. Title/body/group/position. */
    @Transactional
    fun update(actorUserId: UUID, dynamicId: UUID, ruleId: UUID, edit: RuleEdit): RuleView {
        authorizer.requireSide(authorizer.contextForDynamic(actorUserId, dynamicId), Side.D)
        edit.title?.let { require(it.isNotBlank() && it.length <= 120) { "title" } }
        edit.body?.let { require(it.length <= 2000) { "body" } }
        edit.group?.let { require(it in groups) { "group" } }

        val n = dsl.query(
            """
            UPDATE rules SET
                title = COALESCE({2}, title),
                body = CASE WHEN {3} THEN {4} ELSE body END,
                "group" = COALESCE({5}, "group"),
                position = COALESCE({6}, position),
                updated_at = now()
             WHERE id = {0} AND dynamic_id = {1}
            """.trimIndent(),
            ruleId, dynamicId,
            edit.title?.trim(), edit.body != null, edit.body?.trim()?.takeIf { it.isNotEmpty() },
            edit.group, edit.position,
        ).execute()
        if (n == 0) throw NoSuchItem()
        events.append(dynamicId, actorUserId, "rule_updated", """{"rule_id":"$ruleId"}""")
        return get(dynamicId, ruleId)
    }

    /** D may archive anything; an s only their own proposal. */
    @Transactional
    fun archive(actorUserId: UUID, dynamicId: UUID, ruleId: UUID) {
        val ctx = authorizer.requireActive(authorizer.contextForDynamic(actorUserId, dynamicId))
        val n = if (ctx.side == Side.D) dsl.query(
            "UPDATE rules SET status = 'archived', updated_at = now() WHERE id = {0} AND dynamic_id = {1} AND status <> 'archived'",
            ruleId, dynamicId,
        ).execute() else dsl.query(
            """UPDATE rules SET status = 'archived', updated_at = now()
                WHERE id = {0} AND dynamic_id = {1} AND status = 'proposed' AND created_by = {2}""",
            ruleId, dynamicId, actorUserId,
        ).execute()
        if (n == 0) throw TaskNotActionable("RULE_NOT_ARCHIVABLE")
        events.append(dynamicId, actorUserId, "rule_archived", """{"rule_id":"$ruleId"}""")
    }

    /** D accepts an s proposal. */
    @Transactional
    fun accept(actorUserId: UUID, dynamicId: UUID, ruleId: UUID): RuleView {
        authorizer.requireSide(authorizer.contextForDynamic(actorUserId, dynamicId), Side.D)
        val n = dsl.query(
            "UPDATE rules SET status = 'active', updated_at = now() WHERE id = {0} AND dynamic_id = {1} AND status = 'proposed'",
            ruleId, dynamicId,
        ).execute()
        if (n == 0) throw TaskNotActionable("RULE_NOT_PROPOSED")
        events.append(dynamicId, actorUserId, "rule_accepted", """{"rule_id":"$ruleId"}""")
        events.enqueueOutbox("rule", ruleId, "rule_accepted", "rule_accepted:$ruleId")
        return get(dynamicId, ruleId)
    }

    /** Grouped, ordered by group then position — the 规矩 tab's listing. */
    @Transactional(readOnly = true)
    fun list(actorUserId: UUID, dynamicId: UUID, includeArchived: Boolean = false): List<RuleView> {
        authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        return dsl.fetch(
            """
            SELECT * FROM rules WHERE dynamic_id = {0} AND ({1} OR status <> 'archived')
             ORDER BY "group", position, created_at
            """.trimIndent(),
            dynamicId, includeArchived,
        ).map(::view)
    }

    fun get(dynamicId: UUID, ruleId: UUID): RuleView =
        dsl.fetchOne("SELECT * FROM rules WHERE id = {0} AND dynamic_id = {1}", ruleId, dynamicId)
            ?.let(::view) ?: throw NoSuchItem()

    private fun hasDSide(dynamicId: UUID): Boolean = dsl.fetchOne(
        "SELECT 1 FROM memberships WHERE dynamic_id = {0} AND side = 'D' AND access_state = 'ACTIVE'", dynamicId,
    ) != null

    private fun view(r: org.jooq.Record): RuleView = RuleView(
        id = r.get("id", UUID::class.java),
        title = r.get("title", String::class.java),
        body = r.get("body", String::class.java),
        group = r.get("group", String::class.java),
        createdBy = r.get("created_by", UUID::class.java),
        status = r.get("status", String::class.java),
        position = r.get("position", Int::class.java),
        createdAt = r.get("created_at", Instant::class.java),
        updatedAt = r.get("updated_at", Instant::class.java),
    )
}
