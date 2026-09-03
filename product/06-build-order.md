# 06 · 开发顺序

原则：先把「今天」的一条闭环（s 交付 → 回执 → D 处置 → 记录里可见）做到能用两周，再长别的。每个阶段结束都是可跑、可给一对真实用户试的版本。

## 现状 → 新模型 的映射

| 现有 | 处理 |
|---|---|
| `OccurrenceState`（SCHEDULED/ACTIVE/WAITING_ACK/ACKNOWLEDGED/NEEDS_REVIEW/REVIEWED/NEED_TO_DISCUSS/RESCHEDULE_REQUESTED/EXCUSE_REQUESTED/EXCUSED/CANCELLED） | **拆成两轴**：`outcome`（open/delivered/delivered_late/cant_do/new_time_requested/discuss_requested/missed/paused）+ `disposition`（none/seen/praised/let_go/make_up/punished）。旧单轴把"D 没看"和"s 没做"混在一起（WAITING_ACK / NEEDS_REVIEW），正是 D-07 要消灭的结构 |
| `AdjustmentType` DISCUSS/RESCHEDULE/CANT_DO + `AdjustmentResolution` | 变成 outcome 的三个出口；resolution 并入 disposition（`make_up(day)` = 同意新时间，`let_go` = 免了） |
| `AcknowledgementType` ACKNOWLEDGE/PRAISE/COMMENT/REVIEW | → disposition seen/praised；COMMENT → `DayComment`；REVIEW 删 |
| `occurrences.received_at`（V16，未提交） | 保留，改名或直接作 `seen_at`。这批未提交改动**保留**，它们就是回执 |
| `expectation_definitions` + `expectation_recurrences`（V6） | → `Task`；加 `kind, proof, points_earn, requires_d_present, paused_until, status(proposed)` |
| `check_ins`（V6 情绪/精力量表） | 删表；问安 = `Task.kind=checkin` |
| `point_entries`（V12）、`rewards`（V12）、`reward_redemptions`（V13）、`gifts`（V14） | 保留；`point_entries` 加 `reason, by_user_id, ref`；gift 并入 `d_award` |
| `consequence_agreements` / `consequence_events`（V12） | → `ConsequenceTemplate` / `Consequence`；events 加 `issued_by NOT NULL`、状态机 |
| `boundaries`（V10）、`long_distance`（V11） | 删；底线 = 探索比对的「不要」；异地 = `requires_d_present` + `paused_until` |
| `deferred_until`（V8） | 并入 `Task.paused_until` |
| `streak_proof_chance`（V15） | streak 保留；proof_chance 删 |
| `ExploreLibrary.kt` | 内容抽成 JSON（`StarterPack` / `IdeaCard` / `PreferenceItem`），代码删 |
| client `features/{weekly, checkin, boundary, us}` | 删 |
| client `features/response`（composer） | 改成两下处置（无表单，可选附一句） |
| client `features/explore` | 重做（04-explore） |
| client 5 tab shell | 改 4 tab |
| `l10n/app_en.arb` 692 键 | 全部重写为 D/s 语气；新增 zh-CN；不保留"You are seen."类句子 |
| 代码里的 "Product red line" 注释 | 全删 |

## Phase 0 · 清场（半天）✅ 2026-09-03
- 提交现有未提交的 Received 改动（回执雏形）。
- 删 client `features/{weekly,checkin,boundary,us}`、backend `boundary/`、`check_ins`、weekly/us 端点；V17 drop `check_ins`/`boundaries`。删所有 red-line 注释（已应用的迁移文件不改——Flyway 校验 checksum）。
- `long_distance` 暂留：Phase 3 用 `requires_d_present` 替换时一并删。
- 4 tab 壳：今天 / 规矩 / 记录（占位）/ 分；探索挂在规矩下（`/dynamics/:id/explore`）。
- 更新 `CLAUDE.md` / `AGENTS.md` / `README.md` / `.claude/skills/ds-*` 指向 `product/`、`research/`。
- 验收：`./gradlew test`、`flutter analyze` 过。

