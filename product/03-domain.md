# 03 · 领域模型

开发照这个写。名词用英文标识符；状态机是硬约束；「不变量」违反即 bug。

## 对象

### Dynamic
一对关系。`id, timezone, day_start (hour 0–23, 默认 4), honorific_for_d, honorific_for_s, paused_at?, created_at`。
- **关系日** = `[day_start, 次日 day_start)` 按 `timezone`。所有"今天"以此计算。默认 timezone 取 s 的设备时区，D 可改。
- 最多两名 `Member`；可只有一名（对方未到）。

### Member
`user_id, dynamic_id, role ∈ {D, S}, display_name, joined_at, left_at?`。角色可由两人各自确认后互换（switch），不支持同时两个 D。

### Rule（常设规矩）
`id, dynamic_id, title, body?, group (protocol | ritual | restriction | appearance | reporting | other), created_by, active, position`。
- 不生成 occurrence；可被 `Consequence` 或 `DayComment` 引用。
- D 增删改；s 可发 `Proposal`。

### Task（任务定义）
`id, dynamic_id, title, detail?, kind, schedule?, due_time?, proof ∈ {check, photo, text, any}, points_earn (默认 0), requires_d_present (bool), paused_until? (null=不暂停, far-future=无限期), created_by, status ∈ {proposed, active, archived}, position`。
- `kind`：
  - `recurring`：`schedule` = 每天 / 周几集合 / 每 N 天；每关系日生成一条 occurrence（一天多次用 `times_per_day`）
  - `one_off`：只有一条 occurrence，`due_at?` 可空
  - `open`：自愿加分，无截止，可多次交付，每次一条 occurrence
  - `checkin`：问安，一天可多次，`proof=text`
  - `measure`：数值记录（体重/饮水），`unit`，用于曲线（v1.x）
- 由 s 创建的 `status=proposed`，D `accept` 后 `active`；D 创建直接 `active`。
- **暂停**：`paused_until` 期间不生成 occurrence；已生成的未交付 occurrence 标 `paused`。D 一键「我不在」= 对所有 `requires_d_present` 的任务设 `paused_until`。

### Occurrence（某一天的一条）
`id, task_id, dynamic_id, day (关系日), due_at?, outcome, outcome_at?, outcome_note?, proof_ref?, proposed_time?, disposition, disposition_at?, disposition_note?, consequence_id?, points_credited`。

**s 侧 outcome**（s 的动作，或系统在关系日结束时的事实标记）：
```
open ──deliver──▶ delivered            (勾 / 照片 / 文字)
open ──deliver after due──▶ delivered_late   (系统自动判断，s 也可主动选「我认，晚了」)
open ──cant_do(note)──▶ cant_do
open ──new_time(proposed_time, note)──▶ new_time_requested
open ──discuss(note)──▶ discuss_requested
open ──关系日结束，无动作──▶ missed        (系统标记的事实，无任何自动后果)
* ──D 暂停任务──▶ paused
```
- `delivered / delivered_late / cant_do / new_time_requested / discuss_requested` 在 D 处置前 s 可撤回改选一次。
- `missed` 之后 s 仍可 `deliver`（→ `delivered_late`）或 `cant_do`（补说明）。历史永远可补。

**D 侧 disposition**（独立轴，任何 outcome 之后都可做，**永不过期**）：
```
none ──▶ seen         看到了（无字）
none ──▶ praised      很好（可附字）
none ──▶ let_go       算了（这条不追究；不断 streak）
none ──▶ make_up(day) 补上（系统为该 task 在指定关系日生成一条新 occurrence，标 make_up_of）
none ──▶ punished     罚（必须关联一条 Consequence，issued_by = D）
```
- D 可以改处置（记录历史）。`new_time_requested` 的处置里 `make_up(day)` = 同意新时间。
- **回执**：s 侧 `outcome_at` 即显示「已送到」；D 打开该 occurrence 时写 `seen_at`（与 disposition 独立，仅"已读"），显示「{D} 看到了」。

### Consequence（罚）
`id, dynamic_id, issued_by (必须是 D), template_id?, title, detail?, occurrence_ids[], issued_at, status ∈ {issued, done_by_s, confirmed, waived}`。
- **系统永不创建 Consequence。** 没有任何自动路径。
- s 标 `done_by_s`，D `confirm` 或 `waive`。

