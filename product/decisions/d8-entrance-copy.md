# D8 · 未登录界面文案 —— 已裁定

Written 2026-08-29。Owner 授权自行决策:「文案这些细节可以在后期更新打磨,
先尽快把整个流程跑通」。

## 裁定:方案 B

**移除明示关系类别的词,保留视觉气质。**

理由:那份「安静的权威感」来自深色画布、Cormorant、marks 与那条下降的光线,
**不来自「D/s」这三个字母**。方案 A(完全中性化)会把它变成一个通用登录页,
丢掉 owner 验收时说的「高端、有权力感」;方案 C(维持现状)则让借出去的手机
在任何认证之前就暴露产品类别,而应用身份(`app.companion.two` / `Companion`)
是刻意中性的。

## 改动清单

| 位置 | 原文案 | 新文案 | 为什么 |
|---|---|---|---|
| SCR-04 字标 | D/s Relationship Companion | **Companion** | 与 `applicationId`、图标名、Web title 一致。这三处已经是 `Companion` |
| SCR-04 主标题 | A private space for the dynamic you share. | **A private space, for the two of you.** | 保留 Cormorant 那一行的分量与节奏,去掉「dynamic」这个类别词 |
| SCR-04 副标题 | Private. Guided. Devoted. | **Private. Considered. Yours.** | 「Devoted」是这个圈层的标记词。三段式与字距排版保留 |
| SCR-04 页脚 | Your space stays between you. | **Access is protected.** | 原文既暴露关系语境,又是产品**无法保证**的绝对隐私承诺 |
| SCR-04 主按钮 | Enter privately | **Continue** | 按钮无法保证设备、浏览器、通知、网络或旁观者层面的私密 |
| SCR-05 页脚 | Private by design. | **Private by design.** | 不变 —— 这句说的是产品的设计取向,不是承诺,也不暴露类别 |
| SCR-06 眉标 | Create your space | **Create an account** | 「your space」可能被理解为「注册即创建了一个共享空间」 |
| SCR-06 页脚 | Your identity stays private. | **Private by default.** | 同样是无法兑现的绝对表述 —— 服务必然处理邮箱与账号数据 |
| SCR-05 恢复入口 | Forgot password? | **Use an email sign-in link** | 后端**没有**密码重置端点。magic link 是真实可用的恢复路径 |
| SCR-06 密码提示 | At least 8 characters | **10–256 characters** | 服务端最小值是 10。打 8 个字符的人会在提交后才被拒 |

## 保留不动的

- **Cormorant 只给人类语句**:三个屏各自那一行大字保留
- **那条下降的光线**、`mark.authority`、`state.locked` 全部保留
- **「Welcome back」/「Return to your space.」/「Begin privately.」** 保留 ——
  它们说的是「回到你自己的东西」,不说明那是什么

## 新增(REQ-TRUST-001 要求,三张图上都没有)

三个屏底部锁形图标那一行下面,加一条常驻脚注:

> For adults 18+. Use of this service is subject to our **Terms**.
> See how we handle data in our **Privacy Policy**.
> Accounts are private by default.

Terms 与 Privacy 必须**各自可聚焦**、无需登录即可打开、不得藏进菜单。

SCR-06 上另加一条贴近动作的说明,紧邻「Create account」:

> By creating an account, you agree to the Terms and acknowledge the Privacy Policy.

**这条不替代 18+ 勾选**,也不隐含对伴侣、邀请、角色或可见性的任何同意。

## 这仍然是可以推翻的

Owner 明确说文案属于后期打磨。以上是为了让流程跑通而做的**工作决策**,
不是最终定稿。真正不可回退的只有两条,它们不是文案偏好:

1. **未登录界面不得说明产品类别** —— 借用设备是常态,这是隐私红线
2. **10–256 与「email sign-in link」必须与后端一致** —— 否则是功能缺陷,不是措辞
