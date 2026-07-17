# Flutter Arms 模板派生指南

> 目的：从本模板衍生一个新 Flutter 项目的最短路径。
> 最后更新：2026-07-16

## 1. 一次性改名（派生时）

### 1.1 一键改名

不要手工全局替换。运行跨平台脚本：

```bash
dart tool/rename.dart \
  --name my_app \
  --package com.example.my_app \
  --display "My App"
```

脚本会同步 Dart package/import、Android applicationId/namespace/Kotlin 路径、
iOS/macOS bundle id、Linux/Windows/Web 名称。省略参数会进入交互提问；
`--ios-bundle-id` 可覆盖自动推导值。完成后按脚本输出执行
`flutter clean && flutter pub get && tool/gen.sh`，再检查 `git status`。

### 1.2 替换品牌资源

- `assets/icon/app_icon.png` → 你的图标（1024×1024 PNG）。
- `assets/splash/logo.png` → 启动屏 Logo（透明背景 PNG）。
- 生成：
  ```bash
  dart run flutter_launcher_icons
  dart run flutter_native_splash:create
  ```

### 1.3 配置环境

```bash
cp env/dev.example.json env/dev.json
cp env/prod.example.json env/prod.json
# 编辑 env/*.json 填真实 API_BASE_URL / APP_NAME / ENABLE_LOG / USE_MOCK_API
```

`env/*.json` 已在 `.gitignore`，不会误提交。

### 1.4 Mock API（开箱即用的登录与反馈中心）

模板**默认开启 `USE_MOCK_API=true`**（仅 dev flavor），`MockApiInterceptor`
会短路 `/auth/*` 与 `/feedback/*`，返回确定性响应。派生项目第一次
`flutter run` 即可走通登录（演示凭据：`admin / admin`）、FAQ 搜索、反馈提交、
历史与详情，无需等待后端同步就绪。Mock 只替换 transport，页面仍经过
Retrofit/Dio、Repository、UseCase 与 ViewModel 的生产链路。

切到真实后端：把 `env/dev.json` 里 `USE_MOCK_API` 置为 `"false"`。
彻底移除 mock 能力：
1. 删除 `lib/core/network/mock_api_interceptor.dart`。
2. 删除 `lib/core/network/dio_client.dart` 中对 `MockApiInterceptor` 的 import
   与 `if (env.useMockApi)` 两段。
3. 删除 `lib/app/app_env.dart` 中的 `useMockApi` 字段与相关分支。
4. 删除 `env/*.example.json` 里的 `USE_MOCK_API`。
5. 删除 `test/core/network/mock_api_interceptor_test.dart`。
6. 删除依赖 Mock transport 的
   `test/features/feedback/data/datasources/retrofit_feedback_remote_datasource_test.dart`。

**Prod flavor 永远强制 `useMockApi = false`**，即便 `env/prod.json` 传入
`"USE_MOCK_API": "true"` 也会被忽略（见 `AppEnv.fromFlavor` 的 prod 分支）——
防止 Mock 代码被带到线上。

### 1.5 默认功能边界

- `features/feedback` 默认启用并建议保留。它是通用产品能力，也是模板完整架构的
  canonical example；真实后端契约为 `GET /feedback/faqs?q=`、
  `GET /feedback`、`GET /feedback/{id}`、`POST /feedback`。
- `features/showcase` 是 dev-only Developer Lab，生产路由表不注册。派生项目验证完
  `AppDialog`/`super_overlay` 等基础能力后可直接删除。
- 默认底栏只有 Home 与 Profile；FAQ 搜索属于反馈中心，不提供全局 Search 占位页。

如果产品明确不需要反馈中心，删除 `lib/features/feedback`、对应三条路由、Profile
入口、`feedback` i18n 节点与 `test/features/feedback`，然后运行 `tool/gen.sh`。

### 1.6 安全短板处理（见 SECURITY.md §2.1）

上线前必须评估 Hive cipher key 存储方案（`flutter_secure_storage` 或鸿蒙兼容方案）。

