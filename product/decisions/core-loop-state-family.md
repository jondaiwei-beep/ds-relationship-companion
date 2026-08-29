# SCR-02 / 33 / 03 · 核心闭环状态族(待批准)

Written 2026-08-30。**门禁未改动**,三个屏仍是 `blocked_alignment_required`。

产品的心脏。红线 #1 到 #3 全部住在这三个屏里,所以这里的每一条状态规则
都是行为约束,不是排版偏好。

## 三条不可让步的规则

**1. 完成永远不等于确认。** `REQ-COMPLETE-001`。
SCR-02 用一条两节点的进度线表达它:`COMPLETED` ●——○ `WAITING FOR MORGAN`。
这不是装饰 —— 它是这个产品与「打勾就完事」的待办应用之间的全部区别。
第二个节点在伴侣真正回应之前**永远不能填实**。

**2. 只有明确的人类 Send 才创建确认。** 红线 #1。
选择类型不发送;打字不发送;关掉界面不发送。**只有按下 Send 才发送。**

**3. 系统绝不以伴侣的口吻说话。** 红线 #2。
见下面「一个待裁定的设计冲突」。

## 服务端事实(已核实)

| 事实 | 值 |
|---|---|
| occurrence 状态 | `ACTIVE / WAITING_ACK / ACKNOWLEDGED / NEEDS_REVIEW / REVIEWED / NEED_TO_DISCUSS / RESCHEDULE_REQUESTED / EXCUSE_REQUESTED / EXCUSED / CANCELLED` |
| 完成非 ACTIVE 的 occurrence | 409 `OCCURRENCE_NOT_ACTIVE` |
| 确认非 WAITING_ACK 的 | 409 `OCCURRENCE_NOT_WAITING_ACK` |
| 已确认后再调整 | 409 `OCCURRENCE_ACKNOWLEDGED` |
| 四种响应类型 | `ACKNOWLEDGE / PRAISE / COMMENT / REVIEW` |
| 前两种可以无文字 | **是**(今日修复;此前 API 要求非空) |
| 后两种必须有文字 | 是,空的返回 400 `TEXT_REQUIRED` |
| 私密笔记 | 只返回给作者,伴侣读到 null(今日修复;此前谁都读不到) |

**三个冲突码都是实测的**,不是从异常类名推断的 —— 我用两个真实账号跑了一遍
「重复完成 / 重复确认 / 确认后再调整」。客户端必须按码区分,
因为它们对应三句完全不同的话。

## SCR-02 · 完成 → 等待响应

| 状态 | 看到什么 | 能做什么 |
|---|---|---|
| Default | 两节点进度线,`COMPLETED` 实心、`WAITING FOR MORGAN` 空心。「Your part is complete. Morgan's acknowledgement will appear here.」私密笔记字段 | 写私密笔记、返回 Today |
| Loading | 提交完成的过程中。主控件显示「Recording…」,不可二次按下 | 等待 |
| Empty | **N/A** —— 这个屏总有一个 occurrence |
| Error / retry | 提交失败:保留已写的笔记,提供重试。**笔记绝不因为一次网络失败而丢失** | 重试、返回 |
| **已被完成** | 409 `OCCURRENCE_NOT_ACTIVE`:另一台设备已经完成了。**不是错误** —— 显示为已完成状态并继续 | 返回 Today |
| **调整已关闭** | 409 `OCCURRENCE_ACKNOWLEDGED`:已经被确认了,不能再改。中性陈述 | 返回 |
| Offline | 「You're offline. Connect to the internet, then try again.」笔记保留 | 恢复后重试 |
| 授权丢失 | 移除所有关系内容,转到入口。**不说明是哪件事被中断** | 登录 |
| 已被确认 | 伴侣在此期间回应了:第二个节点填实,显示伴侣的回应 | 阅读、返回 |
| 角色变体 | 措辞随角色调整,**权利不变** —— 任何一方都能完成分配给自己的事 |

**私密笔记的两条规则**(今日核实):
- 伴侣**永远**读不到,任何界面都不行
- 作者**必须**能读回来。「ONLY YOU」既是隐私承诺,也是「你能看到」的承诺

## SCR-33 · 确认编辑器

| 状态 | 看到什么 | 能做什么 |
|---|---|---|
| Default | 四种类型一行:Acknowledge / Praise / Comment / Review。文字区。「Send to Morgan」。「Not now」 | 选类型、写字、发送、离开 |
| **两次点击** | 选 Acknowledge → Send。**无需任何文字。** `REQ-ACK-001` 要求如此 | — |
| Comment / Review 未填字 | Send 按下时解释需要文字并聚焦文字区。**服务端也会拒(400 `TEXT_REQUIRED`)** | 补字或换类型 |
| Loading | 「Sending…」,字段与类型锁定 | 等待 |
| Error / retry | **保留已写的文字**。重试是同一次尝试(幂等键) | 重试、Not now |
| **已被确认** | 409 `OCCURRENCE_NOT_WAITING_ACK`:另一台设备已经回应过。**不是失败** —— 显示已发出的那条回应 | 阅读、关闭 |
| **occurrence 不在等待中** | 同上 409。对方撤回或改期了。中性说明,不指责任何人 | 关闭 |
| Offline | 「You're offline.」文字保留 | 恢复后重试 |
| 授权丢失 | 清空草稿,转入口。**未发送的文字不得留在任何地方** | 登录 |
| Not now | 关闭。**不发送任何东西,也不记录「拒绝回应」** —— 沉默不是一种回应 |

## SCR-03 · 收到确认

| 状态 | 规则 |
|---|---|
| Default | 伴侣写的内容与系统文案**视觉可区分**(`REQ-ACK-001`)。有署名、有时间 |
| **无字的确认** | 渲染为中性的类型信号:**「Morgan acknowledged this.」** 不加引号、不编造措辞。这是红线 #2 在渲染层的落点 |
| Loading | 骨架保持版式稳定 |
| Empty | **N/A** —— 没有确认就不会进这个屏 |
| Error / offline | 读取失败:重试。不显示陈旧内容 |
| 授权丢失 | 移除全部内容 |

## 一个待裁定的设计冲突

SCR-33 的图上,文字区**预填**了「I noticed your care and intention tonight.」

能编辑不等于选择过 —— **按下发送通常被理解为接受默认值**,那就把系统的措辞
放进了伴侣嘴里,正是红线 #2 要防的事。

而这张图和**它自己的契约**冲突。`screen.md` 写着:

> suggested language is **visibly system-provided** until the human explicitly
> sends … system suggestions remain **visually subordinate**

一个点一下才采纳的建议 chip 两条都满足;直接躺在输入框里的散文两条都不满足。

**建议**:建议语做成输入框**外**的 chip,点击才插入,插入后可见可改。
这既保住了设计想要的体贴,又让「这些字是我选的」成为一个动作而不是一个默认。

**这是改已批准构图,归设计负责人。**

## 未覆盖

- **SCR-32 Attention 没有任何设计稿。** 给予方的日常入口,`REQ-ATTN-001`
- **`NEEDS_REVIEW`** 状态:`REQ-REVIEW-001` 说过期进入复核,
  且「软件不指派惩罚或后果」。三个屏都没有对应设计
- **Web 适配**:这些是 390 × 844
