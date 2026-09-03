# 综合：人物、一天、现有 App 的对照、结论

2026-09-02。基于 `competitors.md` / `voices-reddit.md` / `voices-zh.md`。每一条人物特征、每一步日脚本后面都标了来源；没有来源的地方我写"（推断）"。这份文档是**结论**，不是计划；等你拍板方向后才动 `product/`、`design/`、代码。

---

## A. 语料里真实出现的四类人

不是我设计的 persona，是语料自己分成了这四堆。按出现频率排。

### A1. 「开关型」同居夫妻 —— 最大一堆
- 结婚/同居多年，工作日各忙各的，晚上和周末在一起。"80% of the time we act just like a normal couple… when he pulls out the stern voice… it's time to submit" (ditcqv)。"My wife and I don't even use it for kink (yet)" (Obedience 5★)。"It helps us flip the switch back" (Obedience 4★)。
- 现实会淹没动态：小孩、争执、工作。"婚後有小孩，是連性生活都不見得有" (PTT M.1623768445)；"吵架火大時，誰還鳥你什麼SM啊" (M.1692450642)；"It only ended because of children" (11qh7gs)。
- Dom 有主业、精力有限："His life is busy with work and other interests, while BDSM is just one part of it for him" (1kmflra)；"he tends to be busy and isn't always available to ask" (11qh7gs)。
- 他们要的不是 24/7 协议，是**低成本把动态拉回日常的开关**。

### A2. 「结构型」sub（常伴 ADHD/神经多样性），Dom 是同居伴侣或每天见面的伴侣
- "As someone with ADHD having a widget… out of sight is out of mind" (Obedience 5★)；"We used to just text/note share my tasks, but I have ADHD & would often forget" (4★)；"Task management can be a huge chore especially for the neurodivergent brain" (4★)；Kneel "great for people who have ADHD" (5★)。
- 任务多为生活自理：喝水、吃药、洗澡、瑜伽、体重（Kizuna 的體重/飲水折線圖；Obedience "Yoga is on mine"）。
- 动力来源是被看见："knowing my Dom can see what I've done each day gives me a sense of accountability" (4★ 2026-05)；"'I'm proud of you baby' my entire day changes" (5★)。
- 痛点：忘了自己有没有交（"From my end it looks empty"）；Dom 审批慢导致被扣分。

### A3. 「异地/轮班」动态 —— 存在但不是默认
- Obedience 200 条里明确提异地 18 条；Reddit 自建工具者是 LDR (jsxbjq)；"we don't live together full-time" (4★)。
- 特有需求：时区/一天何时开始；Dom 缺席时任务照常计数（1668i0b 的 2100 spanks）；"punishments don't always happen immediately, so they end up piling up" (1tpahji)。
- 与 A1 的区别只是**谁在场**；任务结构一样。

### A4. 「重结构」24/7 / M/s —— 声音最大，人数最少
- "He chooses my clothing… permanent collar… list of chores day-to-day" (11qh7gs)；NECO 的按小时日程 + 双主人 (PTT)。
- 论坛里被感知为"主流"，但自认多数的人说这是幻觉 (ditcqv 61 分)。从零写规则表的新手被社区打回 (136xgno)。
- 他们已经有系统（Notion、Sheet、纸笔），换工具意愿低；"Ditch the apps completely" 的声音来自这里。

**Dom 侧（横跨四类）**：想要"被通知、不用记"（1tqzddo），想要减负和被服务（1kmflra），想要自己的待办（Obedience 4★ 2026-01），不敢/不知道问自己想要什么（1kmflra 29 分；PTT M.1626339065），心软（1tpahji "I am a softie"）。Kizuna 作者总结为**「日常管教上的踏實感」**。

---

## B. 两条从语料长出来的一天