## 2. 日常命令

```bash
# 运行
tool/run_dev.sh                           # dev flavor，带 --dart-define-from-file
tool/run_prod.sh                          # prod flavor，release 构建

# 代码生成
tool/gen.sh                               # build_runner + slang

# 清理 + 重新生成
tool/clean.sh && tool/gen.sh

# 本地 CI
tool/test.sh                              # analyze + test
tool/format.sh                            # dart format + --set-exit-if-changed
```

## 3. 新增 Feature 的 Checklist

新增一个 `xxx` feature，例如 `settings`：

可先运行 `dart tool/gen_feature.dart --name settings` 生成基础骨架。生成器默认同时产出 Retrofit adapter 和 ApiClient adapter，Repository 默认接入 Retrofit adapter；ApiClient adapter 作为对比学习和未来替换网络库的参考。

### 3.1 目录结构

```
lib/features/xxx/
├── application/
│   └── xxx_usecases.dart                 # 用例 Provider / 组合层
├── data/
│   ├── datasources/
│   │   ├── xxx_remote_datasource.dart    # 纯 Dart 接口
│   │   ├── retrofit_xxx_remote_datasource.dart
│   │   └── api_client_xxx_remote_datasource.dart
│   ├── models/
│   │   └── xxx_dto.dart                  # Freezed + json_serializable
│   └── repositories/
│       └── xxx_repository_impl.dart      # try/catch AppException → Failure
├── domain/
│   ├── entities/
│   │   └── xxx.dart
│   ├── repositories/
│   │   └── xxx_repository.dart
│   └── usecases/
│       └── get_xxx_usecase.dart
└── presentation/
    ├── pages/
    │   └── xxx_page.dart                  # @RoutePage()
    ├── view_models/
    │   └── xxx_notifier.dart              # @Riverpod
    ├── states/
    │   └── xxx_state.dart                 # Freezed
    └── widgets/
```

### 3.2 Data 层要点
- `xxx_remote_datasource.dart` 只定义纯 Dart 接口，不 import `dio` / `retrofit`。
- Retrofit 写法放在 `retrofit_xxx_remote_datasource.dart`，默认 Provider 注入这个 adapter，适合快速 REST CRUD。
- ApiClient 写法放在 `api_client_xxx_remote_datasource.dart`，用于学习和长期替换网络库；它只依赖 `ApiClient` / `ApiRequest`，不直接依赖 Dio。
- Repository 只依赖纯 data source 接口，并捕获 `AppException` 转 `Failure`：
  ```dart
  try {
    final dto = await _remote.get();
    return Result.success(dto.toEntity());
  } on AppException catch (e) {
    return Result.failure(Failure.fromException(e));
  }
  ```
- Retrofit adapter 内部调用 `.asApi()`；ApiClient adapter 由 `ApiClient.send(...)` 统一抛 `AppException`。
- DTO → Entity 的 mapper 写在 DTO 文件的扩展里（不要反向污染）。

### 3.3 Domain 层要点
- **不能 import** `dio` / `hive` / `retrofit` / `app_exception*.dart`（架构测试强制）。
- Repository 接口返回 `Future<Result<T>>` 或 `Stream<T>`。
- UseCase 仅做编排 + 业务规则。

### 3.4 Presentation 层要点
- 页面加 `@RoutePage()`，运行 `dart run build_runner build --delete-conflicting-outputs` 后路由自动生成。
- 在 `lib/app/app_router.dart` 的 `routes` 列表里添加新路由（如需守卫，加 `guards: [authGuard]`）。
- ViewModel 使用 `@riverpod` 注解。
- State 使用 `@freezed`。
- ViewModel 读取 `application/**` 暴露的 use case Provider，不直接 import `data/**` 或 `domain/repositories/**`。
- 错误展示：`context.failureMessage(failure)` 直接拿到本地化文案；badResponse/validation 会优先使用 `detail`。
- 全局 loading / toast / confirm dialog / popup 统一调用 `AppDialog`；feature 不直接 import `super_overlay`。
- 页面离开期间仍可能完成的请求，必须在 `finally` 中先关闭全局 loading，再检查 `context.mounted`。