## Phase 1 · 今天（核心闭环，2–3 周）
后端 ✅ 2026-09-03（`backend/…/today/`，`TodayIT` 覆盖不变量；164 测试通过）
- 实际落地与下文差异：`memberships.side`（D/S）承担轴授权；`dynamics.day_boundary_minutes` 默认 240（无 `day_start` 列）；`point_entries.reason` 改名为 `task_earn/d_award/d_deduct/redemption/redemption_refund`；`open` 类任务无 occurrence，s 经 `POST /tasks/{id}/deliver` 生一条已交付；make-up 用 slot≥1000 的 occurrence 表达；`missed` 也写 `outcome_at`（历史行 `by_user_id` 为 NULL 标识系统）。
- ⚠️ V18 是破坏性迁移（drop 旧 expectation/occurrence 表）：上 staging（`ops/deploy-ds.sh`，库 `dsapp`）会清掉测试数据。
- V18：`tasks`（改 `expectation_definitions`）、`occurrences` 拆双轴、`day_comments`、`d_notes`、`private_notes`、`dynamics.day_start/timezone`、`point_entries.reason/by/ref`。
- 关系日计算器（唯一实现，服务端 + 客户端各一份，同一测试向量）。
- 每关系日生成 occurrence 的 job；日终标 `missed`（**只写 outcome，无其它副作用**）。
- s 动作：deliver(proof) / cant_do / new_time / discuss / 撤回；自动 `delivered_late`；`task_earn` 入账。
- D 动作：seen（打开即写）/ praised / let_go / make_up(day) / punished（要求 consequence_id）；改处置留历史。
- D 快速加一条；DNote CRUD + 提醒。
- 通知：s 交付→D；D 处置→s；到点提醒→s；DNote 提醒→D。中性文案开关。
客户端
- 4 tab shell，先只做「今天」+ 设置。
- s 今天：列表、勾/拍照/写一句、乐观「已送到」、长按四出口、paused 灰显、顶部余额/连续/day_start。
- D 今天：等我处置列表（两下）、概况、快速加、我要记得的。
- 设备锁（系统生物识别/PIN）。
- 验收：Day A（01-users）从早到晚每一步都能在真机上走通；不变量 1–7 有测试。
- ✅ 2026-09-03 客户端 Phase 1 落地：旧 expectation/response/attention 模型与页面删除；新 `TodayView/OccurrenceView/OpenTaskView/TaskView/DNote` 模型与 today/task/d-note 仓库；`domain/relationship_day.dart` 与服务端同一测试向量；`/dynamics/:id/today` 按 `TodayView.side` 渲染 s 面或 D 面；设置页显示 day_start 并加设备锁（local_auth + secure storage，>30s 回前台重锁）；zh/en 文案齐；`flutter analyze` 0，`flutter test` 全绿。
  - 偏差/待办：`day_start` 只读（服务端无修改端点）；照片证明先用一行引用文字代替拍照；「我认，晚了」不单独出口（服务端按到点自动记 `delivered_late`）；无 Dynamic 级 paused 提示（TodayView 无该字段，按行灰显）；规矩页「问一件事」与探索「用这个」入口随旧模型下线，新建走 D 今天「快速加一条」；真机 Day A 走查未做。