### ConsequenceTemplate（惩罚库）
`id, dynamic_id, title, detail, created_by`。只是模板。

### Reward / Redemption
`Reward: id, dynamic_id, title, cost_points? (null = D 决定), created_by, active`
`Redemption: id, reward_id, requested_by (S), status ∈ {requested, approved, denied, fulfilled}, decided_by, note`
- `approved` 时扣分（ledger 条目 `redemption`）；`denied` 不扣。

### PointsLedger
`id, dynamic_id, member_id (S), amount (±), reason ∈ {task_earn, d_award, d_deduct, redemption, redemption_refund}, ref_type, ref_id, by_user_id, note, created_at`。
- `task_earn`：occurrence 变为 `delivered` 时，若 `task.points_earn > 0` 自动入账（唯一的自动入账；是给分不是扣分）。`delivered_late` 不自动入账，由 D 处置时决定 `d_award`。
- **扣分只有 `d_deduct` 和 `redemption`，都是人做的。**
- 余额 = Σ amount，不会因日期变化重算。

### DayComment（这一天上的留言）
`id, dynamic_id, day, author_id, body, created_at`。两人都可写，双方可见，不可编辑可删除（保留删除痕迹）。

### PrivateNote
`id, dynamic_id, day, author_id, body`。只作者可见，永不共享。

### DNote（D 的备忘）
`id, dynamic_id, author_id (D), body, remind_at?, done_at?`。s 不可见。

### Proposal（s 的提议）
`id, dynamic_id, kind ∈ {task, rule}, payload, status ∈ {open, accepted, declined}, note`。D 处理。

### Streak
派生，不存：`days_together` = 自两人都加入起的关系日数（只涨）；`current_streak` = 连续满足「当日所有非 open、非 paused 的 occurrence 均为 delivered / delivered_late / let_go / make_up 已安排」的关系日数。`missed` 且未 `let_go` → 断。

### Explore 相关对象见 `04-explore.md`。

## 权限

| 动作 | D | s |
|---|---|---|
| 建/改/停/归档 Task、Rule、Reward、ConsequenceTemplate | ✓ | 提议（Proposal） |
| 交付 / 做不了 / 求新时间 / 想谈谈 / 认晚 | — | ✓ |
| 处置（seen/praised/let_go/make_up/punished） | ✓ | — |
| 发 Consequence、confirm/waive | ✓ | 标 done |
| 给分/扣分 | ✓ | — |
| 兑换申请 / 决定 | 决定 | 申请 |
| DayComment | ✓ | ✓ |
| PrivateNote / DNote | 各自 | 各自 |
| 暂停整个 Dynamic / 离开 | ✓ | ✓ |
| 改 day_start / timezone / 称呼 | ✓ | 提议 |
| 探索作答 | ✓ | ✓ |

## 不变量（违反即 bug）

1. **系统从不替伴侣开口**：任何面向对方显示的评价性文字（很好、算了、罚、留言）都有 `by_user_id`，且是那个人主动写/点的。系统自己的文字只陈述事实（已送到、看到了、missed）。
2. **没有自动后果**：`Consequence.issued_by` 非空且为 D；`PointsLedger.amount < 0` 的条目 `by_user_id` 必为人。`missed` 不触发任何写操作。
3. **处置永不过期**：任何历史 occurrence 都可处置；没有"审批截止"字段。
4. **回执先于处置**：s 交付后 200ms 内本地即显示「已送到」（乐观更新），失败必须回滚并明示。
5. **历史可补**：`missed` 之后仍可 deliver / cant_do；补的动作带真实时间戳，不伪装成按时。
6. **暂停不产生债**：`paused` 的 occurrence 不计入 streak、不显示为 missed。
7. **一天只有一种算法**：所有"今天/这一天"按 `Dynamic.timezone + day_start` 计算，客户端不得用设备本地日期。
8. **私密**：`PrivateNote`、`DNote` 任何 API 不向对方返回；通知中性模式下正文不含任务内容。
9. **单人可用**：Dynamic 只有一名成员时，所有 s 侧或 D 侧功能照常，只是对方位空。
10. **不限条数**：免费层对 Task/Rule/Reward 数量无上限。
