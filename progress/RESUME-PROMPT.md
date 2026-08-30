# 续接提示词

复制下面整段发给我，即可继续推进。末尾"本次任务"一行按需改写；
不写也行，我会按「执行顺序」自己挑。

---

继续推进 D/s Relationship Companion 的一期开发。

**工作目录**：`/Users/li/code/app/dsapp-gh`（不是 `dsapp`）。后端端口 **8082**
（8080/8081 属于另一个项目）。JDK 21 在
`/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home`。

## 先加载这些（按顺序，不要跳）

1. **四个 skill**，都在 `.claude/skills/`：
   - `ds-design-generate` —— 缺设计时怎么做（压缩图 → Codex 出图 → 评审 → 确定性渲染）
   - `ds-design-lookup` —— 冻结值在哪查
   - `ds-screen-build` —— 建屏流程
   - `ds-pitfalls` —— 这个库踩过的坑（Flutter Web 渲染、Codex 调用、真 bug vs 工具假象）
2. **现状与计划**：`progress/MASTER-PLAN.md`（一期 6 个 Sprint）、
   `progress/STATE.md`、`progress/session-review-followups.md`（已修 bug 与未决项）
3. **产品契约**：`product/requirements/core-beta.md`（REQ-* 全表）、
   `product/ui-invariants.md`（红线的可执行形式）
4. **设计冻结**：`design/tokens/B2-FREEZE.md`、`design/system/type-in-practice.md`、
   `design/assets/svg/SVG-FREEZE.md`、`design/system/spacing.md`
5. 具体屏：`design/screens/SCR-XX-*/screen.md`（契约 + 状态矩阵 + 资产清单）

先跑一遍现状核对，**不要相信文档里的数字**（它们过期过两次）：

```bash
cd /Users/li/code/app/dsapp-gh
for f in design/screens/SCR-*/screen.md; do \
  printf '%-34s %s\n' "$(basename $(dirname $f))" \
  "$(grep -m1 -oE '(ready_for_build|blocked_alignment_required|future_reference|reference_only)' $f)"; done
for d in design/screens/SCR-*/; do \
  printf '%-34s %s\n' "$(basename $d)" \
  "$(ls -d $d/candidates/*/states/*/ 2>/dev/null | wc -l | tr -d ' ')"; done
```

## 工作方式（这几条是上次纠正过的，请保持）

- **自我决策模式。** 执行细节自己定：先做样板还是批量、要不要现在派 Codex、
  用哪个方向——都不要问我。
- **门禁关闭 ≠ 停工。** 缺设计就按 `ds-design-generate` 生产：压缩参考图 →
  给 Codex 出图（要两个方向）→ 按冻结规范和红线评审 → 确定性渲染整个状态族 →
  提交 → 把带渲染图的 gate 决策交给我。
- **只有这几种情况才停下来问我**：产品红线冲突、某个状态的语义从没人定过、
  不可逆操作、真正的所有权死锁。「还没人画过」不算。
- **gate 由你们决定**（2026-08-30 授权）。设计真正完整时就开：state matrix
  零 blocked 行 + 状态已渲染，两个条件都要**数出来**而不是断言。
  `manifests/screen-index.json` 和 `screen.md` 必须同步。
- **绝不从位图描摹 SVG**，这条无例外。
- **给 Codex 发图前必须压缩**：390×844 WebP q82，约为原图 **7.8%**
  （实测 6.9MB → 91KB）。设计稿是 3× 倍率出的，那分辨率给渲染用，不是给评审用。
  脚本在 `ds-design-generate` 里。
- **Codex 的结论要核验再采信。** 上次它把「Cormorant 只用于人写的话」读对了但
  结论错了——按那个读法四个已批准的入口标题也会违规。规则判已批准且看起来正确的
  东西有罪时，先怀疑规则。
- **验证要真做**：改 bug 要反向注入缺陷确认测试会红；改设计要重跑渲染器确认
  逐字节可复现；改屏幕要在 390×844 真浏览器里看一眼（release build，debug build
  的 dwds 白屏是工具问题不是代码问题）。

## 红线（`product/ui-invariants.md` 有可执行版本）

只有明确的人类 Send 才产生 Acknowledgement；系统绝不以伴侣口吻说话；
完成永远不等于被确认；调整是正常路径不是失败；respond 屏起始为空，
未写字不可发送；不得出现积分/连击/评分/奖杯。

## 执行顺序（依赖排序，我不指定时按此推进）

1. **SCR-09 缺的 4 个态**（Loading、Share/error retry、Offline、Authorization
   loss；Pending/Accepted/Expired/Revoked 已是 candidate rev-2）——
   Sprint 4 握手的发送侧，SCR-10 接收侧已在 rev-3 补齐 5 态
2. **Sprint 5 心脏**：SCR-02 完成→等待响应、SCR-33 确认编辑器（核心红线）、
   SCR-03 收到确认、SCR-32 Attention
3. **命令层已就绪、只差屏幕的三处**：`features/entrance/`、`activation/`、
   `invite/` 都有 `application/` 无 `presentation/`
4. 建屏：按 `ds-screen-build`。一期 14 个屏的 gate 已于 2026-08-30 全部打开

## 我这边的待决事项（你可以催，但不要替我决定）

- **staging 未重新部署** —— `https://ds-api.beforeweplay.com/v1/auth/register`
  仍返回 401（新代码应为 400），线上跑的是旧 jar，脚本 `ops/deploy-ds.sh` 已修好，
  差在服务器上跑一次。这挡着我真机测试。
- **`withdraw` 被 advertise 但没实现** —— 服务端在 `allowedActions` 里给出它，
  却没有对应接口，`NEED_TO_DISCUSS` 对提出者是死路。要么实现，要么别再 advertise
- **SCR-33 是否预填散文**（D9）
- **FCM 凭据**（阻塞真实推送）

## 本次任务

<在这里写具体要做什么；留空则按上面「执行顺序」自己挑，做完再汇报>
