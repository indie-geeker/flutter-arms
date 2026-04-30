# flutter_arms Claude Skills（中文版）

> 本目录是 `.claude/skills/` 下所有 skill 文档的中文翻译。原文（英文 SKILL.md + 英/中混排 references）是 Claude Code 在运行时实际加载的文件，本中文版仅供人类阅读。

这里是 flutter_arms 项目内置的 Claude Code skill 集合。三个 skill 分工明确、互相引用，覆盖"新增功能 / 错误处理 / 测试"三条主线——也是在这个栈上最容易被通用 Flutter 建议带偏的三个地方。

## 三个 skill 速览

| Skill | 触发场景 | 包含内容 |
|---|---|---|
| **[flutter-arms-feature](./flutter-arms-feature/)** | 新增/修改 feature、页面、API、ViewModel、路由、i18n、Retrofit 数据源 | 10 条核心规则 + 9 步 checklist + 8 份 reference + 一整套 data/domain/presentation 代码模板 |
| **[flutter-arms-error-handling](./flutter-arms-error-handling/)** | 处理 DioException、错误展示、401 刷新、`Result<T>`、`Failure`、`AppException`、`.asApi()`、`failureMessage` | Result/Exception/Failure 三件套详解 + Repository 错误流 + UI 展示模式 |
| **[flutter-arms-testing](./flutter-arms-testing/)** | 写测试（unit/widget/integration）、调试失败测试、理解 `architecture_test.dart`、mock、`ProviderContainer` | Repository/ViewModel/Widget 测试模板 + 架构测试规则 + 复用 fixture |

## 触发示例

以下 prompt 会命中对应的 skill：

- "帮我新增一个 bookmark feature" → `flutter-arms-feature`
- "给 `/users` 接口加个 page 和 viewmodel" → `flutter-arms-feature`
- "这个 Retrofit 调用报 DioException 没被 catch 住" → `flutter-arms-error-handling`
- "请求失败时怎么展示错误" → `flutter-arms-error-handling`
- "给 LoginViewModel 写单测" → `flutter-arms-testing`
- "architecture_test 红了不知道怎么改" → `flutter-arms-testing`

复杂任务可能同时触发多个 skill（新增 feature 时通常会用到 feature + error-handling，完成后写测试会再叠加 testing）。三个 skill 的 SKILL.md 都有交叉引用，Claude 会按需加载。

## 为什么是三个 skill 而不是一个大的

拆分的理由是**触发聚焦度**。Claude 对 skill 的触发是基于 description 的匹配——一个大而全的描述要么在"写个按钮"这种小任务里过度触发，要么在真正需要时因为描述太笼统而欠触发。现在的拆法让每个 skill 的 description 能够 sharp 地对应一类任务。

三个 skill 共享同一个底层契约（Clean Architecture + Riverpod 3 + Result/Failure 错误模型），但各自深挖自己的领域细节。

## 与项目的关系

这些 skill **不是**独立于项目存在的——它们记录的是 flutter_arms 项目本身的 conventions。具体来说，skill 里的每条规则都能在项目代码中找到对应的实现证据：

- "`.asApi()` 是必需的" → `lib/core/network/dio_ext.dart` + `auth_repository_impl.dart`
- "Domain 不得 import AppException" → `test/core/architecture_test.dart` 静态强制
- "`XxxViewModel` vs `XxxNotifier` 命名" → `login_view_model.dart` vs `auth_notifier.dart`
- "`context.failureMessage` 是 UI 错误出口" → `core/extensions/build_context_ext.dart` + `login_form.dart`

当你修改项目代码、改变了某条约定时，请同步更新对应 skill 的 SKILL.md 或 references——否则 Claude 会继续按过时的规则写代码。

## 派生新项目时

flutter_arms 是模板。当你用 `tool/rename.dart` 派生新项目时，这些 skill 会跟着 `.claude/skills/` 目录被一起复制过去。派生后需要检查：

1. **package 名替换**：skill 的模板文件里写的是 `package:flutter_arms/...`，rename 脚本应当会改这个；检查 `assets/feature_template/` 下是否正确替换。
2. **项目名引用**：README、SKILL.md 中的 "flutter_arms" 字样按需替换，或保留（如果作为"本项目派生自 flutter_arms 模板"的说明）。
3. **约定偏移**：派生后如果团队偏离了某条 convention（比如换掉了 AutoRoute），立刻更新对应 skill，不然 Claude 会拉着你回到老路上。

## 本地验证 skill 是否生效

新启一个 Claude Code 会话，在项目根目录跑：

```
帮我理解一下 flutter_arms 里添加 feature 的流程
```

Claude 应当自动加载 `flutter-arms-feature` 的 SKILL.md 并按里面的 9 步 checklist 回答你，而不是按通用 Flutter 知识胡编。如果 Claude 没触发 skill，说明 description 还不够 sharp——把那次 prompt 反馈给 Anthropic（或者让我调整 description）。

## 维护原则

- **改项目约定 → 改 skill**：代码和规则必须同步。
- **Skill 里每条规则必须可追溯到项目代码**：不允许写"理想规则"或"想这么干"——skill 记录的是**现状**。
- **新增 skill 的门槛要高**：三个 skill 已经覆盖了核心主线。再加新 skill 之前问问自己：是不是应该在已有 skill 里加一个 reference 文件就够了？

---

最后：这些 skill 由 Claude 在 2026-04-18 基于当时的项目状态生成。后续如果重构不要忘了这里。
