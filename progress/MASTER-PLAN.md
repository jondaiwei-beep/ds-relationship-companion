# 整体研发计划 · 一期 / 二期

Written 2026-08-29. 这是**待确认稿** —— 每个条目需要你逐项过一遍再执行。
现状请读 `progress/STATE.md`，本文件只谈"接下来做什么、做到什么程度"。

---

## 0. 先说结论：真正的瓶颈在哪

| | 数量 | 说明 |
|---|---|---|
| 后端接口 | **33 个，全部完成** | 189 测试，完整闭环跑通 |
| 数据层仓库 | **12 个，全部完成** | 覆盖每一个 Core Beta 界面 |
| 设计系统 | **冻结完成** | 33 SVG · B-2 tokens · B-4 grain · 8 字号角色 · 2 主题 |
| 已建成屏幕 | **1 / 35** | 只有 SCR-01 Today |
| 设计门禁开放 | **1 / 35** | 28 个 `blocked_alignment_required` |
| **App 外壳** | **不存在** | `main.dart` 是预览器，无路由、无登录、无导航 |

**所以：不是后端缺功能，是前端只有一个屏，而且没有壳把它们串起来。**
第二个卡点是设计门禁 —— 28 个屏卡在审批，不是卡在画图。

设计成熟度实测（决定了哪些屏"现在就能建"）：

| 成熟度 | 屏幕 | 能否开工 |
|---|---|---|
| 完整状态族 + QA 文档 | SCR-01 | ✅ 已建成 |
| 有 candidate + 部分状态渲染 | SCR-09(3态) · SCR-10(2态) | ⚠️ 补齐状态即可开 |
| 只有 candidate，无状态渲染 | SCR-02 · 07 · 08 · 12 · 33 | ⚠️ 需补状态族 |
| 只有一张参考图 | 其余 22 屏 | ❌ 需先做设计 |
| 无图 | SCR-32 Attention · SCR-34 时区 | ❌ 设计从零开始 |

---

## 1. 一期（Core Beta）—— 目标：First Connected Dynamic Day

**一期的验收定义（唯一标准）**：
> 两个真人，一个 Android 一个 Web 浏览器，各自注册、配对成功、
> 一方完成一个 Expectation、另一方**手动**发出 Acknowledgement，
> 双方都在自己设备上看到这个闭环。

达不到这个，一期就没完。这也正好是产品文档里的
`FLOW-ACTIVATE-001` + `FLOW-RECEIVE-001` 最小合集。

一期共 **6 个 Sprint**。

### Sprint 1 · App 外壳与会话（前端基建）

这是当前最大的技术债，也是所有屏幕的前置条件。没有它，第二个屏
无处安放。

| 任务 | 交付标准 |
|---|---|
| T1.1 路由骨架 | go_router 路由表，含 deep link（邀请链接必须能直接落地） |
| T1.2 会话层 | `platform/session/` 现在是**空目录**。token 存储、刷新、过期跳转 |
| T1.3 认证守卫 | 未登录 → 入口屏；授权丢失 → 安全落地，不泄露关系内容 |
| T1.4 底部导航提升 | 从 `today_screen.dart` 提升为共享组件（8 个屏引用 nav 资源，二次使用是事实不是猜测） |
| T1.5 真实 `main.dart` | 替换预览器；预览器保留为 `main_preview.dart` |
| T1.6 修部署 + 连产品环境 | 修 `deploy-ds.sh` 的仓库地址，重新部署 staging，验证 `/v1/auth/register` 返回 400 而非 401。之后打包一律带 `--dart-define=API_BASE_URL=https://ds-api.beforeweplay.com` |

**已实测**：staging `ds-api.beforeweplay.com` 健康、CORS 正确、域名可用。
客户端 API 地址本来就是 `--dart-define` 构建参数（`client/lib/app/providers.dart:19`），
所以「打包连产品环境」是两个构建标志，不是代码改动。

**风险**：staging 在跑旧 jar（TD-04/TD-16），修好才能真机验收密码注册。

### Sprint 2 · 进入与认证（SCR-04/05/06）

| 屏 | 状态 | 前置 |
|---|---|---|
| SCR-04 私密入口 | 只有参考图 | **需设计状态族** |
| SCR-05 登录 | 只有参考图 | **需设计状态族** |
| SCR-06 注册 | 只有参考图 | **需设计状态族** |

后端 `/register` `/sign-in` `/magic-links` `/refresh` `/logout` 已就绪。
`REQ-TRUST-001`：入口必须中性表达 18+、条款、隐私、默认私密。

**这一 Sprint 前半段是设计工作，不是编码。** 需要先出 3 个屏的
状态族（default / loading / error / offline），再进 gate，才能建。

### Sprint 3 · 激活与配对（SCR-31/07/08/12）

