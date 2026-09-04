# 05 · 决策记录

每条：决定 · 依据（原话 + 出处）· 证据强度。新决定往下追加，不改旧条；推翻用新条引用旧条编号。
强度：**强** = 多来源反复出现；**中** = 1–2 处明确；**推断** = 我们的推理，语料只间接支持，需要真实用户验证。

| # | 决定 | 依据 | 强度 |
|---|---|---|---|
| D-01 | 默认场景是"白天分开、晚上见面"的同居两人；异地/出差只是「D 是否在场」参数 | Obedience 200 评：异地 18 vs 同居/已婚/24/7 11 + ADHD 7（多为同居）；两类用户任务结构相同（competitors §2）；owner 修正 2026-09-02 | 强 |
| D-02 | 四个 tab：今天 / 规矩 / 记录 / 分 | owner 2026-09-02："三个 tab 不行，要 4 个"；规矩独立成 tab 依据 protocol-vs-task 帖（r/BDSMAdvice 1stmnh7, jobw50, 1kqqoav；PTT NECO「日常禁慾」；Kizuna「早晚問安」） | 中 |
| D-03 | 有提醒、有通知、有 widget | "I get a reminder at night… My Dom knows when I complete them as he gets an alert. It's exactly what we needed." (Obedience 5★ 2024-02)；ADHD "out of sight is out of mind"（widget 诉求）；推翻旧"不做提醒"红线 | 强 |
| D-04 | 计分，但**扣分只有人做**，系统只自动**加**分 | 正向最高频词 points/rewards；病在 "points are way too easy to earn… punishments… pile up"（Reddit）、"resets itself with the points daily… negative points"（Obedience 1★）；Our Dynamic 不计分 ≈ 零用户 | 强 |
| D-05 | 基础项默认 0 分（`points_earn=0`），加分项 D 明确设 | "base-level healthy habits shouldn't earn points, only failure punished"（Reddit 1 条回复） | 推断 |
| D-06 | s 交付立刻有回执「已送到」，D 打开有「看到了」 | "it would let you know it was received and is waiting approval from your Dom… From my end it looks empty." (Obedience 4★ 2025-04) | 强 |
| D-07 | D 的处置**永不过期、不计时**；D 缺席不产生任何债 | "If the dominant doesn't approve the task by the time… counts the task as incomplete. That's not at all how this should work" (Obedience 2★ 2024-02)；"my dom didn't approve it until after the due time so I got points docked" (5★ 2024-12) | 强 |
| D-08 | 没做有四个正规出口：做不了 / 求个新时间 / 想谈谈 / 我认，晚了；`missed` 是事实标记，无自动后果 | "if subs could request late tasks or send in late tasks for a penalty" (Obedience 5★ 2024-12)；Kizuna「就算當天課題沒完成，雙方也能在日曆裡留言『求饒』或『處罰』」；NECO 「自首」；Kneel 的 "automatic consequences when deadlines slip" 为反例 | 强 |
| D-09 | D 的处置五个词：看到了 / 很好 / 算了 / 补上 / 罚 | 用户要 Kneel 式 "acknowledged / actioned" 按钮；"I'm proud of you baby" 是人写的；五个词的具体选择是我们定的 | 中（词是推断） |
| D-10 | 惩罚只能 D 手动发，从模板库或自写；`Consequence.issued_by` 非空 | "we don't use the punishments" 多条；"don't know how punishments are triggered" (4★ 2024-03)；Kneel 自动后果被 D-07 同一批人反对 | 强 |
| D-11 | 记录 tab：日历 + 这一天时间线 + 两人留言 | Kizuna 月曆留言（唯一直接来源）；TPE Dom "at the end of the following day, have her kneel and go over what got complete"（Reddit，反 App 派但描述了同一动作） | 中 |
| D-12 | 私人备注（自己可见）、D 备忘（s 不可见） | "add something for the D to do/to remember/to remind" (Obedience 4 条)；D 备忘对 s 隐藏是推断 | 中 |
| D-13 | 单人付费解锁整个 Dynamic；免费层核心功能不限条数 | 37/200 条抱怨双人订阅与 5 条上限；"the App we're using has limited functionality so we can't do too many tasks at once"（Reddit）；Kizuna 免费起量；BeMoreKinky 付费墙 1★ 多条 | 强 |
| D-14 | 付费层只放：长期照片归档、曲线、导出、主题 | 推断：必须找到不伤核心循环的付费点 | 推断（需 owner 确认） |
| D-15 | 一天从几点算（`day_start`）可设，全部"今天"按 Dynamic 时区 | "I go to bed late and having to update the history for several of my tasks is annoying" (Obedience 4★ 2026-05)；数据错乱是 18 条 bug 差评主因 | 强 |
| D-16 | 循环任务不强制绑定具体时刻；`due_time` 可空 | Obedience 1★ 2026-05（循环任务必须绑时间）；"without the pressure of a deadline" (4★ 2024-05) → `open` 类任务 | 强 |
| D-17 | 问安是 `Task.kind=checkin`，一天可多次，一句话；砍掉情绪/精力量表 | Kizuna「每天早晚問安」；Kneel 每日多次 check-in；量表无人要 | 中 |
| D-18 | 文案用 D/s 词汇，语气 playful but serious；删所有"哲学"句子 | Obedience "devilish tone. It's playful but serious. It doesn't pretend to be anything it isn't"；Our Dynamic 反例 | 中 |
| D-19 | 设备锁 + 中性通知文案「{App} · 1 条新消息」 | Kneel 设备级私密锁被点名；Notes "discreet"（Reddit）；大陆用户零样本，私密权重可能被低估 | 中 |
| D-20 | 探索住在规矩里，今天顶部给 D 一个「今晚要什么？」入口；三层 = 比对 / 灵感卡 / 起步包 | owner："我们还有一个探索"；BeMoreKinky 评论（04-explore）；Obedience "templates… tailored them" | 中 |
| D-21 | 比对答完才互见；「不要」永不归属到人 | BeMoreKinky "matching activities" 是最大功能抱怨；不归属"不要"是安全设计推断 | 中 |
| D-22 | 探索全量免费，不做文章 | BeMoreKinky 付费墙 1★ 多条；文章仅 1 条正面 | 中 |
| D-23 | 起步包是可编辑草稿，不是选项 | "we took some of the templates and tailored them to what works for us" (5★ 2025-01) | 中 |
| D-24 | s 可 `proposed` 任务/规矩，D 接受后生效 | "limits can be established of who can edit what. It gives it yet another D/s feel." (Obedience 4★ 2025-04)；s 提议路径是推断 | 推断 |
| D-25 | 兑换需 D 批准；D 可自由裁量给分附一句话 | "the Dom could award reward points at his discretion" (4★ 2025-01)；奖励兑换需 Dom 批准 (4★ 2025-03) | 强 |
| D-26 | 按条暂停「需要 D 在场」的任务；D 一键「我不在」 | Day B（01-users）推断自 Obedience 异地评论 + "It helps us flip the switch back"；无直接原话 | 推断 |
| D-27 | Streak 只涨不跌显示"在一起的天数"；连续天数 `let_go` 不断 | SubTasks / Collared 都有 streak；`let_go` 不断是 D-07 的推论 | 推断 |
| D-28 | 砍：Weekly 回避式总结、Check-in 量表、Boundaries/Agreements/Us 页、旧 Explore 内容库、无 D 侧的 Attention 流 | synthesis D3；语料无一处要这些 | 中 |
| D-29 | 保留：occurrence 三态（→ 四个出口）、Response composer（→ 五个处置）、Waiting（→ 回执）、points ledger、ExploreLibrary 作为内容源 | synthesis D5 | — |
| D-30 | 不做：聊天、位置共享、贞操计时、co-dom / 多伴侣（v1） | 聊天有 9 条正面但每个手机都有 IM；co-dom 6 条，v2 再看 | 中 |

