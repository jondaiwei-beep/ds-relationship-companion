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
后端
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

## Phase 2 · 记录（1–2 周）
- 日历（每天一格：交付数/未交付/有留言/有处置）、这一天时间线（occurrence + disposition + DayComment 按时间）。
- DayComment 双方；PrivateNote；照片/文字归档；streak 与 days_together。
- 周/月事实统计（数字，不评价）。
- 验收：晚上两人对着"这一天"收尾的脚本可走完；历史 `missed` 可补交付。

## Phase 3 · 规矩 + 分（1–2 周）
- Rule CRUD；Task 定义管理（含 per-item `paused_until`、D「我不在」一键）；s Proposal 与 D 接受。
- Reward 目录、Redemption 流程；ConsequenseTemplate 库；D 给/扣分附一句。
- 分 tab：余额、可兑换、申请、流水、规则可见。
- 验收：Day B（D 出差两周）脚本可走完，且 D 不在期间 s 的 streak 不断、无 missed 债。

## Phase 4 · 探索（1–2 周）
- 题库 + `PreferenceAnswer` + 比对视图（双答才互见、不归属「不要」）。
- IdeaCard 库 + 动作（加到今天/规矩、提议、试过了）；「今晚要什么？」入口。
- StarterPack 首日流程（可编辑草稿→一键启用）。
- 验收：首日路线（02-surfaces）10 分钟内走完并产生第一条 occurrence。

## Phase 5 · 打磨（并行/收尾）
- widget（iOS/Android）与锁屏中性文案；导出；付费（单人解锁、免费不限条数）；`kind=measure` 曲线；主题。

## 每个 Phase 的门
1. 对照 `05-decisions` 检查没有引入自动扣分/自动惩罚/审批计时。
2. 文案全部过一遍：没有系统替人说话的句子。
3. 关系日测试向量跑过（跨午夜、跨时区、改 day_start 当天）。