## Phase 2 · 记录（1–2 周）
后端 ✅ 2026-09-03（`backend/…/record/`，`RecordIT` 覆盖；175 测试通过）
- `RecordQueryService`：月视图 cell（due/delivered/flagged/missed/undisposed/comments/hasPrivateNote，无内容的天不出现）；这一天时间线（occurrence_history 两轴 + DayComment + point_entries + reward_redemptions，按时间排序）；facts（纯计数，`03-decisions` 不评价）；summary（`daysTogether` + `currentStreak`）。
- `RelationshipStreaks`（新，`today/application/`，today 与 record 共用一份）：`daysTogether` 改为「两人都 ACTIVE 起的关系日数，只涨」，取 `memberships.joined_at` 较晚者，单人取 `dynamics.created_at`；`PointsService.daysTogether` 与 `TodayQueryService.TodayView.daysTogether` 均改为委托这里，不再是「有交付的不同天数」。`PointsIT` 对应断言重写（`days together never resets` 现断言「补记录不影响计数」，新增 `days together only grows as relationship days elapse`）。
- `currentStreak` 向前回溯以 `daysTogether` 的起始日为下限（否则空历史的关系会一路查到 4713 BC 撞 Postgres date 范围——已用 `RecordIT` 复现并修好）。
- `DayCommentService`：双方可写、软删（`deleted_at`）、只删自己的；outbox `day_comment`（dedupe `comment:$id`），扩展 `OutboxDispatcher.recipientFor`（评论作者以外的 ACTIVE 成员）/`isStale`（评论已删）/`neutralBodyFor`/deepLink（`/record/{day}`）。
- `PrivateNoteService`：`upsert` 空内容删除，非空走 `ON CONFLICT` upsert；`get`/`day()` 只返回 actor 自己的，从不返回对方的（`RecordIT` 覆盖）；D-Note 不出现在时间线（无 `d_note` kind）。
- `RecordController`：`GET .../record/{month,day,facts,summary}`、`POST .../record/comments`（IdempotentPost）、`DELETE /v1/day-comments/{id}`、`PUT .../record/private-note`；`month` 用 `@RequestParam month: String` 手动 `YearMonth.parse`（项目未注册 YearMonth 的 Spring converter，避免新增全局 bean）。
- 历史可补：`OutcomeService.set` 本来就允许 s 把 `missed` 改成 `delivered`（→ 因逾期自动记 `delivered_late`）或 `cant_do`——未改代码，新增 `RecordIT` 用例验证真实时间戳而非伪装成按时。
- 未新增 V19：V18 已含 `day_comments`/`private_notes` 全部所需字段与索引。
- 验收：`RecordIT` 覆盖月 cell 算术、这一天时间线顺序与隐私（B 的私人备注/DNote 对 A 不可见）、双方留言与只删自己、facts 纯计数、streak（let_go/paused 不断、undisposed missed 断）、daysTogether 只涨、`missed→delivered_late` 补记录、`day_comment` outbox 目标。

客户端 ✅ 2026-09-03（`client/lib/features/record/`，`domain_client/models/record.dart` + `record_repository.dart`；322 测试通过，`flutter analyze` 0）
- 记录 tab：头部「在一起 N 天 · 连续 M 天」（D-27）；周一起始月格，今天格以 `TodayView.day` 为准（不变量 7，不读设备时钟），格内 `delivered/due`、未处置点、留言角标；左右滑/箭头换月，未到的月不可进，未到的天不可点；底部 facts 表「项 | 本周 | 本月」纯计数，本周＝含关系日今天的周（周一–周日），本月＝当前显示的月。
- 这一天 `/dynamics/:id/record/:day`：时间线按时间一列，钟点用 Dynamic 时区；人名由 `TodayView.side` + `partnerDisplayName` + JWT `sub` 推得（历史条目无 by_user_id）；留言只在时间线出现一次，底部只放输入框；自己的留言长按删；私人备注失焦即 PUT，清空即删。
- 历史可补：每个 occurrence 的当前态由该天时间线最后一条 outcome/disposition 推出（DayView 不带），动作挂在该 occurrence 最后一行：s 对 `missed` 见「补交付 / 说明做不了」（LineSheet 可选一句，不再问凭证类型）；D 对任何非 open/paused 且未处置的 occurrence 见五个词。写入走 Phase 1 的 `setOutcome/setDisposition`，成功后失效 day/month/facts/summary/today 五个 provider。
- 通知深链 `/record/{day}` 经 `HomeResolver` 解出 Dynamic 再跳；`ApiClient` 新增 `put`。补上的日期选择从今天关系日起。
- 验收：`calendar_math_test`（周一起始、跨年）、`record_screen_test`（月格/标记/换月/点开）、`day_screen_test`（时间线顺序与时区、留言增删且只删自己、私人备注保存与清空、s 补交付/说明做不了、D 五词与不过期、409 回退）、`navigation_routing_test` 深链落到这一天。

