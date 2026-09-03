# 04 · 探索（玩法怎么设计）

探索不是内容库，是**两个人一起决定"接下来试什么"的工具**。住在「规矩」tab 里，「今天」顶部给 D 留一个高频入口（今晚要什么？）。

## 依据

BeMoreKinky 是这个品类里唯一做"探索"的、有规模的产品（Play 10K+ 安装 / 474 评，iOS 4.6★ / 196）。它的用户评论说清了三件事——人们要什么、什么时候会走、以及它为什么和任务管理是两件事。（来源：Google Play / App Store 评论，2025-07 → 2026-08，抓取 47 条；全部原话）

**要什么**
- "We use it as a conversation starter and it's been fun so far." (5★ 2025-09-01)
- "It is fun and great for trying new things and **building anticipation**." (3★ 2026-06-11)
- "I love the ideas in the app! And learning more about my partner." (5★ 2025-11-19)
- "Lots of things to explore. Definitely helps me learn connect with my partner." (5★ 2026-08-07)

**为什么走**
- 双人比对做不好："the syncing between partners and their preferences doesn't work great. **Especially matching activities!**" (3★ 2026-06-11)；"If I view and compare quiz results with my partner, it doesn't back out correctly." (3★ 2026-03-24)
- 付费墙："You get a teaser and everything else is behind a paywall." (1★ 2026-06-21)；"you have to pay for everything" (1★ 2026-05-15)
- 内容重复 / 用尽："repeat featured quizzes" (3★ 2026-03-24)
- 答完不保存："don't save your preferences… it asked us to do the intro stuff all over again" (1★ 2025-12-20)

**和任务管理是两件事**：BeMoreKinky 用户抱怨 "Not earning points for habits either" (3★ 2026-06-11) —— 他们想在探索 App 里管日常，正如 Obedience 用户想在管理 App 里要"ideas or suggestions for limits, rules, punishments, tasks, and rewards… for those of us who are new" (4★, competitors.md §3)。两边各缺一半。我们把"决定试什么"和"每天做什么"接在一起：探索的产出直接变成 Task / Rule。

Obedience 的模板被用的方式："we took some of the templates and tailored them to what works for us" (5★ 2025-01) —— **起步包是拿来改的，不是拿来选的**。

## 三层

### 1. 两人比对（PreferenceCompare）

- 一个题库（`PreferenceItem`），按主题分组（服务与仪式 / 规矩与限制 / 感官 / 束缚 / 羞辱与语言 / 展示与着装 / 惩罚方式 / 奖励方式 / 场景……），支持自定义条目。
- 每人对每条独立答：`want / ok / no / talk`（想要 / 可以 / 不要 / 想聊）。答案自动保存，可随时改。
- **只有两人都答过的条目才互见。** 展示：
  - 「都想要」（want ∩ want）
  - 「一个想要、一个可以」
  - 「有人想聊」（任一方 talk）
  - **「不要」永远不归属到人**：显示为「这条不做」，不显示是谁选的。这是安全词/底线的自然来源（02-surfaces：底线 = 比对里的"不要"）。
- 每条比对结果上有动词：`加到规矩` / `加到今天` / `做成任务`（D）、`提议给 {D}`（s）。

### 2. 灵感卡（IdeaCard）

- 一张卡 = 一个可执行的小玩法，字段：`audience ∈ {for_d, for_s, for_both}, title, how (3–5 句), needs (道具/时间), intensity (1–3), tags, related_preference_ids`。
- 卡的动作，全部是动词：
  - D：`加到今天`（生成 one_off Task）/ `加到规矩`（生成 Rule）/ `存起来`（DNote）
  - s：`提议给 {D}`（Proposal）/ `存起来`
  - 两人：`试过了`（标 done，沉底；可评「再来 / 不再」）
- 只推荐比对里不是「不要」的卡；「想聊」相关的卡置顶。
- 「今晚要什么？」= 从 for_d / for_both 里按当前偏好抽一张，D 在「今天」顶部一键拿到。抽卡不通知 s，只有 D 把它变成 Task 才通知。

### 3. 起步包（StarterPack）

- 6–10 个包，每个 = 3–6 条 Task + 1–3 条 Rule + 2–3 条 Reward，全部预填成**可编辑草稿**，首日选一个后逐条改措辞、改时间、删掉不要的，再一键启用。
- 首批包（推断，需要你确认名字与内容）：日常问安 / 家务服务 / 身体与健康 / 着装与呈现 / 语言与称呼 / D 不在家时 / 新手第一周。
- 现有 `ExploreLibrary.kt` 的条目做为起步包与灵感卡的内容源，按上面字段重构。

## 不做

- 不做文章/教程（"Love the articles too!" 只 1 条；内容运营成本高，且是 BeMoreKinky 的付费墙所在）。
- 不做"匹配度百分比"这类分数。
- 不做按题库分页强制答完；任何时候可以只答 3 条就看交集。
- 不区分免费/付费题库；探索全量免费（付费墙是 BeMoreKinky 最大差评）。

## 对象（补 03-domain）

- `PreferenceItem: id, dynamic_id? (null=系统库), group, title, detail?`
- `PreferenceAnswer: item_id, member_id, answer ∈ {want, ok, no, talk}, updated_at`（唯一键 item+member）
- `IdeaCard: id, audience, title, how, needs?, intensity, tags[], related_item_ids[]`（系统库）
- `IdeaCardState: card_id, dynamic_id, status ∈ {saved, tried_again, tried_never}, by`
- `StarterPack: id, title, tasks[], rules[], rewards[]`（静态 JSON）

不变量补充：`PreferenceAnswer` 只在**双方都存在**时返回给对方；`no` 在对方视角永远聚合为「这条不做」，接口不返回 member_id。