### B1. A1/A2 混合：同居、白天分开、sub 有 ADHD、Dom 上班
| 时间 | 发生了什么 | 依据 |
|---|---|---|
| 07:10 | sub 起床，手机锁屏/桌面 widget 上就有今天的 3 件事：吃药、喝水 2L、晚饭前把厨房收好 | "widget… out of sight is out of mind"；jsxbjq 每天早上 3 件事 |
| 07:30 | Dom 出门前顺手加一条："今晚 9 点跪着汇报" 或什么都不加 | TickTick "I can add stuff for him throughout the day"；jobw50 protocols |
| 12:40 | sub 吃了药，一拍/一勾。**立刻看到"已送到，等 TA 看"** | "let you know it was received and is waiting approval… From my end it looks empty" |
| 14:00 | Dom 开会间隙收到通知，两下点完"看到了/很好"。**不被计时，不因为晚看而扣 sub 的分** | "should be able to trust the submissive enough to review at the dominant's convenience"；"my dom didn't approve it until after the due time so I got points docked" |
| 18:30 | sub 今天厨房没收，主动写："没做，下午头疼，明天补" | NECO「若有無法完成任務之原因 需告知主人事情緣由」；"if subs could request late tasks or send in late tasks for a penalty" |
| 21:00 | 两人都在家。Dom 打开今天这一天的记录，当面处理：哪条"算了"、哪条"补上"、哪条"罚" | Kizuna「在日曆裡留言求饒或處罰」；"kneel and go over what got complete" |
| 21:10 | Dom 给一个 sub 够得着的目标（"这周全勤 → 周末选餐厅"） | Kizuna 獎勵商店「一份大餐」；"the Dom could award reward points at his discretion" |
| 周日 | 两人看一眼这周，Dom 顺手改规则："喝水不算分了，不喝才扣" | "base-level healthy habits shouldn't earn points, only failure punished"；"revamped the list… every year" |

### B2. A3：Dom 出差两周
| 时间 | 发生了什么 | 依据 |
|---|---|---|
| 出差前 | Dom 一键"我不在，暂停需要我在场的那些" | "There is a reason why in the obedience app there is an option to pause a habit" |
| 期间 | sub 继续做能做的；做不了的直接标"做不了：你不在" | 1668i0b 楼主"I just expected him to have realised" |
| 期间 | Dom 时区不同，晚看 8 小时不影响任何计分 | "option to change the time of day a new day starts" |
| 回来 | 两人对着这两周的记录一起过，惩罚是**人当面定**的，不是系统累加的 2100 下 | 1668i0b 174 分"Accountability has to come from both sides" |

---

## C. 拿现有 App 对着 B1 走一遍

现有壳：五个 tab **Today / Dynamic / Points / Explore / Us**；屏幕：激活向导、邀请/加入、Today、Occurrence 详情、Create expectation、Response composer（Acknowledge/Praise/Comment/Review）、Attention、Waiting、Check-in、Weekly、Boundaries、Pause、Points、Settings/Leave。

| B1 步骤 | 现有 App | 判定 |
|---|---|---|
| 07:10 widget/锁屏看到今天 3 件事 | 无 widget、无提醒（旧红线"no reminders"）。Today 有 "ONE THING MATTERS / 01 · NOW" | ✗ 缺。A2 用户明确要 |
| 07:30 Dom 顺手加一条 | Create expectation 存在，但 D 侧循环（acknowledge/resolve）在当前客户端**不可达**；Dom 没有"我的今天" | ✗ 半残 |
| 12:40 勾掉 + 看到"已送到" | Waiting 屏 "Your service is recorded. / Waiting for {name}"——**这一步现有 App 做对了**，且比 Obedience 好 | ✓ 保留 |
| 14:00 Dom 两下点完，不计时 | Response composer 两下"Acknowledge" ✓；无审批截止 ✓。但入口在 Attention 屏，D 侧当前进不去 | ✓ 概念对，✗ 不可达 |
| 18:30 sub 说"没做，明天补" | 有 Discuss / New Time / Can't Do 三态 ✓（"asked to discuss / asked for a new time / said they can't do this"） | ✓ 这是我们比竞品都强的地方 |
| 21:00 当面处理一天的记录 | 没有"这一天"的视图；Occurrence detail 是单条；Weekly 是周总结，措辞极度回避（"That is a fact about the week, not about either of you"） | ✗ 缺"日历上的一天 + 留言" |
| 21:10 给个够得着的目标 | Points 有 give/take/history，但**没有奖励目录/兑换**；"consequence" 有 12 个字串但无 UI 触发 | ✗ 半残。用户最高频正向词是 rewards |
| 周日改规则 | Weekly 只有 Keep / Pause 两个选项 | ✗ |
| B2 出差暂停 | Pause 是整个 Dynamic 一起停（"Nothing is expected of either of you"），不能只停需要 Dom 在场的那几条 | ✗ 粒度错 |
| 私密 | 有 private entrance / app lock 的需求文档；Today 有 "PRIVATE BY DEFAULT" | ✓ 方向对 |
| Check-in | 情绪/能量/需要 五选一，可私密可分享 | ？语料里 check-in 是"每天多次问安"（Kneel 4★、Kizuna 早晚問安），不是情绪量表。现有设计是我们的假设 |
| Explore | 内容库 | ？语料要的是"模板帮新手起步 + 自己改"（Obedience 5★ 2025-01），不是浏览 |
| Boundaries / Us / Agreements | 存在 | 语料里无人提及。不是不重要，是没人为此选工具 |

