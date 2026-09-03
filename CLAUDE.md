# Claude Code contract

## Start here

1. `product/README.md` → `00-thesis` → `02-surfaces` → `03-domain`. 这是产品的唯一事实来源；代码与文档冲突时改代码。
2. `product/06-build-order.md` 告诉你现在做到哪一阶段、下一步是什么。
3. `research/` 是所有产品决定的出处。要加或改一个产品行为，先在 `product/05-decisions.md` 追加一条带原话+URL 的记录，再动代码。

## 硬约束（来自 `product/03-domain.md` 不变量）

- 系统从不替伴侣开口：一切评价性文字都有 `by_user_id`。
- 没有自动扣分、自动惩罚、审批计时。`missed` 只是事实标记。
- D 的处置永不过期；D 缺席不产生债。
- 所有"今天"按 `Dynamic.timezone + day_start` 计算，不用设备日期。
- `PrivateNote` / `DNote` 不返回给对方。

## 视觉基础

- 设计 token：`design/tokens/design-tokens.json` 与生成的 `ds_design_tokens.dart`；不散写 Hex 或随意间距。
- 字体、SVG、纹理：`design/assets/`，通过 `manifests/assets.json` / `svg-freeze.v1.json` / `texture-freeze.b4.v1.json` 引用。改动前跑 `npm run foundation:check`。
- `app/` 是可移植的 Flutter 设计系统包；`client/` 是运行中的应用。新界面逐步迁到 `app/` 的主题与组件上。
- 最小触控 48dp；语气 playful but serious，用 D/s 词汇；不写"哲学"句子。

## 工作方式

- 小步提交；每个 Phase 结束跑 `backend ./gradlew test`、`client flutter analyze && flutter test`。
- 不要为了保留旧功能而绕路：`06-build-order` 标了删的就删。
- 不确定的产品问题：查 `research/`，找不到出处就在 `05-decisions` 标「推断」并继续，不要停下来等。
