# Flutter Arms 架构说明

> 最后更新：2026-04-17

## 1. 总览

Flutter Arms 采用 **Clean Architecture + MVVM**，按 feature 切分模块：

```
lib/
├── app/                  # 引导层：bootstrap、环境、路由、ProviderScope
│   ├── app.dart
│   ├── app_env.dart      # AppEnv（--dart-define 注入）
│   ├── app_router.dart
│   └── bootstrap.dart    # runZonedGuarded + 错误捕获 + Hive 初始化
├── core/                 # 框架无关工具：网络、存储、错误、日志、主题、i18n 胶水
│   ├── error/            # AppException（Data）+ Failure/FailureCode（Domain/Presentation）
│   ├── locale/
│   ├── logger/
│   ├── network/          # dio_client、TokenInterceptor、ApiInterceptor、dio_ext
│   ├── result/           # Result<T> + ResultX 扩展
│   ├── storage/
│   └── theme/
├── features/             # 业务切片：<feature>/{data, domain, presentation}
│   ├── auth/             # 登录、Token 刷新、鉴权守卫
│   ├── home/             # 首页 Tab（含 profile 设置页）
│   ├── onboarding/
│   └── splash/
├── i18n/                 # slang 翻译（*.i18n.json → strings.g.dart）
├── shared/               # 跨 feature UI 组件
├── main_dev.dart         # bootstrap(flavor: dev)
└── main_prod.dart        # bootstrap(flavor: prod)
```

## 2. 分层契约

每个 feature 目录下强制遵循：

### 2.1 Data 层
- **职责**：远程 API（Retrofit）、本地存储（Hive）、DTO ↔ 实体的 mapper。
- **可 import**：`dio`、`retrofit`、`hive_ce`、`core/error/app_exception*.dart`。
- **不可 import**：`features/*/presentation/**`。

### 2.2 Domain 层
- **职责**：UseCase、Entity、Repository 接口、Failure 契约。
- **可 import**：`core/result/**`、`core/error/failure.dart`、`meta`。
- **不可 import**：`dio` / `retrofit` / `hive_ce` / `AppException`（架构测试强制）。

### 2.3 Presentation 层
- **职责**：Page、Widget、ViewModel（Riverpod Notifier）、State。
- **可 import**：`flutter`、`flutter_riverpod`、`auto_route`、自身 domain。
- **不可 import**：其他 feature 的 presentation；`AppException`。

### 2.4 架构测试
`test/core/architecture_test.dart` 使用 AST 级文本扫描强制以下规则：

1. `lib/features/**/domain/**` 不得 import Data 层运输包（dio/hive/retrofit）。
2. `lib/features/**/{domain,presentation}/**` 不得 import `app_exception*.dart`。
3. `lib/core/**` 不得 import `lib/features/**`（允许文件级 `// arch-exempt` 豁免）。
4. `features/<X>` 不得 import `features/<Y>`（允许文件级 `// arch-exempt` 豁免）。

**当前豁免**（全部为 auth 跨切面能力）：
- `core/network/dio_client.dart` → `features/auth/data/datasources/auth_remote_datasource.dart`（TokenInterceptor 刷新链）。
- `features/home/presentation/pages/profile_page.dart` → `features/auth/.../auth_notifier.dart`（登出能力）。
- `features/splash/presentation/pages/splash_page.dart` → `features/auth/.../auth_notifier.dart`（登录态跳转）。

未来若 auth 需进一步下沉，可考虑抽出 `core/auth/` 或 `AuthPort` 接口。

## 3. 错误模型（路径 3：双层分离）

```
 Remote/Retrofit           Repository              ViewModel/UI
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
  final dto = await _remote.xxx(body).asApi();   // dio_ext 扩展
  return Result.success(dto.toEntity());
} on AppException catch (e) {
  return Result.failure(Failure.fromException(e));
}
```

`dio_ext.dart` 的 `Future<T>.asApi()` 将任意未知异常转为 `UnknownException`，保证 Repository 之外只见 `AppException`。

### 3.5 UI 层取文案
`context.failureMessage(failure)` 返回本地化文案：
- 先尝试 `badResponse`/`validation` 的 `detail`（服务端 / 校验器提供的具体文案）。
- 否则取 `t.errors.<code>`（i18n 兜底）。

## 4. Provider 拓扑

核心 Provider 都标注 `@Riverpod(keepAlive: true)`，在 `bootstrap` 的 `ProviderScope.overrides` 里注入基建。

| Provider | 作用 | 注入方式 |
|----------|------|----------|
| `appEnvProvider` | 运行时 flavor 配置 | bootstrap override |
| `appLoggerProvider` | Talker logger 实例 | bootstrap override |
| `kvStorageProvider` | Hive 封装 | 初次访问时懒加载（依赖 `HiveKvStorage.instance`）|
| `dioProvider` / `authRefreshDioProvider` | 业务 Dio + 刷新专用 Dio | 依赖 env/logger/storage |
| `localeProvider` | slang locale state | 启动时从 storage 恢复 |
| `themeProvider` / `themeSeedColorProvider` | 主题 state | storage 持久化 |

架构选择：**所有静态 Singleton 已淘汰**（原 `AppEnv.current`/`AppLogger.instance` 已移除），全部走 Provider，使测试可精准 override。

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
