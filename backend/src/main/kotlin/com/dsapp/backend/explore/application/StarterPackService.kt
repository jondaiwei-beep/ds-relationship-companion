package com.dsapp.backend.explore.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.explore.domain.ExploreCatalog
import com.dsapp.backend.explore.domain.StarterPackDef
import com.dsapp.backend.points.application.PointsService
import com.dsapp.backend.rules.application.RuleService
import com.dsapp.backend.today.application.NoSuchItem
import com.dsapp.backend.today.application.TaskService
import com.dsapp.backend.today.domain.Proof
import com.dsapp.backend.today.domain.TaskKind
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalTime
import java.util.UUID

/**
 * 起步包 (StarterPack) — product/04-explore.md §3. Static drafts the client
 * shows editable; `apply` operates purely on the client-edited [ApplyDraft],
 * never re-reading the static pack, since the point is the client already
 * trimmed/edited it (D-23: "起步包是可编辑草稿，不是选项").
 */
@Service
class StarterPackService(
    private val catalog: ExploreCatalog,
    private val authorizer: MembershipAuthorizer,
    private val taskService: TaskService,
    private val ruleService: RuleService,
    private val pointsService: PointsService,
) {
    data class DraftTask(
        val title: String,
        val detail: String? = null,
        val kind: String = "checkin",
        val schedule: Map<String, Any?>? = null,
        val dueTime: String? = null,
        val proof: String = "check",
        val pointsEarn: Int = 0,
    )

    data class DraftRule(
        val title: String,
        val body: String? = null,
        val group: String = "other",
    )

    data class DraftReward(
        val title: String,
        val detail: String? = null,
        val cost: Int? = null,
    )

    data class ApplyDraft(
        val tasks: List<DraftTask> = emptyList(),
        val rules: List<DraftRule> = emptyList(),
        val rewards: List<DraftReward> = emptyList(),
    )

    data class ApplyResult(val taskIds: List<UUID>, val ruleIds: List<UUID>, val rewardIds: List<UUID>)

    fun packs(): List<StarterPackDef> = catalog.packs

    @Transactional
    fun apply(actorUserId: UUID, dynamicId: UUID, packId: String, draft: ApplyDraft): ApplyResult {
        catalog.packById(packId) ?: throw NoSuchItem()
        // Same rights check TaskService/RuleService apply to their own
        // create(): read access plus maySetUp (covers "creator before the
        // partner joins" and any active member thereafter).
        val ctx = authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        if (!ctx.maySetUp) throw com.dsapp.backend.dynamic.domain.AuthorizationException.DynamicNotActive(ctx.dynamicState)

        val taskIds = draft.tasks.map { t ->
            taskService.create(
                actorUserId, dynamicId,
                TaskService.NewTask(
                    title = t.title,
                    detail = t.detail,
                    kind = TaskKind.valueOf(t.kind),
                    schedule = if (TaskKind.valueOf(t.kind) == TaskKind.recurring) (t.schedule ?: mapOf("type" to "daily")) else null,
                    dueTime = t.dueTime?.let { LocalTime.parse(it) },
                    proof = Proof.valueOf(t.proof),
                    pointsEarn = t.pointsEarn,
                ),
            ).id
        }
        val ruleIds = draft.rules.map { r ->
            ruleService.create(actorUserId, dynamicId, RuleService.NewRule(r.title, r.body, r.group)).id
        }
        val rewardIds = draft.rewards.map { rw ->
            pointsService.addReward(actorUserId, dynamicId, rw.title, rw.detail, rw.cost)
        }
        return ApplyResult(taskIds, ruleIds, rewardIds)
    }
}