| 屏 | 设计现状 |
|---|---|
| SCR-31 目标选择 | 单张图，无 candidates 目录 |
| SCR-07 角色定位 | rev-2 candidate，缺状态 |
| SCR-08 关系结构 | rev-2 candidate，缺状态 |
| SCR-12 起始节奏 | candidate，缺 replace/edit 交互态 |

后端 `/dynamics` `POST /starter-rhythm` 已就绪。
`REQ-ACT-001`：先问想要什么结果，再问角色 —— 顺序不能反。

### Sprint 4 · 邀请与加入（SCR-09/10/11）

这是**跨设备的第一次真实握手**，也是一期风险最高的一段。

| 屏 | 设计现状 | 备注 |
|---|---|---|
| SCR-09 邀请伴侣 | 3 个状态渲染 ✅ | 缺 share/copy、loading、offline、授权恢复 |
| SCR-10 Web 加入 | 2 个状态渲染 ✅ | 缺 revoked/stale、loading、offline |
| SCR-11 双方同意 | 仅参考图 | 需设计 |

`REQ-INVITE-001`：Pending / Accepted / Expired / Revoked 四态必须
从服务端解析，**不允许出现不透明 404**。
`REQ-JOIN-001`：被邀请方不重复走创建者的完整 onboarding。

**这一 Sprint 结束时应能：Android 发邀请 → 真实浏览器打开 → 加入成功。**

### Sprint 5 · 日常闭环（SCR-02/33/03 + SCR-32）

产品的心脏。红线就在这里。

| 屏 | 红线 |
|---|---|
| SCR-02 完成→等待响应 | `REQ-COMPLETE-001` 完成**永远不等于**被确认，必须是独立的"等待人类响应"时刻 |
| SCR-33 确认编辑器 | **核心红线**：只有明确的人类 Send 才产生 Acknowledgement。系统绝不以伴侣口吻说话 |
| SCR-03 收到确认 | 伴侣写的内容必须与系统文案视觉可区分 |
| SCR-32 Attention | **无设计图**，给予方的日常入口，`REQ-ATTN-001` |

SCR-01 已支持 Complete / Discuss / New Time / Can't Do 四个动作并已联调。
本 Sprint 补上"另一端"。

### Sprint 6 · 一期收尾与真机验收

| 任务 | 交付标准 |
|---|---|
| T6.1 端到端真机走查 | Android 真机 + iPhone Safari，两个真实账号 |
| T6.2 恢复态全覆盖 | `REQ-RECOVERY-001`：每个已建屏都有 loading/empty/error/offline/stale/授权丢失 |
| T6.3 幂等验证 | `REQ-IDEMP-001`：Join/Complete/Acknowledge/调整/Pause/Leave 重试只产生一次业务转移 |
| T6.4 Web 端验证 | 刷新、后退、直接 URL 三件事必须正确 |
| T6.5 打包 | Android release APK + Web 部署 |

---

## 2. 二期（Core Beta 完整 + Public MVP 起步）

一期只覆盖了"能连上并跑通一天"。二期覆盖"能长期用下去"。
共 **5 个 Sprint**。

### Sprint 7 · 任务与期望管理（SCR-19/20/14/13）
Task List · Create Task · Task Detail · Dynamic Overview。
后端 `POST /expectations` `GET /occurrences/{id}` 已就绪。

### Sprint 8 · 反思与检查（SCR-22/23/24）
Write Reflection · Weekly Check-in · Pause Check-in。
`REQ-WEEKLY-001`：D7 只做 Keep/Adjust/Pause 一个轻量面，**不做评分**。
`REQ-PAUSE-001`：Pause 不产生递归 backlog，Resume 不要求补旧任务。

### Sprint 9 · 关系档案与历史（SCR-17）
Us Relationship Profile。`REQ-HISTORY-001`：系统提醒**不得**被呈现为
"连接时刻"。

### Sprint 10 · 通知、隐私与设置（SCR-25/26/28/29/30/34）
| 屏 | 备注 |
|---|---|
| SCR-25 通知 | 后端 `LoggingNotificationChannel` **只打日志**，无真实投递 |
| SCR-26 隐私边界 | `REQ-PRIVACY-001` 三态可见性 |
| SCR-28 账号设置 | 含 Leave（无需伴侣批准）|
| SCR-29 通知节奏 | Quiet Hours |
| SCR-30 配对管理 | 含 Block |
| SCR-34 时区/日界 | `REQ-TIME-001` DST 不得静默移动关系日 |

### Sprint 11 · 推送投递（技术）
FCM 真实投递替换 `LoggingNotificationChannel`；Web Push 在
`webPush` flag 后面。**阻塞于你提供 FCM 凭据**。

### Sprint 12 · 二期收尾
全量恢复态、性能、真机回归、发布。

