# SCR-04 / 05 / 06 · 状态族与文案规格（待批准）

Written 2026-08-29。经 Codex 产品评审。**这三个屏的门禁仍然关闭，本文件不改变门禁** ——
它是「让门禁有资格被打开」的那部分工作：把三张参考图缺的状态族、文案、
以及与后端的对齐补齐，交由产品/设计负责人批准。

## 摘要：一个必须由你决定的问题

**入口屏在未认证状态下暴露了关系语境。**

参考图上的字样：

- 顶部字标 **「D/s Relationship Companion」**
- 主标题 **「A private space for the dynamic you share.」**
- **「Private. Guided. Devoted.」**
- 底部 **「Your space stays between you.」**

而这个仓库里，应用身份是**刻意中性**的:

| 位置 | 值 |
|---|---|
| Android `applicationId` | `app.companion.two` |
| 桌面图标名 | `Companion` |
| Web `<title>` / PWA name | `Companion` |

那次改名的提交信息是「a neutral application identity」。**但装好之后打开的第一屏，
把这份中性完全抵消了。** 借出去的手机、被人从肩后瞥一眼、锁屏预览 ——
在任何认证发生之前，就已经说明机主可能在使用一个 D/s 产品。

产品红线写着「共享或借用的设备是**常态**，不是边缘情况」。

**这是设计所有者的决定，不是我能自行改的**（红线：文案不是自动经过产品批准的，
而且我不得替产品重写已批准的视觉）。三条路：

| 方案 | 代价 |
|---|---|
| A. 未登录界面完全中性化（Codex 建议：字标改 `Private Companion`，标题改 `A private space, available when you sign in.`） | 失去入口的情绪与质感 —— 而那正是你验收时说的「高端、有权力感」 |
| B. 保留视觉气质，只移除**明示**关系类别的词 —— 去掉 `D/s`、`the dynamic you share`、`Devoted` | 折中；仍保留深色、Cormorant、marks 与那条下降的光线 |
| C. 维持现状 | 明确接受这个暴露面 |

**我倾向 B。** 那份「安静的权威感」来自排版、留白与那条光线，不来自「D/s」这三个字母。
中性化措辞不会让它变廉价；而 A 会把它变成一个通用登录页。

---

## 与后端的三处不一致（均已核实源码）

| # | 不一致 | 事实 | 处置 |
|---|---|---|---|
| 1 | 「Forgot password?」 | 后端**没有任何**密码重置端点 | 改为 **「Use an email sign-in link」** —— magic link 已实现，是真实可用的恢复路径。它做的是认证，不是改密码，所以名字也不该叫重置 |
| 2 | 「At least 8 characters」 | 服务端最小值是 **10**（`requireUsablePassword`） | 全部改为 **10–256 characters**。8 个字符的人会在提交后才被拒 |
| 3 | SCR-05 契约要求「与 magic-link 对齐」，但图上是密码表单 | 两者**都**已实现：密码是常规门，magic link 是第二条路，也是密码功能上线前老账号的唯一路 | 密码留作主表单，magic link 作为一等的次要模式并入同一状态族 |

## REQ-TRUST-001 缺失项（严重）

**三张图上都没有 Terms、Privacy、18+ 与「默认私密」的说明。** 而 `REQ-TRUST-001` 明确要求
入口界面以中性语言传达这四件事。

建议在每屏底部锁形图标那一行下面加一条常驻脚注：

> For adults 18+. Use of this service is subject to our **Terms**. See how we
> handle data in our **Privacy Policy**. Accounts are private by default.

Terms 与 Privacy 必须是**各自可聚焦的链接**、无需登录即可打开、不得藏进菜单。

SCR-06 上另加一条更贴近动作的说明，紧邻「Create account」：

> By creating an account, you agree to the Terms and acknowledge the Privacy Policy.

**这条不替代 18+ 勾选。** 且它不隐含对伴侣、邀请、角色、共享或可见性的任何同意。

---

## 状态族

### SCR-04 私密入口

