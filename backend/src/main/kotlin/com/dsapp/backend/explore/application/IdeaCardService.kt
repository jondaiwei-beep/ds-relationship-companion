package com.dsapp.backend.explore.application

import com.dsapp.backend.dynamic.application.MembershipAuthorizer
import com.dsapp.backend.dynamic.domain.Side
import com.dsapp.backend.explore.domain.ExploreCatalog
import com.dsapp.backend.explore.domain.IdeaCardDef
import com.dsapp.backend.rules.application.RuleService
import com.dsapp.backend.today.application.DNoteService
import com.dsapp.backend.today.application.DynamicDays
import com.dsapp.backend.today.application.NoSuchItem
import com.dsapp.backend.today.application.TaskService
import com.dsapp.backend.today.domain.Proof
import com.dsapp.backend.today.domain.TaskKind
import org.jooq.DSLContext
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

/**
 * 灵感卡 (IdeaCard) — product/04-explore.md §2.
 *
 * "只推荐比对里不是「不要」的卡；「想聊」相关的卡置顶" ties exclusion
 * explicitly to PreferenceCompare's mutual `notDoing` bucket — so filtering
 * here calls [PreferenceService.notDoingItemIds], not a single-sided `no`.
 *
 * `draw` is the "今晚要什么？" entry: "抽卡不通知 s，只有 D 把它变成 Task 才
 * 通知" — so draw never touches the outbox, only `act(add_today)` does
 * (via TaskService, which already enqueues task_proposed for an s and
 * nothing extra for a D's own active task).
 */
@Service
class IdeaCardService(
    private val dsl: DSLContext,
    private val authorizer: MembershipAuthorizer,
    private val catalog: ExploreCatalog,
    private val preferences: PreferenceService,
    private val taskService: TaskService,
    private val ruleService: RuleService,
    private val dNoteService: DNoteService,
    private val days: DynamicDays,
) {
    data class CardView(val card: IdeaCardDef, val state: String?)

    data class ActResult(
        val taskId: UUID? = null,
        val ruleId: UUID? = null,
        val noteId: UUID? = null,
        val state: String? = null,
    )

    /**
     * Cards for the requesting member's side by default (D sees for_d ∪
     * for_both, s sees for_s ∪ for_both); [audience] narrows that further.
     * Excludes cards related to the dynamic's mutual "不要" items;
     * cards related to a "想聊" item sort first.
     */
    @Transactional(readOnly = true)
    fun cards(actorUserId: UUID, dynamicId: UUID, audience: String?): List<CardView> {
        val ctx = authorizer.requireRead(authorizer.contextForDynamic(actorUserId, dynamicId))
        val defaultAudience = if (ctx.side == Side.D) setOf("for_d", "for_both") else setOf("for_s", "for_both")
        val allowed = if (audience != null) defaultAudience.intersect(setOf(audience)).ifEmpty { setOf(audience) } else defaultAudience

        val notDoing = preferences.notDoingItemIds(actorUserId, dynamicId)
        val talking = preferences.talkItemIds(actorUserId, dynamicId)
        val states = statesFor(dynamicId)

        return catalog.cards
            .filter { it.audience in allowed }
            .filter { it.relatedItemIds.none { id -> id in notDoing } }
            .sortedByDescending { it.relatedItemIds.any { id -> id in talking } }
            .map { CardView(it, states[it.id]) }
    }

    /** "今晚要什么？" — one random card for the D, same filtering, no notification. */
    @Transactional(readOnly = true)
    fun draw(actorUserId: UUID, dynamicId: UUID): CardView {
        authorizer.requireSide(authorizer.contextForDynamic(actorUserId, dynamicId), Side.D)
        val notDoing = preferences.notDoingItemIds(actorUserId, dynamicId)
        val states = statesFor(dynamicId)
        val pool = catalog.cards
            .filter { it.audience == "for_d" || it.audience == "for_both" }
            .filter { it.relatedItemIds.none { id -> id in notDoing } }
        val picked = pool.randomOrNull() ?: throw NoSuchItem()
        return CardView(picked, states[picked.id])
    }

    @Transactional
    fun act(actorUserId: UUID, dynamicId: UUID, cardId: String, action: String): ActResult {
        val ctx = authorizer.requireActive(authorizer.contextForDynamic(actorUserId, dynamicId))
        val card = catalog.cardById(cardId) ?: throw NoSuchItem()

        return when (action) {
            "add_today" -> {
                val today = days.today(dynamicId)
                val dueAt = days.settings(dynamicId).rangeOf(today).endInclusive
                val task = taskService.create(
                    actorUserId, dynamicId,
                    TaskService.NewTask(
                        title = card.titleZh,
                        detail = card.howZh.joinToString(" "),
                        kind = TaskKind.one_off,
                        schedule = null,
                        dueAt = dueAt,
                        proof = Proof.check,
                        pointsEarn = 0,
                    ),
                )
                ActResult(taskId = task.id)
            }
            "add_rule" -> {
                val rule = ruleService.create(
                    actorUserId, dynamicId,
                    RuleService.NewRule(title = card.titleZh, body = card.howZh.joinToString(" "), group = "other"),
                )
                ActResult(ruleId = rule.id)
            }
            "save" -> {
                if (ctx.side == Side.D) {
                    val note = dNoteService.create(
                        actorUserId, dynamicId,
                        body = "${card.titleZh} — ${card.howZh.joinToString(" ")}".take(1000),
                        remindAt = null,
                    )
                    ActResult(noteId = note.id)
                } else {
                    val state = upsertState(dynamicId, cardId, "saved", actorUserId)
                    ActResult(state = state)
                }
            }
            "tried_again", "tried_never" -> {
                val status = if (action == "tried_again") "tried_again" else "tried_never"
                ActResult(state = upsertState(dynamicId, cardId, status, actorUserId))
            }
            else -> throw IllegalArgumentException("action")
        }
    }

    private fun upsertState(dynamicId: UUID, cardId: String, status: String, actorUserId: UUID): String {
        dsl.query(
            """
            INSERT INTO idea_card_states (id, dynamic_id, card_id, status, by_user_id)
            VALUES ({0}, {1}, {2}, {3}, {4})
            ON CONFLICT (dynamic_id, card_id)
            DO UPDATE SET status = EXCLUDED.status, by_user_id = EXCLUDED.by_user_id, updated_at = now()
            """.trimIndent(),
            UUID.randomUUID(), dynamicId, cardId, status, actorUserId,
        ).execute()
        return status
    }

    private fun statesFor(dynamicId: UUID): Map<String, String> = dsl.fetch(
        "SELECT card_id, status FROM idea_card_states WHERE dynamic_id = {0}", dynamicId,
    ).associate { it.get("card_id", String::class.java) to it.get("status", String::class.java) }
}
