# SCR-31 / 07 / 08 / 12 · 激活向导状态族(待批准)

Written 2026-08-30。**门禁未改动**,四个屏仍是 `blocked_alignment_required`。
本文件补齐它们契约里全是 TBD 的状态矩阵。

## 首要事实:这不是四个屏,是一个向导

四个屏的输入**全部进入同一个 `POST /v1/dynamics`**。设计稿上的
「1 of 4 / 2 of 4 / 3 of 4 / 4 of 4」不是装饰,是准确的:
在第四步之前,服务端不知道任何事情。

这决定了状态族的形状:

- **前三步没有 loading、没有 error、没有 offline** —— 它们不发请求。
  草稿活在客户端内存里,退回上一步不会撤销任何已写入的东西,
  因为根本还没写入。
- **第 4 步是第一次真实写入**,也是唯一需要完整恢复态的一步。
- 一个人在第 2 步关掉 App,服务器上什么都没留下。这是对的:
  半个 Dynamic 不是一个可以恢复的东西。

## 与 D2 建屏顺序的关系

`product/decisions/d2-build-order.md` 把激活拆在同意两侧:
SCR-31/07 是**个人设置**(邀请之前),SCR-08/12 是**共享配置**(同意之后)。

但技术上它们是一条命令。所以顺序是:

1. SCR-31 + SCR-07 收集**个人**答案 → 存草稿,不发请求
2. SCR-08 + SCR-12 收集**共享**答案 → 发出 `POST /v1/dynamics` + starter rhythm
3. 然后才是邀请

在伴侣接受之前,SCR-08/12 里配置的东西必须标注为**「私人提议」**,
被邀请方能够拒绝或修改。邀请本身绝不创建一个双方活跃的 Dynamic。

## 状态族

### 三步共有(SCR-31 / 07 / 08)

| 状态 | 规则 |
|---|---|
| Default | 设计稿即规格 |
| Loading | **N/A** —— 不发请求 |
| Empty | **N/A** —— 选项是固定的产品清单 |
| Error / retry | **N/A** |
| Offline | **N/A** —— 全部可用。这是一个卖点:没网也能想清楚要什么 |
| 授权丢失 | **N/A** —— 尚无受保护内容 |
| 角色变体 | **N/A** —— 这里正是在**选择**角色 |

唯一的交互态是「未选择时 Continue 不可用」。按 D7 的同一条理由,
按钮**保持视觉可用**并在按下时解释,而不是无声禁用。

### SCR-31 目标选择

五个选项来自 `REQ-ACT-001`,与服务端 `DesiredOutcome` 枚举一一对应:

| 界面文案 | 线上值 |
|---|---|
| Closer | `CLOSER` |
| Structure | `STRUCTURE` |
| Service & devotion | `SERVICE` |
| Accountability | `ACCOUNTABILITY` |
| Explore together | `EXPLORE` |

**这不只是存储。** `StarterRhythmService` 用它挑选起始节奏内容 ——
选 Accountability 与选 Closer 会拿到不同的仪式与期望。
(服务端此前接受任意字符串并静默回落到 CLOSER;已在 0853745 修复。)

### SCR-07 角色定位

两组独立选择:**Couple / Solo**,以及**可选的**起始角色。

> 「A starting point, not a limit. You can change this later.」

角色预设 `DOMINANT / SUBMISSIVE / SWITCH / CUSTOM`,**可以完全不选**。
数据库列可空、客户端可空、命令层可空 —— 三处都不能要求它。
它**永不用于授权**,服务端用独立的 `role_context` 表示位置。

### SCR-08 结构与情境

`LIGHT / STEADY / DEFINED`,**Steady 默认选中**(设计稿如此)。
外加 Long-distance / Together、时区(设备检测)、可选的边界偏好。

时区必须是 **IANA 名称**,不是裸偏移量 —— `REQ-TIME-001`:
固定偏移会让关系日在夏令时切换时静默移位。

### SCR-12 起始节奏 —— 唯一有完整恢复态的一步

| 状态 | 看到什么 |
|---|---|
| Default | 服务端建议的三条:ritual / expectation / check-in,每条可「Replace」 |
| Loading | 建议正在取回。骨架保持版式稳定 |
| Error / retry | 「We couldn't load a starting rhythm. Try again.」前三步答案保留 |
| Offline | 「You're offline. Connect to the internet, then try again.」草稿保留 |
| 提交中 | 主控件显示「Starting…」,不可二次按下 |
| 结果不确定 | 与注册同理:Dynamic 可能已创建。**不说「重试」**,而是「Check whether it was created」 |
| 授权丢失 | 转到入口,清空草稿。不说明是什么被中断了 |

## 幂等

创建 Dynamic 与启动节奏都持有幂等键,**成功后不清除节奏键** ——
理由与 join 相同:响应丢失恰恰是重试必须扛住的情况。
(join 上这条我第一次就写错了,见 5f4c5c6。)

## 未覆盖

- **Boundaries & preferences** 是一个二级页面,设计稿上只有入口行
- **Web 适配**:这些是 390 × 844
- **「Add another expectation」**:API 支持 `includeSecondExpectation`,
  设计稿有这个入口,但第二条期望的选择界面未设计