| 状态 | 看到什么 | 能做什么 |
|---|---|---|
| Default | 中性字标、引导文案、主按钮、登录入口、18+/Terms/Privacy 脚注 | 继续注册或去登录；打开 Terms / Privacy |
| Loading | 无远程内容，**无页面级加载态**。导航期间被按下的控件显示「Opening…」且不可二次按下 | 等待 |
| Empty | **N/A** —— 静态入口，不是内容集合 |
| Error / retry | 靠近被按控件的行内提示：「We couldn't open that page. Try again.」 | 重试，或改走另一条认证路径 |
| Offline | 「You're offline. Connect to the internet to sign in or create an account.」 | 阅读说明；恢复后重试 |
| Stale | **N/A** —— 此处没有任何服务端派生或缓存的关系数据 |
| 授权丢失 | **绝不提及此前存在会话。** 显示普通的默认入口 —— 否则借用设备的人就得知了机主有账号 | 正常继续或登录 |
| 角色 / 伴侣变体 | **N/A** —— 未登录入口**绝不**因角色、伴侣状态、邀请或关系状态而变化 |

### SCR-05 登录

一个状态族，两种模式:**密码**（常规）与 **邮件登录链接**（恢复与老账号）。

| 状态 | 看到什么 | 能做什么 |
|---|---|---|
| Default · 密码 | Email、Password、显示/隐藏、「Sign in」、「Use an email sign-in link」、「Create an account」、脚注 | 输入、切换模式、去注册 |
| Default · 邮件链接 | Email、「Send sign-in link」、「Use password instead」、中性说明 | 请求链接或退回密码模式 |
| Loading · 密码 | 主控件显示「Signing in…」；字段与竞争性提交动作暂时锁定 | 等待。**密码不得被记录或在离开流程后保留** |
| Loading · 邮件链接 | 主控件显示「Sending link…」 | 等待 |
| Empty | 空白表单就是默认态，不是独立状态。提交空表单 → 显示字段错误并聚焦第一个无效字段 |
| Error / retry | **保留 email，清空密码**，显示不泄露注册状态的错误，两条认证路径都保持可用 | 修正重试、改用邮件链接、去注册 |
| 链接已发送 | 「Check your email」+ 不可枚举的确认文案 | 「Resend link」（可见的频率限制）、「Use a different email」、「Use password instead」 |
| 链接失效 / 过期 | 中性错误 + 「Request a new link」。**不含任何账号或关系信息** | 请求新链接或改用密码 |
| Offline | 「You're offline. Connect to the internet, then try again.」保留 email；App 进入后台或离开流程时清空密码 | 编辑字段；恢复后重试 |
| Stale | 显示数据方面 **N/A**。已被打开过的 magic link 按「失效/过期」处理，不叫 stale |
| 授权丢失 | 从受保护内容被安全重定向而来:清空全部敏感状态，显示「Please sign in to continue.」**不得指明是哪个账号、伴侣、角色、邀请或内容触发了跳转** | 用任一方式登录，或返回 |
| 角色 / 伴侣变体 | **N/A** —— 认证界面与错误对所有角色、所有配对状态必须完全一致 |

### SCR-06 创建账号

| 状态 | 看到什么 | 能做什么 |
|---|---|---|
| Default | Email、Create password（提示 **10–256 characters**）、显示/隐藏、18+ 勾选、「Create account」、「Sign in」、脚注 | 填写、确认年龄、创建、去登录 |
| Loading | 主控件显示「Creating account…」；阻止重复提交 | 等待 |
| Empty | 空白表单即默认态。提交空表单 → 字段错误 + 聚焦第一个无效字段 |
| Error / retry | **保留 email 与年龄勾选**；密码仅在人仍停留于本屏时保留，否则清空 | 修正重试、去登录、改用邮件链接 |
| **网络结果不确定** | 「We couldn't confirm whether the account was created. Try signing in or request an email sign-in link before creating it again.」 | 去登录、请求链接，或明确地重试创建 |
| Offline | 「You're offline. Connect to the internet, then try again.」 | 编辑字段；恢复后重试 |
| Stale | **N/A** |
| 授权丢失 | 创建过程中 **N/A**（本就没有先前授权）。若注册成功但会话建立失败 → 转到 SCR-05 并显示「Please sign in to continue.」 |
| 角色 / 伴侣变体 | **N/A** —— 创建账号**不得**指派或暗示任何角色、伴侣、同意、邀请接受或共享可见性 |

