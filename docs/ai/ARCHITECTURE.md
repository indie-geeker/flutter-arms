# Flutter Arms 架构说明

> 最后更新：2026-07-01

## 1. 总览

Flutter Arms 采用 **Clean Architecture + MVVM**，按 feature 切分模块：

```
lib/
├── app/                  # 引导层：bootstrap、环境、路由、ProviderScope
│   ├── app.dart
│   ├── app_env.dart      # AppEnv（--dart-define 注入）
│   ├── app_router.dart
│   └── bootstrap.dart    # runZonedGuarded + 错误捕获 + 基建初始化/注入
├── core/                 # 框架无关端口与默认适配器
│   ├── auth/             # AuthTokenRefresher 端口
│   ├── error/            # AppException（Data）+ Failure/FailureCode（Domain/Presentation）
│   ├── locale/
│   ├── logger/           # AppLog 端口 + Talker 适配器 + dev 日志面板入口
│   ├── network/          # ApiClient/ApiRequest 端口、Dio adapter、TokenInterceptor
│   ├── result/           # Result<T> + ResultX 扩展
│   ├── storage/
│   └── theme/
├── features/             # 业务切片：<feature>/{application,data,domain,presentation}
│   ├── auth/             # 登录、Token 刷新、鉴权守卫
│   ├── home/             # 首页 Tab（含 profile 设置页）
│   ├── onboarding/
│   └── splash/
├── i18n/                 # slang 翻译（*.i18n.json → strings.g.dart）
├── shared/               # 跨 feature UI 组件
├── main_dev.dart         # bootstrap(flavor: dev)
└── main_prod.dart        # bootstrap(flavor: prod)
```

### 1.1 仓库形态决策

默认仓库形态是**单 Flutter app package**。模板面向独立开发者，优先优化：

- fork 后快速改名、运行、调试和发布。
- 单套 `pubspec.yaml`、单套代码生成命令、单套 IDE workspace。
- 用架构测试和 Provider 注入维护边界，而不是一开始拆成多个 package。

不默认启用 Melos。只有满足以下条件之一时才考虑升级：

- 同一仓库维护多个 app。
- `core`、`shared UI` 或业务能力需要跨项目复用或独立发布。
- CI 需要 package 级缓存、并行测试和独立版本管理。
- 团队规模或所有权边界已经稳定，拆包收益大于依赖管理成本。

在默认单体模式下，基础设施优先使用端口隔离：日志、存储、网络、认证会话属于高优先级；
普通业务 feature 默认留在 `lib/features/<feature>` 内，不按 feature 拆 package。
具体升级预案见 [MELOS_DECISION.md](./MELOS_DECISION.md)。

## 2. 分层契约

每个 feature 目录下强制遵循：

### 2.1 Application 层
- **职责**：Provider 组合、用例注入、跨层端口实现（例如 auth token refresher、当前会话读取）。
- **可 import**：本 feature 的 `domain/**`、必要的 `data/**` 实现、`core/**` 端口。
- **不可 import**：Flutter UI、页面组件、其他 feature 的 presentation。

### 2.2 Data 层
- **职责**：远程 API adapter、本地存储、DTO ↔ 实体 mapper、Repository 实现。
- **远程数据源拆分**：
  - `*_remote_datasource.dart` 只放纯 Dart 接口，不写 `@RestApi`，不 import Dio/Retrofit。
  - `retrofit_*_remote_datasource.dart` 是默认 adapter，适合快速 REST CRUD。
  - `api_client_*_remote_datasource.dart` 是对照 adapter，适合学习和长期替换网络库。
- **可 import**：`dio`、`retrofit`、`hive_ce`、`core/error/app_exception*.dart`、`core/network/api_client.dart`。
- **不可 import**：`features/*/presentation/**`。

### 2.3 Domain 层
- **职责**：UseCase、Entity、Repository 接口、Failure 契约。
- **可 import**：`core/result/**`、`core/error/failure.dart`、`meta`。
- **不可 import**：`dio` / `retrofit` / `hive_ce` / `AppException`（架构测试强制）。

### 2.4 Presentation 层
- **职责**：Page、Widget、ViewModel（Riverpod Notifier）、State。
- **可 import**：`flutter`、`flutter_riverpod`、`auto_route`、自身 `application/**`、自身 domain/entity/usecase 类型。
- **不可 import**：本 feature 的 `data/**`、domain repository 接口、其他 feature 的 presentation、`AppException`。

### 2.5 架构测试
`test/core/architecture_test.dart` 使用 AST 级文本扫描强制以下规则：

1. `lib/features/**/domain/**` 不得 import Data 层运输包（dio/hive/retrofit）。
2. `lib/features/**/{domain,presentation}/**` 不得 import `app_exception*.dart`。
3. `lib/core/**` 不得 import `lib/features/**`（允许文件级 `// arch-exempt` 豁免）。
4. `features/<X>` 不得 import `features/<Y>`（允许文件级 `// arch-exempt` 豁免）。
5. `features/**/presentation/**` 默认不得 import 本 feature 的 `data/**` 或 `domain/repositories/**`。

`// fast-track` 只保留给明确的小实验页面，不作为核心示例默认写法。

**当前豁免**：
- `features/home/presentation/pages/profile_page.dart` → `features/auth/.../auth_notifier.dart`（登出能力）。
- `features/splash/presentation/pages/splash_page.dart` → `features/auth/.../auth_notifier.dart`（登录态跳转）。