### 3.5 i18n
- 在 `lib/i18n/en.i18n.json` 与 `zh.i18n.json` 对称添加文案。
- 跑 `dart run slang` 生成 `strings.g.dart`。
- UI 层通过 `context.t.<path>` 访问。

### 3.6 测试
每个新 feature 至少补齐：
- Repository 单测（mocktail mock DataSource，覆盖成功 / 404 / 401 / 超时）。
- ApiClient adapter 单测（fake `ApiClient`，断言 `ApiRequest` 的 method/path/body/decode）。
- ViewModel 单测（`ProviderContainer` + override）。
- Page widget 测（`TranslationProvider` + `ProviderScope.overrides`）。

参考：
- `test/features/auth/data/repositories/auth_repository_impl_test.dart`
- `test/features/auth/presentation/view_models/login_view_model_test.dart`
- `test/features/home/presentation/pages/profile_page_test.dart`

### 3.7 架构测试
无需手动维护。每次 `flutter test` 会自动跑 `test/core/architecture_test.dart`：
- 若新 feature 跨 feature 引用，会立即红线。如确实无法解耦，在 import 行上一行加 `// arch-exempt: <理由>`。
- 若 domain 误 import 了 dio/hive/retrofit，会立即红线。
- 若 presentation 直接 import data 或 repository 接口，会立即红线；临时 `// fast-track` 只用于小实验，不用于核心示例。

## 4. 常用扩展点

- **接入第三方 API**：优先用纯 data source 接口 + Retrofit adapter；如果希望降低未来换库成本，补 ApiClient adapter。
- **替换网络库**：保留 `ApiRequest` 语义，替换 `apiClientProvider` 的 adapter，再逐步迁移 data source。
- **替换日志**：实现 `AppLog`，override `appLoggerProvider`；普通 feature 不依赖 Talker。
- **替换存储初始化**：实现 `StorageInitializer`，在 bootstrap 注入新的 `KvStorage`。
- **离线缓存**：Hive box（`core/storage/kv_storage.dart` 已示范；新增时请遵循同一 cipher 策略）。
- **推送/埋点**：不进入模板内核。在 `app/bootstrap.dart` 里初始化，并通过 Provider/端口暴露。
- **自定义主题**：`core/theme/theme_notifier.dart` + `app_colors.dart`，seedColor 已持久化到 storage。

## 5. 什么时候升级到 Melos

默认不要升级。单体仓库更适合独立开发者派生模板、快速迭代和发布。
如果出现以下信号，再考虑把 `core`、`shared UI` 或多个 app 拆到 Melos workspace：

- 一个仓库需要维护多个 Flutter app。
- `core` 或 UI 组件要跨项目复用，甚至作为 package 发布。
- CI 时间明显受单 package 限制，需要 package 级缓存和并行测试。
- 团队/模块所有权稳定，拆包能降低协作成本，而不是只增加导入和生成复杂度。

即使升级，也优先拆基础设施和共享 UI，不要默认按 feature 拆 package。

详细预案见 [MELOS_DECISION.md](./MELOS_DECISION.md)。

## 6. 发布前 Checklist

- [ ] `docs/ai/SECURITY.md` §3 Checklist 逐项过一遍。
- [ ] `env/prod.json` 通过 CI Secret 注入，不进 git。
- [ ] `flutter analyze` 零告警。
- [ ] `flutter test` 全绿，包含 `test/core/architecture_test.dart`。
- [ ] `flutter build appbundle --flavor prod --dart-define-from-file=env/prod.json --obfuscate --split-debug-info=build/symbols`。
- [ ] 自测：无网 / 断网 / 弱网 / 401 刷新成功 / 401 刷新失败 / 连续 401。
- [ ] Profile → 长按头像（dev flavor）可通过 `devLogViewerProvider` 打开日志面板（release 构建里入口被 flavor 判断关闭）。