## 待 owner 拍板
- D-14 付费层内容
- D-05 基础项默认 0 分（可能让新用户觉得"没分"）
- 04-explore 起步包名单
- D-09 五个处置词的中文措辞
- 起步包 7 个的名字与内容为推断，待 owner 确认（内容在 backend/src/main/resources/explore/starter_packs.json，可直接改）
- Phase 5 推迟项（2026-09-03）：付费（单人解锁、免费不限条数——需要商店账号、定价、地区）、桌面 widget、主题。代码侧未做任何铺垫，决定后再开。
- 导出不含私密笔记（连本人的也不含），若要"只导本人私密笔记"需 owner 确认。
- 推送通知（2026-09-03）：无 FCM/APNs 凭证，先用轮询 + 本地通知。要即时推送需 owner 建 Firebase 项目并提供 `google-services.json` / APNs key。
- 任务改动权（推断）：只有 D 能直接改任务；s 改 = 提议一条新的。依据 competitors.md「limits can be established of who can edit what. It gives it yet another D/s feel.」

## D-31 · 不再显示连续天数（streak）· 2026-09-04 ·「推断」
Codex 评审与业主反馈都指出「0 in a row」是习惯打卡话术，与「不做游戏化喧闹」冲突；
服务端仍计算 streak（03-domain 不变），客户端任何页面都不展示。在一起的天数只在伴侣加入后显示。
详见 design/system/redesign-2026-09.md §3。

## D-32 · 每页一个 Cormorant 锚点，字级 44 · 2026-09-04 ·「推断」
业主：「不高级」；Codex：四页字级层级比 1.5–2×，命中 5–6 条模板特征。
决定每个 tab 只有一个 44px 的展示体锚点（Today/Record 是日期，Rules 是页名，Points 是分数），
其余全部 Inter 小字。覆盖 typography.md 早先「Today 用小号 Inter 标题」的做法。