## Phase 3 · 规矩 + 分（1–2 周）
后端 ✅ 2026-09-03（`backend/…/rules/`、`points/`、`today/`；`RuleIT`/`RedemptionIT`/`AwayIT`/`ConsequenceLifecycleIT` 覆盖；203 测试通过）
- V19：新表 `rules`（title/body/group/status/position，group CHECK 六选一）；`reward_redemptions` 加 `status`(requested/approved/denied/fulfilled)/`decided_by`/`decided_at`/`note`/`point_entry_id`；`rewards.cost` 改可空（NULL = 「D 决定」）；`dynamics.d_away_until`。`consequences` 生命周期表 V18 已建，本阶段只加流转端点，未改表。
- `RuleService`/`RuleController`（`/v1/dynamics/{id}/rules`）：list（按 group、position）、create（D→active，s→proposed）、update（D only）、archive（D 任意/s 仅自己的 proposed）、accept（D）。事件走 `RelationshipEventWriter`；outbox `rule_proposed`→D、`rule_accepted`→S。
- Task：补 `decline`（D，proposed→archived，事件 `task_declined`）；`create`/`accept` 补上此前缺失的 outbox 入队（`task_proposed`→D、`task_accepted`→S）——原来只写了 timeline 事件，没有推送。
- `AwayService`/`AwayController`（`POST .../away {until}`、`POST .../back`，D only）：写 `dynamics.d_away_until`；对所有 `requires_d_present` 的 active 任务设 `paused_until=until` 并 sweep 今天的 open occurrence 到 paused；`back` 只清 `paused_until` 恰等于本次 away 值的任务（手工按条设的不同暂停时间不受影响），清 `d_away_until`。`dAwayUntil` 已加入 `DynamicQueryService.DynamicDetail` 与 `TodayQueryService.TodayView`。
- Redemption 流程（`PointsService`/`PointsController`）：`request`（s，写 `requested`，有定价的奖励仍检查可负担但不扣分）、`decide`（D，approve 写唯一一条 `redemption` 流水并回填 `point_entry_id`；deny 不扣分；「D 决定」奖励 approve 时必须给 `costOverride`，否则 409 `REDEMPTION_REQUIRES_COST`）、`fulfill`（任一方）、`redemptions`（双方可见，可按 status 过滤）。既有 `redeem()`（即时兑换）现拒绝 cost=NULL 的奖励，改走 `request`。`GET .../points/rules` 列出 `points_earn>0` 的 active 任务。outbox `redemption_requested`→D、`redemption_decided`→S。
- Consequence 生命周期（`ConsequenceLifecycleService`/`ConsequenceController`）：`POST /v1/consequences/{id}/done`（S，issued→done_by_s）、`/confirm`、`/waive`（D，issued 或 done_by_s→confirmed/waived，写 `decided_at`）；`GET /v1/dynamics/{id}/consequences?status=`。系统不触碰这张表——只有 `DispositionService` 的 `punished` 会建行。`MembershipAuthorizer` 新增 `contextForConsequence`。
- `OutboxDispatcher` 扩展 `recipientFor`/`isStale`/`neutralBodyFor`/`deepLinkFor` 覆盖全部新事件类型；deep link `/rules`、`/points`。
- ⚠️ 偏差：旧的 `PointsController` `GET/POST /v1/dynamics/{id}/consequences`（操作 `consequence_agreements`/`consequence_events`，Phase 3 之前的"预先约定、手动触发"惩罚概念）与新 `ConsequenceController` 的同路径冲突（Spring ambiguous mapping），旧路由改名为 `/v1/dynamics/{id}/agreement-consequences`，服务层 `PointsService.consequenceHistory`/`issueConsequence`/`agreements` 未改；两套惩罚概念目前并存，未合并——建议后续 phase 评估是否收敛到 `consequences`/`ConsequenceLifecycleService` 一套。
- ⚠️ jOOQ 可选参数踩坑：`WHERE (? IS NULL OR col = ?)` 在 Postgres 下报「could not determine data type of parameter」，需 `CAST(? AS text) IS NULL`（`redemptions`/`consequences` 的 status 过滤两处已修）。
- 验收：s 建规矩为 proposed 且在 D 接受前不算 active；s 不能改 D 的规矩；away 只暂停 `requires_d_present` 的任务，`back` 只恢复它自己暂停的那些；`requested` 状态兑换不扣分，denied 不扣分，approve 恰好写一条归属 D 的 `redemption` 流水；「D 决定」奖励 approve 时若无 cost 报错；consequence done/confirm/waive 的双边规则；所有扣分流水都有 actor（既有 CHECK 约束）。

