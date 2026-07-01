---
name: flutter-arms-feature
description: Scaffold and modify features in a flutter_arms project (Clean Architecture + MVVM + Riverpod 3 + AutoRoute + Retrofit/ApiClient adapters + Freezed + hive_ce + slang). Use this skill whenever the user asks to add, modify, rename, or extend a feature — including new pages, new API endpoints, new ViewModels/Notifiers, new entities/DTOs, new routes, new i18n keys, or new remote datasources. Also use it when the request is phrased as "添加登录页", "add a settings screen", "wire up /users API", "新增 feature", "写一个 profile 页", "make a search module", or anything that touches data/domain/presentation layers. Do NOT write generic Flutter code in this project — flutter_arms has its own Result<T>, Failure, and DataSource-side exception conversion conventions that must be followed. Apply this skill proactively even when the user doesn't say "feature" explicitly, as long as the change involves any of: Riverpod providers, AutoRoute pages, Retrofit interfaces, Hive storage, Freezed states, slang i18n, or Clean Architecture layers.
---

# flutter-arms-feature

你正在 **flutter_arms** 项目里工作——一个 Clean Architecture + MVVM 的 Flutter 模板。你写的一切都必须匹配 `lib/` 已有的约定。动手前先判断改动属于哪一层，并规划文件树。

## 技术栈（不可替换）

| 关切 | 工具 | 禁止替换为 |
|---|---|---|
| 状态 + DI | **Riverpod 3** + `@riverpod` / `@Riverpod(keepAlive: true)` | 不用 Bloc、不用 GetIt、不用 StateProvider、不用 ChangeNotifierProvider |
| 路由 | **AutoRoute** + `@RoutePage()` | 不用 GoRouter，顶层导航不用 `Navigator.push` |
| 网络 | **Dio + Retrofit** + `@RestApi()` | 不用原生 `http` 包 |
| 不可变数据 | **Freezed 3** —— `abstract class X with _$X` | 不手写 `copyWith`，不用 Equatable |
| JSON | `json_serializable` + `@JsonSerializable` / `@freezed` `fromJson` | — |
| 本地存储 | **hive_ce** 经由 `kvStorageProvider` | 不用 `shared_preferences` |
| i18n | **slang** —— `context.t.<path>` | 不用 `AppLocalizations.of(context)` |
| 错误 | `Result<T>` + `Failure` + `AppException`（自定义三件套） | 不用 Dartz `Either`，UI 不用 `try/catch` |
| 日志 | **talker** —— `ref.read(appLoggerProvider)` | 不用 `print` |
| Lint | `very_good_analysis` + 80 字符行宽 | — |
| 测试 | `flutter_test` + **mocktail** + `ProviderContainer` | 不用 mockito |

## 层级契约（由 `test/core/architecture_test.dart` 强制）

```
features/<f>/
├── data/              ← dio、retrofit、hive_ce、AppException 仅允许在此
│   ├── datasources/   ← 纯接口 + Retrofit/ApiClient adapter + Hive 封装
│   ├── models/        ← DTO @freezed + toEntity() 扩展
│   └── repositories/  ← impl：try { await _remote.xxx() } on AppException catch
├── domain/            ← 纯 Dart；禁 dio/hive/retrofit/AppException
│   ├── entities/      ← @immutable 普通类或 freezed
│   ├── repositories/  ← abstract class，方法返回 Future<Result<T>>
│   └── usecases/      ← 一个 use case 一个类，有 `call()` 方法
└── presentation/      ← flutter、riverpod、auto_route；禁 AppException
    ├── pages/         ← @RoutePage() StatelessWidget / ConsumerWidget
    ├── view_models/   ← @riverpod class XxxViewModel extends _$XxxViewModel
    ├── states/        ← @freezed XxxState
    └── widgets/       ← 私有 _Xxx 或公共共享 widget
```

违反这些规则会导致 `tool/test.sh` 失败。真需要跨层调用（比如 Profile 页要调 `AuthNotifier`），在 import 上一行加 `// arch-exempt: <reason>`。不要随意添加豁免——当前白名单只限 auth。

## 关键规则（CRITICAL，通用 Flutter 建议经常写错）

1. **Repository 始终返回 `Future<Result<T>>`**，永远不向 UI 抛异常。标准写法：
   ```dart
   try {
    final dto = await _remote.xxx(body);
     return Result.success(dto.toEntity());
   } on AppException catch (e) {
     return Result.failure(Failure.fromException(e));
   }
   ```

2. **DataSource adapter 负责底层异常转换。** Retrofit adapter 在 `_api.xxx().asApi()` 处把 `DioException` 转成 `AppException`；ApiClient adapter 通过 `DioApiClient.send(...)` 得到同样的 `AppException`。Repository 不再 import `dio_ext.dart`，也不调用 `.asApi()`。

3. **Domain / Presentation 从不 import `app_exception.dart`** —— 只认 `Failure` + `FailureCode`。否则架构测试失败。

4. **UI 通过 `context.failureMessage(failure)` 渲染错误** 获取本地化文本。**不要**硬编码错误字符串，**不要**在 UI 里调 `failure.toString()`。

5. **ViewModel 命名约定**：
   - `XxxViewModel` → **页面级** Notifier，随路由销毁。默认 `@riverpod`（autoDispose）。
   - `XxxNotifier` → **全局** Notifier，长于页面生命周期（auth、theme、locale）。总是 `@Riverpod(keepAlive: true)`。

6. **用私有 widget 类，不用 `Widget _buildXxx()` 方法。** 在同一文件底部抽一个 `class _Xxx extends StatelessWidget { ... }`，并用分隔注释标明。