**文案层**：现有全部字串都在回避 D/s 词汇和评价（"You are seen." "Nothing was completed or answered. That is a fact about the week, not about either of you."）。语料里用户喜欢的语气是 Obedience 的 "**devilish tone. It's playful but serious. It doesn't pretend to be anything it isn't**"。我们的 Our Dynamic 式"praise over points"文案有一个真实对照组：零用户。

---

## D. 结论

### D1. 之前四条红线 vs 语料
| 旧红线 | 语料怎么说 | 结论 |
|---|---|---|
| 系统不替伴侣说话 | 没人反对；"'I'm proud of you baby'" 是人写的 | **保留**，且是唯一没被语料打脸的 |
| 不做提醒 | ADHD 用户全靠提醒/widget；Dom 侧要"被通知" | **废除** |
| 反游戏化/不计分 | points/rewards 是最高频正向词；病在设计（基础项给分、堆积），不在计分本身 | **废除**，改成"Dom 定的分，系统不自动扣" |
| 调整只讨论不批准 | Discuss/New Time/Can't Do 三态是我们最好的部分；但 Dom 需要能"算了/补上/罚"落地 | **保留三态，补 Dom 的处置** |
| 默认异地 | 异地 18 vs 同居+已婚+ADHD 更多；且两者任务结构一样 | **改为默认"白天分开的同居"**，异地只是"谁在场"的参数 |

### D2. 产品命题（一句话，供你否决）
**一个给"白天分开、晚上见面"的 D/s 两人用的日常记录：sub 做了什么立刻有回执，Dom 什么时候看都不迟，没做的可以说原因，晚上两人对着这一天的记录当面收尾；分和罚由 Dom 一个人定，系统只记账、只提醒、从不替人开口。**

差异化不在功能清单（Obedience 功能比谁都多），在三件竞品**结构上**做不到的事：
1. 审批**不计时**、Dom 缺席不产生债（Obedience/Kneel 的 automatic consequences 是反面）
2. 未完成有**正规出口**（求饒/迟交/做不了/自首），且落到"那一天"的记录上，两人能在上面说话
3. **单方付费、免费不限条数**（37/200 条抱怨的直接反面；Kizuna 免费也能起来）

### D3. 要砍/要缩的
- Check-in 情绪量表 → 缩成"问安"（早/晚一句话 + 可多次）
- Weekly 的回避式总结 → 变成日历/时间线，Dom 能在任何一天上留言
- Explore → 起步模板（可改），不是内容库
- Boundaries/Agreements/Us → 降为设置页，不占 tab
- 全部"哲学"文案与注释 → 删；语气向 "playful but serious" 靠

### D4. 缺口，如实说
- 大陆用户零样本。命题里"私密"权重可能被低估。
- Dom 侧的一手声音仍少（评论区多是 sub 写的）。1kmflra/Kizuna/PTT 男 S 三处一致指向"减负 + 被服务 + 不必自己想"，但样本薄。
- 我没读 jobw50/1kqqoav（ritual/protocol 帖），"问安/仪式"这块具体形态还是靠 Kneel 评论和 Kizuna。

### D5. 我建议的下一步（等你一句话）
如果你认可 D2：删 `product/`、`design/`，写五份小文档（thesis / users / day / surfaces / decisions），代码层面保留 occurrence 三态 + Waiting/Response 这条链，其余（Weekly、Check-in、Explore、Boundaries、Points 现状）按新文档重做。如果你不认可 D2，告诉我哪一条，我回语料里找依据或找反证。