客户端 ✅ 2026-09-03（`client/lib/features/rules/`、`features/points/`；`rules_screen_test` 7 例 + `points_screen_test` 7 例；全仓 313 测试通过，analyze 0 issue）
- 模型/仓库：`models/rule.dart`（RuleView/NewRule/RuleEdit，六组常量）、`models/redemption.dart`、`models/consequence.dart`；`Reward.cost` 改 `int?`（null=「D 决定」）；新增 `PointsRule`；`RuleRepository`（list/create/PATCH update/archive/accept）、`ConsequenceRepository`（list/done/confirm/waive）；`PointsRepository` 补 request/redemptions/decide/fulfill/pointsRules；`TaskRepository.decline`；`DynamicRepository.away/back`；`TodayView`/`DynamicDetail` 加 `dAwayUntil`；`ApiClient.patch`。
- 规矩 tab（`rules_screen.dart` 取代旧 `dynamic_screen.dart`）：顶部 D「我不在」→日期选择→`/away`（until = 所选日在 Dynamic 时区 day_start 的瞬间，不用设备日期）；已设则显「不在，到 M月d日」+「回来了」→`/back`，s 只读。分区顺序：常设规矩（按 group 分组；D 点开改/归档，s 长按→「提议改一条」，以编辑后的文本 POST 出一条 proposed）→ 循环任务定义（计划/凭证/分/需要 D 在；D 加、暂停到某日/不定期、恢复、归档；s 提议→proposed）→ 提议中（任务+规矩合并，D 接受/不要，s 看自己待看的）→ 奖励目录（D 加/下架，成本可「到时候再定」=null；s 只读 + 去兑换）→ 惩罚库（`/agreements` 模板，D 加/结束；文案明说只在处置里由 D 手动用）→ 底线与安全词占位行→探索。
- 分 tab（`points_screen.dart` 重写）：余额取 s 的（D 面显「{s} 有 N 分」）；「在一起 N 天 · 连续 M 天」复用 `recordSummaryProvider`；可兑换（不够显「还差 N 分」，null 显「{D} 定」；cost=0 直接 `/redeem`，否则 LineSheet 可选一句→`/request`）；兑换申请（s 看状态词；D 同意/不行，「D 决定」奖励同意时必填分数→`costOverride`；approved 双方可「完成了」→`/fulfill`）；罚（issued→s「做完了」；D 对 issued/done_by_s「确认」/「算了」，无计时）；流水 reason 词映射；规则可见（`/points/rules` + 「其余基础项 0 分」）；D 给分/扣分→`POST /points`。
- 每个写操作带 `Idempotency-Key`，失败只显一句「没发出去」，成功后 invalidate 相关 provider；s 的 userId 由 `dynamicDetailProvider.members(side=S)` 推出（`sUserIdProvider`）。
- ⚠️ 偏差：任务定义表单只做 recurring（daily/weekdays/every_n_days）+ 凭证 + 分 + 需要 D 在，未做 timesPerDay/dueTime/one_off/measure 的编辑。
- ⚠️ 偏差：安全词模型无字段，规矩页只留「底线」一行链到探索的偏好对照，未做安全词。
- ⚠️ 偏差：旧 Dynamic 总览页（成员对、结构行、`orbit_figure`）及其测试删除；`ConsequencePanel`/`issueConsequence`/`ConsequenceEvent`（走已改名的 `/agreement-consequences`）从客户端移除，惩罚只来自处置的 `punished`；`PointsScreen` 去掉 onBack 与 gift UI（`gift` 仓库方法保留未接线）。
- ⚠️ 偏差：兑换申请与罚两个列表当前不按 status 过滤，全部展示（denied/fulfilled/confirmed/waived 灰显）；量大后需分页或只留最近。