7. **修改任意注解后跑 `tool/gen.sh`**（`@freezed`、`@riverpod`、`@RoutePage()`、`@RestApi()`、`@JsonSerializable`）。它会执行 `build_runner build --delete-conflicting-outputs && dart run slang`。

8. **i18n key 同时加进 `lib/i18n/en.i18n.json` 和 `lib/i18n/zh.i18n.json`**，结构对称。然后重跑 slang。通过 `context.t.<path>` 访问。

9. **禁止跨 feature import。** feature X 要用 feature Y 的东西，要么 (a) 提升到 `core/`（优先），要么 (b) 在违规 import 上一行加 `// arch-exempt: <reason>` 并写真实理由。不要悄悄 import。

10. **代码风格**：80 字符行宽、尾随逗号、每个 public 符号带中文 `///` 文档注释、import 顺序 dart → package → relative。

## 新增 feature（分步）

feature 名为 `<name>`（单数、snake_case，例如 `settings`、`post`、`search`）：

1. **从模板 scaffold。** 复制 `.claude/skills/flutter-arms-feature/assets/feature_template/` 到 `lib/features/<name>/`。所有路径和文件内容里的 `%feature%` → `<name>`，`%Feature%` → PascalCase。对照表见 `references/checklist.md`。

2. **填充 Data 层：**
   - `data/models/<name>_dto.dart` —— Retrofit 响应 DTO，用 `@freezed`；加 `toEntity()` 扩展。
   - `data/datasources/<name>_remote_datasource.dart` —— 纯远程数据源接口。
   - `data/datasources/retrofit_<name>_remote_datasource.dart` —— Retrofit adapter + 默认 provider，读 `dioProvider`。
   - `data/datasources/api_client_<name>_remote_datasource.dart` —— ApiClient adapter，只依赖 `ApiClient` / `ApiRequest`；provider 接线放在单独 provider 文件。
   - `data/datasources/<name>_local_datasource.dart` —— 仅当 feature 有缓存。包装 `KvStorage`。
   - `data/repositories/<name>_repository_impl.dart` —— `implements <Name>Repository` + repository provider + 每个 UseCase 一个 provider。标准形态看 `auth_repository_impl.dart`。

3. **填充 Domain 层：**
   - `domain/entities/<name>.dart` —— `@immutable` 普通 Dart 类并做值相等；字段多的话用 freezed。
   - `domain/repositories/<name>_repository.dart` —— abstract class，方法返回 `Future<Result<T>>`。
   - `domain/usecases/<verb>_<name>_usecase.dart` —— 每个 UseCase 一个类，`const` 构造器和 `call(...)` 方法。

4. **填充 Presentation 层：**
   - `presentation/states/<name>_state.dart` —— `@freezed`，至少含 `isLoading`、`error: Failure?` 及数据字段。
   - `presentation/view_models/<name>_view_model.dart` —— `@riverpod class <Name>ViewModel extends _$<Name>ViewModel`。`build()` 返回初始 state。动作读 UseCase provider，`switch` on `Result`，更新 `state`。
   - `presentation/pages/<name>_page.dart` —— `@RoutePage()`。读 Riverpod 就用 `ConsumerWidget`，否则 `StatelessWidget`。在 `ref.listen` 里通过 `AppDialog.showError(context, context.failureMessage(failure))` 渲染错误。
   - `presentation/widgets/` —— 私有 `_Xxx` widget；如被复用则提升到 `lib/shared/widgets/`。

5. **注册路由** 在 `lib/app/app_router.dart`：在 `routes` 里加 `AutoRoute(page: <Name>Route.page)`。需要鉴权就加 `guards: <AutoRouteGuard>[_authGuard]`。

6. **对称地加 i18n key** 到 `lib/i18n/en.i18n.json` 和 `lib/i18n/zh.i18n.json`，放在 `<name>:` 命名空间下。

7. **跑代码生成**：`tool/gen.sh`。

8. **补测试**（见 `flutter-arms-testing` skill）：
   - `test/features/<name>/data/repositories/<name>_repository_impl_test.dart`
   - `test/features/<name>/presentation/view_models/<name>_view_model_test.dart`
   - `test/features/<name>/presentation/pages/<name>_page_test.dart`（当页面有有意义交互时）

9. **验证**：`tool/test.sh` —— analyze + test，含 `test/core/architecture_test.dart`。

## 遇到不同问题时查阅哪份 reference

- **`references/architecture.md`** —— 层级边界、如何读架构测试的失败、何时把代码提升到 `core/`、`// arch-exempt:` 的正确用法。
- **`references/state_management.md`** —— Riverpod 3 模式、ViewModel vs Notifier、`ref.listen` vs `ref.watch`、Freezed state 形态、禁用项（StateProvider、ChangeNotifier）。
- **`references/networking.md`** —— Retrofit 接口、`.asApi()` 边界、拦截器链、mock API、超时配置位置。
- **`references/routing.md`** —— AutoRoute 声明、guard、嵌套路由、`AuthListenable` 在登录态变化时如何重评估 guard。
- **`references/storage.md`** —— `KvStorage` 接口、普通/加密 box、新增持久化 key、feature 本地数据源。
- **`references/i18n.md`** —— slang 工作流、动态参数、errors 命名空间、JSON 对称要求。
- **`references/ui_conventions.md`** —— 私有 widget 类、`lib/shared/` 共享 widget、通过 `context.theme`/`context.colors` 访问主题、错误展示模式。
- **`references/checklist.md`** —— 模板占位符替换表 + 常见错误清单。

只在任务真正涉及时加载对应 reference，跨领域时可加载多份。

## 模板位置

`assets/feature_template/` 提供完整目录树，含 `%feature%` / `%Feature%` 占位符。复制树、同时替换路径和内容，再填入真实字段、DTO 结构、endpoint 路径。替换表在 `references/checklist.md`。
