# Melos 升级决策

> 最后更新：2026-07-01

Flutter Arms 默认保持单 Flutter app package，不默认启用 Melos。

## 默认不启用的原因

- 独立开发者最常见的问题是快速派生、运行、调试和发布；单 package 成本最低。
- Melos 会引入 workspace、跨 package 代码生成、依赖联动、IDE 索引和 CI 缓存策略等额外复杂度。
- 当前模板的主要边界问题可以用 `app/core/shared/features`、Provider 注入和架构测试解决，不需要 package 拆分。

## 触发条件

满足以下条件之一，再考虑升级 Melos：

- 一个仓库需要长期维护多个 Flutter app。
- `core`、`shared UI` 或某个业务能力需要跨项目复用，甚至独立发布。
- CI 已经明显受单 package 限制，需要 package 级缓存、并行测试和独立版本管理。
- 团队或模块所有权稳定，拆包能降低协作成本，而不是只增加导入和生成复杂度。

## 推荐拆包顺序

1. `packages/app_core`：error/result/env/logger/storage/network contracts。
2. `packages/app_ui`：shared widgets、theme primitives。
3. `apps/flutter_arms`：实际 app、routes、features。
4. Feature packages：仅在 feature 需要跨 app 复用或团队独立维护后再拆。

## 不推荐

- 不按每个 feature 默认拆 package。
- 不为了“看起来可扩展”提前创建 `melos.yaml`。
- 不把日志、网络、存储这些基础设施替换问题交给 Melos 解决；优先用端口和 adapter。

## 升级验收

- `melos bootstrap`、`melos run analyze`、`melos run test` 都能稳定通过。
- app 能继续通过现有 flavor、env、代码生成和发布流程。
- README 明确从单 package 到 Melos 的迁移步骤。
- 拆包后 `core` package 不反向依赖 app 或 feature。