## Phase 4 · 探索（1–2 周）
后端 ✅ 2026-09-03（`backend/…/explore/`；`ExploreIT` 13 例覆盖；全仓 209 测试通过）
- V20：新表 `preference_items_custom`（dynamic 自定义题库条目）、`preference_answers`（`item_id text` 兼容系统 slug 与自定义 UUID，`answer CHECK (want/ok/no/talk)`，唯一键 dynamic+item+member）、`idea_card_states`（`status CHECK (saved/tried_again/tried_never)`，唯一键 dynamic+card）。
- 静态内容 = JSON，非表：`backend/src/main/resources/explore/{preference_items,idea_cards,starter_packs}.json`，启动时由 `ExploreCatalog`（Jackson snake_case→camelCase）读入内存。preference_items 57 条（10 组，含从 voices-zh/voices-reddit 提炼的呈报/自首/D不在家等本土条目）；idea_cards 34 张（全部 related_item_ids 已用测试断言对齐 preference_items）；starter_packs 7 个（日常问安/家务服务/身体与健康/着装与呈现/语言与称呼/D 不在家时/新手第一周）。
- `PreferenceService`：`items`（只返回调用者自己的答案）、`answer`（upsert，itemId 兼容系统 slug/自定义 UUID）、`addCustom`（D/s 皆可）、`compare`（隐私核心：双答才互见；桶优先级 notDoing > someoneTalks > bothWant > wantAndOk；notDoing 的 DTO 只有 `{itemId,title}`，测试用反射断言字段名不含 member/side/user 任何字样；单人 dynamic 返回全空桶 + `partnerAnswered=false`）。
- `IdeaCardService`：`cards`（按调用者 side 默认过滤 for_d/for_s + for_both，`audience` 参数可再收窄；排除与 mutual notDoing 关联的卡；talk 关联卡置顶）；`draw`（D only，随机抽卡，不写 outbox——测试直接查 `outbox_records` 计数断言）；`act`（add_today/add_rule/save/tried_again/tried_never，复用 TaskService/RuleService/DNoteService，proposed/active 由被调用方按 side 原生决定，未特殊处理）。
- `StarterPackService`：`packs()` 返回静态草稿；`apply` 只操作客户端传入的 draft（不重读静态包），`@Transactional`，幂等交给 controller 层 `IdempotentPost`。
- `ExploreController`：9 个路由，见下方"实现的端点"。删除旧 `activation/api/ExploreController.kt`（`GET /v1/explore`）及 `ExploreLibrary.kt`（471 行内容已按 04-explore 的字段重构进三份 JSON，非机械搬运）；`SecurityConfig` 移除对应的 permitAll 行。`StarterRhythmController`/`StarterRhythmService`/`StarterContent.kt`（激活向导，读 `StarterContent` 非 `ExploreLibrary`）未动。
- ⚠️ 偏差：`research/practice.md` 不存在，改用 `research/voices-zh.md`（PTT BDSM 板 + Kizuna）与 `research/voices-reddit.md` 做内容依据（呈報/叮囑/自首/早晚問安/日常禁慾/月历求饶-处罚等真实语言已吸收进 preference_items 与 idea_cards）。
- ⚠️ 偏差：04-explore.md 未写死 idea_cards 的语言字段落地字段名，采用 `titleZh/titleEn/howZh/howEn/needsZh/needsEn`（`_zh`/`_en` 对，API 全量返回两者，客户端自选）。
- ⚠️ 偏差：`wantAndOk` 桶 vs `someoneTalks`/`notDoing` 的优先级 04-explore.md 未逐条列出组合矩阵，按其"不变量补充"段落推断：`no` 最高优先级（永不归属到人），其次 `talk`（想聊置顶但不如"不要"敏感），再是 want∩want 与 want+ok。
- 验收：见 `ExploreIT.kt`——双答才互见（未互答条目在双方 `items()` 视图均不含对方答案）；`no` 从不归属到人（反射断言 DTO 字段）；四桶组合正确；单人 dynamic 空桶 + 标志位；卡片过滤（mutual-no 排除、talk 置顶）；`draw` 不入 outbox；`act(add_today)` 的 s→proposed / D→active+今日 occurrence；起步包 apply 精确匹配裁剪后的 draft（未落地字段真的不创建）；幂等重放不重复创建。
- 起步包 7 个的名字与内容为推断，已同步记入 `product/05-decisions.md` 待 owner 拍板列表。