`core/network` 不再 import auth data。Token 刷新通过 `core/auth/AuthTokenRefresher` 端口注入。

## 3. 错误模型（路径 3：双层分离）

```
 Remote/Retrofit/ApiClient  Repository              ViewModel/UI
   ┌──────────┐   catch    ┌─────────────┐   return  ┌──────────┐
   │DioError  │──────────▶│AppException │──────────▶│ Failure  │
   └──────────┘  mapper   └─────────────┘  .from()   └──────────┘
                                                         │
                                                   FailureCode.*
                                                         │
                                               i18n: t.errors.<code>
```

### 3.1 AppException（Data 层内部）
`lib/core/error/app_exception.dart`：`sealed class AppException`，具备 7 个子类（Network / Timeout / BadResponse / Auth / Validation / Cancelled / Unknown）。

### 3.2 AppExceptionMapper
`lib/core/error/app_exception_mapper.dart`：将 `DioException` 转为对应 `AppException` 子类；抽取响应体里的 `message`/`msg`/`error` 作为 `detail`。

### 3.3 Failure（Domain/Presentation）
`lib/core/error/failure.dart`：单一值类 `Failure(code, cause?, stackTrace?, detail?)`。`FailureCode` 为枚举：network / timeout / badResponse / auth / validation / cancelled / unknown。

### 3.4 转换时机
Repository 实现里：

```dart
try {
  final dto = await _remote.xxx(body);   // DataSource adapter 保证失败时抛 AppException
  return Result.success(dto.toEntity());
} on AppException catch (e) {
  return Result.failure(Failure.fromException(e));
}
```

Retrofit adapter 内部使用 `Future<T>.asApi()` 解封或转换 Dio 错误；`ApiClient` adapter 直接从 `ApiClient.send(...)` 接收解码结果或 `AppException`。Repository 只处理纯 data source 接口，不 import Dio/Retrofit。

### 3.5 UI 层取文案
`context.failureMessage(failure)` 返回本地化文案：
- 先尝试 `badResponse`/`validation` 的 `detail`（服务端 / 校验器提供的具体文案）。
- 否则取 `t.errors.<code>`（i18n 兜底）。

## 4. Provider 拓扑

核心 Provider 都标注 `@Riverpod(keepAlive: true)`，在 `bootstrap` 的 `ProviderScope.overrides` 里注入基建。

| Provider | 作用 | 注入方式 |
|----------|------|----------|
| `appEnvProvider` | 运行时 flavor 配置 | bootstrap override |
| `appLoggerProvider` | `AppLog` 日志端口 | 默认 Talker adapter，bootstrap 可 override |
| `devLogViewerProvider` | dev 日志面板入口 | 仅在 logger 是 Talker adapter 时可用 |
| `kvStorageProvider` | `KvStorage` 端口 | bootstrap 通过 `StorageInitializer` 初始化后 override |
| `dioProvider` / `authRefreshDioProvider` | 业务 Dio + 刷新专用 Dio | 依赖 env/logger/storage |
| `apiClientProvider` | `ApiClient` 网络端口 | 默认 `DioApiClient` adapter |
| `authTokenRefresherProvider` | Token 刷新端口 | 默认 noop，bootstrap override 为 auth 实现 |
| `localeProvider` | slang locale state | 启动时从 storage 恢复 |
| `themeProvider` / `themeSeedColorProvider` | 主题 state | storage 持久化 |

架构选择：业务代码不直接读取静态 Singleton。`AppEnv`、日志、存储、网络和认证刷新都通过 Provider 组合；即使某个 adapter 内部有实例缓存，也只在 adapter 边界内使用，使测试可精准 override。

## 5. 路由守卫

`lib/app/app_router.dart` 中的 `AuthGuard`：
- 监听 `authNotifierProvider`（`reevaluateListenable`），登录态变化自动重评估所有路由。
- 未登录访问受保护页面 → 重定向到 `LoginRoute`，登录成功后 pop 回原页面。

## 6. 全局错误捕获

`lib/app/bootstrap.dart`：

```dart
await runZonedGuarded<Future<void>>(
  () async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (d) => logger.handle(d.exception, d.stack, 'FlutterError');
    PlatformDispatcher.instance.onError = (e, s) { logger.handle(e, s, 'PlatformDispatcher'); return true; };
    ...
    runApp(ProviderScope(overrides: [...], observers: const [AppProviderObserver()], child: const App()));
  },
  (e, s) => logger.handle(e, s, 'ZoneUncaught'),
);
```

覆盖：UI 构建错误、平台异常、Zone 未捕获 Future、Provider 失败（`AppProviderObserver.providerDidFail`）。

## 7. 环境注入

- `env/{dev,prod}.example.json` 为模板。复制为 `env/{dev,prod}.json`（已 gitignore）后填真实值。
- `tool/run_dev.sh`/`tool/run_prod.sh` 自动带上 `--dart-define-from-file`。
- `AppEnv.fromFlavor` 使用 `String.fromEnvironment` / `bool.fromEnvironment` + `bool.hasEnvironment` 作为回退优先级：`--dart-define` > flavor 默认值。

## 8. 新增 Feature 的 checklist

见 [TEMPLATE_GUIDE.md](./TEMPLATE_GUIDE.md)。