**Public MVP 屏（SCR-15/16/18/21/27）不在一期二期范围**，
产品文档已明确列为 `future_reference`。

---

## 3. 技术任务清单（Bug / 缺失组件 / 技术债）

代码里 **零 TODO / FIXME**，债不在注释里，在结构里。

### 🔴 阻塞级

| ID | 项 | 说明 |
|---|---|---|
| TD-01 | **无 App 外壳** | 无路由、无导航、无认证守卫。`main.dart` 是预览器 |
| TD-02 | **`platform/session/` 空目录** | 无 token 生命周期管理 |
| TD-03 | **`platform/deeplink/` 空目录** | 邀请链接无法落地 → Sprint 4 直接卡死 |
| TD-04 | **deploy-ds.sh 指向旧仓库** | 🔴 实测发现：脚本 clone `JonDai/dsapp`，实际仓库是 `jondaiwei-beep/ds-relationship-companion`。**staging 正在部署一个陈旧 jar** —— `/v1/auth/register` 线上返回 401，但当前源码里它是 `permitAll` |
| TD-05 | **28 个屏门禁未开** | 需产品/设计负责人逐屏审批。绝不自行修改 gate |
| TD-16 | **staging 跑的是旧构建** | TD-04 的后果。密码注册（V9）线上不可用，真机连产品环境前必须先修 |

### 🟠 功能缺失（非 bug，是未建）

| ID | 项 | 说明 |
|---|---|---|
| TD-06 | `platform/push/` 空 + 后端只打日志 | 真实推送不存在。阻塞于 FCM 凭据 |
| TD-07 | 共享组件层为空 | 10 个组件契约已写（`design/components/CONTRACTS.md`），零提升。**按需提升，不预先猜 API** |
| TD-08 | 无 CI | 无自动化流水线，`foundation:check` 只在本地跑 |
| TD-09 | 无 E2E 测试 | 跨设备闭环无自动验证 |
| TD-10 | Explore 是 placeholder | `explorePlaceholder` flag，Public MVP 才做 |

### 🟡 待决策 / 小债

| ID | 项 | 说明 |
|---|---|---|
| TD-11 | 两个提案 token 未定 | `display.expectation` 28/31、`body.support` 12/17 当前是内联覆盖 |
| TD-12 | G-1..G-4 三个待确认位 | `product/domain/g1-g4-implemented-answers.md` |
| TD-13 | SCR-01 四个状态缺 QA 证据 | offline / 授权丢失 / role-variant / solo 已实现但无渲染证据 |
| TD-14 | Android 未做渲染验证 | 只在 Flutter Web 渲染过；真机是肉眼验收，非像素比对 |
| TD-15 | 无错误上报 | 生产环境无崩溃/异常收集 |

---

## 4. 设计稿盘点

仓库里的设计资产实际情况：

```
design/
├── reference/webp/v1/    10 个参考板（86 webp）—— 原始视觉基线
│   ├── 00 Visual Baseline
│   ├── 01 Access and Authentication
│   ├── 02 Role and Pairing Setup
│   ├── 03 Pairing Consent and Foundation
│   ├── 04 Core Relationship
│   ├── 05 Reflection Us Explore
│   ├── 06 Tasks and Agreement Review
│   ├── 07 Reflection Check-in and Consent
│   ├── 08 Notifications Privacy and Subscription
│   └── 09 Account Notification and Pairing
├── screens/SCR-00..34/   35 个屏目录，每个含 screen.md 契约
├── assets/svg/           33 个冻结 SVG master
├── assets/fonts/         7 个 ttf（Cormorant Garamond + Inter）
├── tokens/               B-2 冻结 + Flutter/Web 生成绑定
├── components/           10 个组件契约
└── qa/                   渲染证据
```

**关键区别 —— 参考图 ≠ 可施工设计稿：**

| 类型 | 数量 | 能否直接建 |
|---|---|---|
| 完整状态族（8 态 + QA 文档） | 1（SCR-01） | ✅ |
| candidate + 状态渲染 | 2（SCR-09 三态、SCR-10 两态） | ⚠️ 补齐即可 |
| 仅 candidate 无状态 | 5（SCR-02/07/08/12/33） | ⚠️ 需补状态族 |
| 仅单张参考图 | 25 | ❌ 需设计 |
| 完全无图 | 2（SCR-32 Attention、SCR-34 时区） | ❌ 从零设计 |

**结论：25 个屏的"设计稿"其实只是参考图。** SCR-01 之所以能建，
是因为它有完整状态族 + `design-qa.md` 验收标准 —— 那才是可施工的标准。

---

## 5. 每个功能"做到什么程度"

避免失控的关键。每个屏的完成定义统一为六条：

