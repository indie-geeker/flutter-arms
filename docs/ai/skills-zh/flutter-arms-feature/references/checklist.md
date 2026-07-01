# 新增 feature 清单

## 占位符替换

从 `assets/feature_template/` 拷贝时，以下占位符需同时在文件名与文件内容中替换。模板使用 `%` 分隔符是因为不会和 Dart `{...}` 具名参数语法冲突。

| 占位符 | 替换为 | 示例（`settings`） |
|---|---|---|
| `%feature%` | 小驼峰下划线（snake_case）单数 feature 名 | `settings` |
| `%Feature%` | PascalCase | `Settings` |

## 文件映射

| 模板路径 | 生成路径（示例 `settings`） |
|---|---|
| `data/datasources/%feature%_remote_datasource.dart` | `lib/features/settings/data/datasources/settings_remote_datasource.dart` |
| `data/datasources/%feature%_local_datasource.dart` | `lib/features/settings/data/datasources/settings_local_datasource.dart` |
| `data/models/%feature%_dto.dart` | `lib/features/settings/data/models/settings_dto.dart` |
| `data/repositories/%feature%_repository_impl.dart` | `lib/features/settings/data/repositories/settings_repository_impl.dart` |
| `domain/entities/%feature%.dart` | `lib/features/settings/domain/entities/settings.dart` |
| `domain/repositories/%feature%_repository.dart` | `lib/features/settings/domain/repositories/settings_repository.dart` |
| `domain/usecases/get_%feature%_usecase.dart` | `lib/features/settings/domain/usecases/get_settings_usecase.dart` |
| `presentation/pages/%feature%_page.dart` | `lib/features/settings/presentation/pages/settings_page.dart` |
| `presentation/view_models/%feature%_view_model.dart` | `lib/features/settings/presentation/view_models/settings_view_model.dart` |
| `presentation/states/%feature%_state.dart` | `lib/features/settings/presentation/states/settings_state.dart` |

重命名文件，打开每个文件，再替换内容。然后填入真实的端点、DTO 字段、实体字段、state 字段、UseCase 签名。

## 步骤清单

1. [ ] 决定 feature 名：单数、snake_case、无动词前缀（例如 `post`，不是 `add_post`）。
2. [ ] 把模板树拷到 `lib/features/<name>/`。
3. [ ] 在文件名和内容里做 `%feature%` / `%Feature%` 替换。
4. [ ] 裁剪用不到的模板 —— 比如 feature 无本地缓存，就删掉 `%feature%_local_datasource.dart` 并在 repository impl 里移除其 provider 接线。
5. [ ] 在 remote datasource 上填 Retrofit 端点和路径参数。
6. [ ] 填 DTO 字段（严格对齐 API 响应；JSON key 与 Dart 字段不一致时用 `@JsonKey`）。
7. [ ] 填 DTO 的 `toEntity()` 扩展。
8. [ ] 填 Entity 字段（domain —— 不要 JSON 注解）。
9. [ ] 填 Repository 接口方法（全部返回 `Future<Result<T>>`）。
10. [ ] 用 `try { await _remote.xxx(); } on AppException catch` 模式填 Repository 实现；`.asApi()` 只放在 Retrofit DataSource adapter。
11. [ ] 把每个 UseCase 写成小类，带 `call(...)` 方法。
12. [ ] 为 repository 和每个 UseCase 增加 Riverpod provider（函数式），与 impl 同一文件。
13. [ ] 填 State 字段（必有 `isLoading` + `Failure? error`；再加领域数据字段）。
14. [ ] 填 ViewModel —— `build()` 返回初始 state；每个动作读 UseCase provider 并对 `Result` switch。
15. [ ] 填 Page —— `@RoutePage()`；读 state 就用 `ConsumerWidget`。
16. [ ] 在 page 文件底部创建 `_XxxWidget` 私有类，或放 `presentation/widgets/` 若 feature 内共享。
17. [ ] 在 `lib/app/app_router.dart` 注册路由，受保护加 `guards: [_authGuard]`。
18. [ ] 在 `lib/i18n/en.i18n.json` 和 `lib/i18n/zh.i18n.json` 的 `<name>` 命名空间下同步加 i18n key，保持结构对称。
19. [ ] 跑 `tool/gen.sh` —— 会执行 `build_runner build --delete-conflicting-outputs` + `dart run slang`。
20. [ ] 跑 `tool/format.sh`（80 字符强制换行）。
21. [ ] 跑 `tool/test.sh` 并修复任何 lint / 架构测试失败。
22. [ ] 写测试 —— 精确模式见 `flutter-arms-testing` skill。

## 常见错误

- ❌ 把 `.asApi()` 写在 Repository，而不是 Retrofit DataSource adapter → 传输细节泄漏进仓储层。
- ❌ 在 ViewModel 或 Page 里 import `app_exception.dart` → 架构测试挂（规则 2）。
- ❌ 跨 feature import 没加 `// arch-exempt: <reason>` → 架构测试挂（规则 4）。
- ❌ `zh.i18n.json` 缺了对应 key → `dart run slang` 代码生成失败。
- ❌ 加了 `@freezed` / `@riverpod` / `@RoutePage()` / `@RestApi()` 后忘了再跑 `tool/gen.sh` → 构建报错找不到 `_$Xxx`。
- ❌ Page 用 `StatefulWidget` + 手动 `setState` 来持表单值 —— state 应放 ViewModel，表单用 `initialValue`。
- ❌ Repository throw 而非 `return Result.failure(...)` → UI 无法按契约处理。
- ❌ 用 `StateProvider<bool>(...)` 而非 `@riverpod class` —— 老 API，不在批准清单。
- ❌ Entity import 了 DTO 或 DTO 的 freezed 文件 → domain 应当只有 domain 类型。
- ❌ 手写 `copyWith` —— 让 Freezed 生成。
- ❌ 把默认 repository provider 放在 impl 文件**之外** —— 违反"一个 feature 模块、一个 DI 接线点"；网络 adapter 的可替换 provider 可以单独放在 datasource provider 文件。

## 命名约定一览

| 种类 | 模式 | 示例 |
|---|---|---|
| Feature 文件夹 | snake_case 单数 | `settings`、`post`、`search` |
| Entity 类 | PascalCase 单数 | `Post`、`Settings` |
| DTO 类 | `<Entity>Dto` | `PostDto`、`SettingsDto` |
| Repository 接口 | `<Feature>Repository` | `PostRepository` |
| Repository 实现 | `<Feature>RepositoryImpl` | `PostRepositoryImpl` |
| 远端 DS | `<Feature>RemoteDataSource` | `PostRemoteDataSource` |
| 本地 DS | `<Feature>LocalDataSource` | `PostLocalDataSource` |
| UseCase | `<Verb><Feature>UseCase` | `GetPostUseCase`、`DeletePostUseCase` |
| 页面级 ViewModel | `<Feature>ViewModel` | `PostViewModel` |
| 全局 Notifier | `<Feature>Notifier` | `AuthNotifier` |
| State 类 | `<Feature>State` | `PostState` |
| Page widget | `<Feature>Page` | `PostPage` |
| AutoRoute 类（生成） | `<Feature>Route` | `PostRoute` |
| 函数式 provider | lowerCamelCase | `postRepository`、`getPostUseCase`、`postRemoteDataSource` |
| 私有子 widget | `_<Name>` | `_PostHeader`、`_PostListTile` |