---

## 错误文案

**规则:必须为真、不指责、不泄露某邮箱是否已注册（账号枚举）、
且对未登录的读者不使用任何关系词汇。**

客户端:

| 情形 | 文案 |
|---|---|
| Email 为空 | Enter your email. |
| Email 格式不对 | Enter a valid email address. |
| 密码为空 | Enter your password. |
| 新密码 < 10 | Use at least 10 characters. |
| 新密码 > 256 | Use no more than 256 characters. |
| 未勾选 18+ 就提交 | Confirm that you are 18 or older to create an account. |

服务端（按 `AuthServices` 实际返回的错误码）:

| 错误码 | 文案 |
|---|---|
| `INVALID_CREDENTIALS` | We couldn't sign you in with those details. Check your email and password, or use an email sign-in link. |
| `ACCOUNT_NOT_ACTIVE` | We can't sign you in. Try an email sign-in link or contact support. |
| `AGE_NOT_CONFIRMED` | Confirm that you are 18 or older to create an account. |
| `PASSWORD_TOO_SHORT` | Use at least 10 characters. |
| `PASSWORD_TOO_LONG` | Use no more than 256 characters. |
| `INVALID_OR_EXPIRED_MAGIC_LINK` | That link can no longer be used. Request a new one. |
| 未知 / 5xx | We couldn't sign you in right now. Try again. |
| 离线 | You're offline. Connect to the internet, then try again. |
| 超时 / 结果不确定 | We couldn't confirm the sign-in. Try again. |

## 字段校验时机

| 字段 | 输入时 | 失焦时 | 提交时 |
|---|---|---|---|
| Email | 值变得合理后**清除**已显示的错误；**不要**在打字过程中新增错误 | 非空则做基本格式检查。**不判断该地址是否存在** | 要求非空且格式基本正确，去除首尾空格 |
| 密码（登录） | 无强度规则，无凭据错误 | 仅空 / 非空 | 仅要求非空。**不要**把注册的长度规则套用到登录 —— 老账号可能遵循更早的约定 |
| 新密码 | 稳定显示「10–256 characters」 | 过短 / 过长反馈 | 超出范围就拦下并聚焦。**不要**自创大写、数字、符号或强度要求 |

**18+ 勾选:按钮保持视觉可用**，这样这个要求才可被发现，键盘与读屏用户也不会面对一个
无解释的禁用控件。未勾选就按下 → 不发请求，显示错误、聚焦勾选框并播报。
**服务端的 `AGE_NOT_CONFIRMED` 仍要处理** —— 客户端校验不是安全边界。

勾选框**只确认年龄**。它不授予角色、伴侣访问、内容可见性或任何关系同意。

---

## 其余需要批准的文案改动（Codex 提出，我同意）

| 现文案 | 问题 | 建议 |
|---|---|---|
| Your space stays between you. | 既暴露关系语境，又是产品**无法保证**的绝对隐私承诺 | Access is protected. |
| Your identity stays private. | 同样是无法兑现的绝对表述 —— 服务必然处理邮箱与账号数据 | Private by default. |
| Enter privately | 按钮无法保证设备、浏览器、通知、网络或旁观者层面的私密 | Continue |
| Create your space | 可能被理解为「创建账号 = 创建了一个共享空间」 | Create an account |

## 已有的资产缺口

SVG Freeze v1 里**没有**眼睛/显示密码图标。禁止从 raster 预览描摹，也不能用 Material 图标
临时顶替。当前实现用 `Show` / `Hide` 文字，保持 48dp 触达区。
记录在 `design/assets/svg/REQUESTED.md`。