1. 有**完整状态族**：default / loading / empty / error+retry / offline / 授权丢失
2. 按**设计图**建（图是规格，JSON 契约说什么必须为真，图说长什么样，**先读图**）
3. **接真实服务端**，不留 fixture
4. **不变量写成测试**（参考 `product/ui-invariants.md`）
5. **渲染证据**存在 `design/qa/implementation/SCR-XX/`
6. `npm run foundation:check` 通过（无裸 hex、无临时间距、无平行 token 层）

**六条缺一条，就不算完成。** SCR-01 是这个标准的样板。

---

## 6. Owner 已决策（2026-08-29）

| # | 事项 | 裁定 |
|---|---|---|
| D1 | CORS 允许来源 | **不是问题。** 产品环境不存在此问题；测试一律由我打包连产品环境数据。已实测：staging `ds-api.beforeweplay.com` 的 CORS 已正确配置 |
| D3 | 25 个屏谁出状态族 | **找 Codex 讨论产品需求。** 已按此执行，首个产出见 `product/decisions/guest-preview.md` |
| 新增 | **访客预览** | 新增需求，已完成产品评审，见下 |

### 仍需你裁定

| # | 事项 | 影响 |
|---|---|---|
| D2 | 门禁开放顺序 —— 建议按 Sprint 顺序批 | 阻塞除 SCR-01 外全部 34 屏 |
| D4 | FCM 凭据 | 阻塞 Sprint 11 |
| D5 | 两个提案 token 采纳与否 | 影响 SCR-02 / SCR-33 |
| D6 | 一期是否含 Web 完整验收，还是 Android 优先 | 影响 Sprint 1 与 6 工作量 |
| **D7** | **Create Task 是否允许访客输入文本？** | 我与 Codex 意见不同，见 `product/decisions/guest-preview.md` 末节 |

---

## 6b. 访客预览（新增需求）

完整决策稿：**`product/decisions/guest-preview.md`**。要点：

**不叫「访客登录」，叫「产品预览」。** 访客没有身份、没有 Dynamic、
没有成员关系 —— 建模成 user 或 tier 会模糊隐私、同意与授权边界。

**核心张力**：产品全部价值是「另一个真人回应你」，而访客按定义是一个人。
模拟伴侣响应 → 违反红线 1、2。给空壳 → 没人会注册。

**解法**：一份固定的虚构样例 Dynamic + 叙述式状态浏览器。
访客**绝不能**按下「完成」然后立刻收到虚构伴侣响应 —— 即使标了样例，
那也在教「系统会提供回应性肯定」这个虚假承诺。
反过来，把**响应间隔本身**做成卖点：
「App 让这个时刻保持可见；如何回应由你的伴侣决定。」

**注册引导边界不是「写数据库」。** 那是实现细节 —— 对敏感文本太晚，
对设备偏好太早。正确边界是**第一次表达真实的个人或关系意图**。

**访客不能接受邀请。** 必须先注册/登录 → 确认 18+ → 审阅邀请 → 显式接受。

**数据库影响：访客零 schema 改动。** 现有 `users.email NOT NULL` +
非空 CHECK + 唯一索引 + 10 处外键，已在用约束表达「用户必须有真实身份」。
唯一需要的迁移与访客无关：

```sql
-- V10：权益骨架
ALTER TABLE users ADD COLUMN entitlement text NOT NULL DEFAULT 'core_beta';
ALTER TABLE users ADD CONSTRAINT users_entitlement_ck
    CHECK (entitlement IN ('core_beta'));
```

单值枚举是故意的 —— 付费档位未定义前先占列位，不让休眠的定价概念影响当前行为。

**排期**：访客预览横跨 Sprint 2（入口与 18+ 门槛）与 Sprint 5（样例闭环叙述），
不单独占一个 Sprint。它本质是「已有屏的一种只读状态 + 一个注册引导层」，
不是一批新屏。

---

## 7. 建议的起步动作

D1 与 D3 已定，Sprint 1 的技术基建**不依赖任何门禁**，可立即开工：

1. **先修 TD-04** —— `deploy-ds.sh` 指向旧仓库，staging 在跑陈旧 jar。
   这是真机验收的前置条件，几分钟的事，但不修就白测
2. **并行开 Sprint 1** —— 路由、会话、认证守卫、导航提升、真 `main.dart`
3. **Sprint 1 结束时**：App 有真实外壳，SCR-01 挂在真实路由上，
   打包连 `ds-api.beforeweplay.com`，你可以在真机上走真实登录

访客预览的产品决策已完成（`product/decisions/guest-preview.md`），
其设计需求可以在你审 D2 门禁顺序时一并考虑 —— 它不新增屏，
是已有屏的只读状态加一个注册引导层。

**仍需你裁定：D2 门禁顺序、D7 Create Task 是否允许访客输入。**