客户端 ✅ 2026-09-03（`client/lib/features/explore/`；全仓 315 widget/unit 测试通过，`flutter analyze` 0 issues）
- 路由 `/dynamics/:id/explore?section=prefs|compare|cards` 一屏三段（偏好/对照/灵感卡），`/dynamics/:id/explore/packs` 起步包；规矩页四个入口词 + 底线段直接列 compare `notDoing`（只有标题，无归属）；规矩/任务皆空时顶部出「从一套开始」。
- ⚠️ 偏差：答题走 `PUT …/items/{id}/answer`（控制器如此，任务描述写的 POST 不存在）；s 的「提议给 D」复用 `act(add_today)`（后端按 side 原生落 proposed），无独立 propose 动作。
- ⚠️ 偏差：对照行的动词只做了「加到规矩 / 提议给 D」（走 RuleRepository.create），「加到今天 / 做成任务」未做——后端没有 item→task 端点，且卡片已覆盖该路径。
- 旧 `GET /v1/explore` 客户端（`explore_view.dart` + 旧 ExploreScreen）删除；`今晚要什么？` 在 D 今天 TodayMeta 下方，抽卡 sheet 可「再抽一张」。

## Phase 5 · 打磨（并行/收尾）
- widget（iOS/Android）与锁屏中性文案；导出；付费（单人解锁、免费不限条数）；`kind=measure` 曲线；主题。

后端 ✅ 2026-09-03（`64445c9`；全仓 215 测试通过）
- V21：`occurrences.value numeric(12,3)`。`POST /v1/occurrences/{id}/outcome` 接受 `value`：measure 任务交付时必填，非 measure 任务传值报错。
- `GET /record/series?taskId=&from=&to=` → `{taskId, unit, points:[{day,value}]}`（仅 delivered/delivered_late）。
- `GET /record/export?from=&to=&format=json|csv`（≤366 天，双方可导），内容只有事实字段（任务、结果、处置、数值、当天留言）。⚠️ 偏差：私密笔记完全不导出（含本人的），避免任何不对称。
- 锁屏/通知中性文案在 Phase 1 `OutboxDispatcher.neutralBodyFor` 已落，无新改动。

客户端 ✅ 2026-09-03（`004264c`；319 测试通过，`flutter analyze` 0 issues）
- s 今天：measure 任务交付弹数字输入（带单位），行内显示 `72.5 kg`。记录：`/record/series/:taskId` 30 天折线（CustomPaint，无新图表依赖）；当天条目「曲线」入口 + 记录页底部 measure 任务列表。
- 导出：记录页「导出记录」→ 90/30/365 天或自定义区间 → CSV 经 `share_plus` 分享。⚠️ 新增依赖 `share_plus`。

⏸ 推迟（写入 05-decisions 待拍板）：付费（单人解锁的定价/商店账号是外部事实）、桌面 widget（平台原生工程量大，锁屏文案已中性）、主题。

## 每个 Phase 的门
1. 对照 `05-decisions` 检查没有引入自动扣分/自动惩罚/审批计时。
2. 文案全部过一遍：没有系统替人说话的句子。
3. 关系日测试向量跑过（跨午夜、跨时区、改 day_start 当天）。
