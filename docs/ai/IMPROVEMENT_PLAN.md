# Flutter Arms 模板 改进计划

> 版本：v1.0 · 最后更新：2026-04-17
> 目的：将 Flutter Arms 打磨为一套可直接衍生新项目的独立开发者模板，填补安全/正确性坑，统一架构，补齐工程化最后一公里。

---

## 1. 背景与目标

### 1.1 定位
面向独立开发者的 Flutter 快速开发模板，基于 Clean Architecture + MVVM，预置 Riverpod 3、AutoRoute、Dio/Retrofit、Hive、slang、Talker 等常用栈。

### 1.2 目标
任何基于本模板的新项目：
1. **无需补安全短板**（认证链路、token 刷新、加密存储路径清晰）。
2. **无需重写错误模型**（Failure + i18n 开箱可用）。
3. **无需重新搭工程化**（CI、lint、splash、launcher icon、secret 注入、异常上报预置）。
4. **新增 feature 有明确 checklist**，测试与架构约束由测试强制。

### 1.3 非目标
- 不做运行时特性功能扩展（推送、埋点、定位等按需集成，不进模板内核）。
- 不追求多后端协议适配（只保留 Dio/REST，为未来扩展留接口即可）。
- 不引入复杂依赖（尽量用 pub.dev 主流包 + 少量胶水代码）。

---

## 2. 决策摘要

| 编号 | 决策 | 结论 |
|------|------|------|
| D1 | Hive cipher key 安全存储方案 | **搁置**（鸿蒙兼容考量）。docs/ai/SECURITY.md 留 TODO；未来上线前/接鸿蒙时再接入 |
| D2 | Failure i18n 模型 | **a**：Failure 携带 `FailureCode` 枚举，UI 层映射 `t.errors.*` |
| D3 | TokenInterceptor 刷新路径 | **a**：Interceptor 直调 `AuthRemoteDataSource.refreshToken` |
| D4 | Dev fallback 处理 | **a**：彻底删除 magic password 分支 |
| D5 | 模板范围 | **完整集**：Phase 0~4 全部落地 |
| D6 | Lint 规则集 | **a**：`very_good_analysis`（`public_member_api_docs` 延后至 Phase 4） |
| S2-dio | 刷新 Dio 拆分 | **a**：新建 `authRefreshDioProvider`（无 TokenInterceptor），解循环依赖 |
| Exception 模型 | **路径 3**：双层分离。`AppException` 在 Data 层，`Failure` 在 Domain/Presentation 层，Repository 做转换 |

---

## 3. 风险 × ROI 矩阵

| ID | 问题 | 风险 | ROI | 改动量 | 归属 |
|----|------|------|-----|--------|------|
| S1 | Hive cipher key 明文落盘 | 高·安全 | 高 | 中 | **Phase TODO** |
| S2 | TokenInterceptor 绕开 Repo，硬编码端点 | 中·正确性 | 高 | 中 | Phase 1 |
| S3 | 刷新失败路径让队列请求二次 401 | 中·正确性 | 高 | 小 | Phase 1 |
| S4 | AuthGuard 不响应登录态变化 | 中·UX | 高 | 小 | Phase 1 |
| S5 | Dev magic password 污染生产 Repository | 中·安全 | 高 | 小 | Phase 1 |
| A1 | Singleton vs Provider 双轨制 | 低 / 中（长期） | 高 | 中 | Phase 2 |
| A2 | Failure 仅携带硬编码中文 message | 低 | 高 | 中 | Phase 2 |
| A3 | `authNotifierProvider` 兼容别名遗留 | 低 | 中 | 小 | Phase 0 |
| A4 | `AppException` 死代码 | 低 | — | — | **取消（路径 3 重新启用）** |
| E1 | `analysis_options.yaml` 过松 | 低 | 高 | 小 | Phase 0 |
| E2 | 无 CI | 低 | 高 | 小 | Phase 0 |
| E3 | 无全局异常上报 | 中·线上盲区 | 高 | 小 | Phase 3 |
| E4 | `talker_flutter` 引入未使用 | 低 | 中 | 小 | Phase 3 |
| E5 | 无 native splash / launcher icon 预配置 | 低 | 中 | 小 | Phase 3 |
| E6 | dev/prod 差异弱，无 `--dart-define` 演示 | 低 | 中 | 小 | Phase 3 |
| Q1 | Result 缺 `when/fold/map` 便捷 API | 低 | 中 | 小 | Phase 2 |
| Q2 | Profile 页硬编码 `'User'`、默认 seed 色重复 | 低 | 小 | 小 | Phase 0 / 1 |
| Q3 | Splash 固定 350ms 延迟 | 低 | 小 | 小 | Phase 3 |
| Q4 | ProviderObserver 只实现 `didUpdateProvider` | 低 | 小 | 小 | Phase 2 |
| Q5 | `logout` 不调远端 | 低 | 小 | 小 | Phase 1 |
| Q6 | Timeout 三项共用一个常量 | 低 | 小 | 极小 | Phase 0 |

---

## 4. 架构设计

### 4.1 双层错误模型（路径 3）

```
┌──────────────────────────── Presentation ────────────────────────────┐
│  ViewModel  ─── switch(Result)  ───▶  UI (context.failureMessage)    │
└──────────────────────┬──────────────────────────┬────────────────────┘
                       │                          │
                       ▼                          ▼
                  Result<T>                   FailureCode
                  Failure ───────────────────▶  (enum → t.errors.*)
┌────────────────────────── Domain ───────────────────────────────────┐
│  UseCase → Repository interface                                     │
│  (仅使用 Result / Failure；不得 import AppException / Dio / Hive)    │
└──────────────────────┬──────────────────────────────────────────────┘
                       ▼
                 on AppException catch
                       ▲
┌────────────────────────── Data ─────────────────────────────────────┐
│  Repository impl  ◄── throw AppException ─── DataSource (.asApi())  │
│                             ▲                                        │
│              ApiInterceptor ─┘   (DioException.error = AppException) │
└──────────────────────────────────────────────────────────────────────┘
```

**职责契约**：

- **Data / DataSource**：抛 `AppException` 及其子类。不在签名中暴露 `DioException` / `HiveError`。
- **Data / Repository**：`on AppException catch` 转 `Result.failure(Failure.fromException(e))`。
- **Domain**：不感知 `AppException`。接口与实现仅使用 `Result<T>` / `Failure`。
- **Presentation**：`switch(Result)`；对 `Failure` 调 `t.errors.byCode(failure.code)` 取文案。

### 4.2 核心类型定义

```dart
// lib/core/error/failure_code.dart
enum FailureCode {
  network, timeout, badResponse, auth, validation, cancelled, unknown,
}

// lib/core/error/app_exception.dart
sealed class AppException implements Exception {
  const AppException({
    required this.code,
    this.cause,
    this.stackTrace,
    this.detail,
  });
  final FailureCode code;
  final Object? cause;
  final StackTrace? stackTrace;
  final String? detail;
}

final class NetworkException      extends AppException { const NetworkException({super.cause, super.stackTrace, super.detail}) : super(code: FailureCode.network); }
final class TimeoutException      extends AppException { const TimeoutException({super.cause, super.stackTrace, super.detail}) : super(code: FailureCode.timeout); }
final class BadResponseException  extends AppException { const BadResponseException({super.cause, super.stackTrace, super.detail}) : super(code: FailureCode.badResponse); }
final class AuthException         extends AppException { const AuthException({super.cause, super.stackTrace, super.detail}) : super(code: FailureCode.auth); }
final class ValidationException   extends AppException { const ValidationException({super.cause, super.stackTrace, super.detail}) : super(code: FailureCode.validation); }
final class CancelledException    extends AppException { const CancelledException({super.cause, super.stackTrace, super.detail}) : super(code: FailureCode.cancelled); }
final class UnknownException      extends AppException { const UnknownException({super.cause, super.stackTrace, super.detail}) : super(code: FailureCode.unknown); }

// lib/core/error/failure.dart
final class Failure {
  const Failure({
    required this.code,
    this.cause,
    this.stackTrace,
    this.detail,
  });
  final FailureCode code;
  final Object? cause;
  final StackTrace? stackTrace;
  final String? detail;

  factory Failure.fromException(AppException e) => Failure(
        code: e.code,
        cause: e.cause ?? e,
        stackTrace: e.stackTrace,
        detail: e.detail,
      );
}
```

### 4.3 降样板：`ApiInterceptor` + `.asApi()` 扩展

```dart
// lib/core/error/app_exception_mapper.dart
class AppExceptionMapper {
  static AppException fromDio(DioException e, [StackTrace? st]) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(cause: e, stackTrace: st);
      case DioExceptionType.badResponse:
        return e.response?.statusCode == 401
            ? AuthException(cause: e, stackTrace: st, detail: _extractMsg(e))
            : BadResponseException(cause: e, stackTrace: st, detail: _extractMsg(e));
      case DioExceptionType.cancel:
        return CancelledException(cause: e, stackTrace: st);
      case DioExceptionType.connectionError:
        return NetworkException(cause: e, stackTrace: st);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnknownException(cause: e, stackTrace: st);
    }
  }
  static String? _extractMsg(DioException e) => /* 解析 response.data.message */;
}

// lib/core/network/api_interceptor.dart (改造)
@override
void onError(DioException err, ErrorInterceptorHandler handler) {
  final appEx = AppExceptionMapper.fromDio(err, err.stackTrace);
  handler.next(DioException(
    requestOptions: err.requestOptions,
    response: err.response,
    type: err.type,
    error: appEx,
    stackTrace: err.stackTrace,
  ));
}

// lib/core/network/dio_ext.dart
extension ThrowAppExceptionX<T> on Future<T> {
  Future<T> asApi() => catchError((Object e, StackTrace st) {
    if (e is DioException && e.error is AppException) {
      throw e.error! as AppException;
    }
    throw UnknownException(cause: e, stackTrace: st);
  });
}
```

**DataSource 调用写法**：

```dart
@override
Future<UserModel> me() => _api.me().asApi();
```

**Repository 调用写法**：

```dart
try {
  final token = await _remote.login(body);
  await _local.saveToken(token);
  final user = await _remote.me();
  await _local.saveUser(user);
  return Result.success(user.toEntity());
} on AppException catch (e) {
  return Result.failure(Failure.fromException(e));
}
```

### 4.4 Result 扩展 API（Phase 2 新增）

```dart
extension ResultX<T> on Result<T> {
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => switch (this) {
        Success<T>(:final data)            => success(data),
        FailureResult<T>(:final failure_)  => failure(failure_),
      };

  Result<R> map<R>(R Function(T) f) => switch (this) {
        Success<T>(:final data)            => Result.success(f(data)),
        FailureResult<T>(:final failure_)  => Result.failure(failure_),
      };

  Result<T> mapFailure(Failure Function(Failure) f) => switch (this) {
        Success<T>()                       => this,
        FailureResult<T>(:final failure_)  => Result.failure(f(failure_)),
      };

  T getOrElse(T fallback) => this is Success<T> ? (this as Success<T>).data : fallback;
  T? getOrNull() => this is Success<T> ? (this as Success<T>).data : null;
}
```

### 4.5 i18n 错误文案

`lib/i18n/strings_*.i18n.json` 增加：

```jsonc
{
  "errors": {
    "network":     "网络连接失败，请检查网络设置",
    "timeout":     "请求超时，请检查网络后重试",
    "badResponse": "服务响应异常",
    "auth":        "登录已过期，请重新登录",
    "validation":  "参数校验失败",
    "cancelled":   "请求已取消",
    "unknown":     "发生未知错误，请稍后重试"
  }
}
```

UI 辅助：

```dart
extension FailureL10nX on BuildContext {
  String failureMessage(Failure f) {
    final t = this.t;
    return switch (f.code) {
      FailureCode.network     => t.errors.network,
      FailureCode.timeout     => t.errors.timeout,
      FailureCode.badResponse => f.detail ?? t.errors.badResponse,
      FailureCode.auth        => t.errors.auth,
      FailureCode.validation  => f.detail ?? t.errors.validation,
      FailureCode.cancelled   => t.errors.cancelled,
      FailureCode.unknown     => t.errors.unknown,
    };
  }
}
```

### 4.6 Dio 拆分（解 S2 循环依赖）

```dart
// core/network/dio_client.dart
@Riverpod(keepAlive: true)
Dio authRefreshDio(Ref ref) {
  return Dio(BaseOptions(
    baseUrl: ref.read(appEnvProvider).baseUrl,
    connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
    receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
    sendTimeout:    const Duration(milliseconds: AppConstants.sendTimeoutMs),
  ))..interceptors.add(const ApiInterceptor()); // 仅 error mapping，无 TokenInterceptor
}

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRefreshDataSource(Ref ref) =>
    AuthRemoteDataSource(ref.read(authRefreshDioProvider));
```

`TokenInterceptor.refreshAction` 改为直调 `ref.read(authRefreshDataSourceProvider).refreshToken(...)`，不再自建 Dio，不再硬编码 `/auth/refresh`。

---

## 5. Phase 分解

### Phase 0 — 基础加固（0.5d）

| # | 任务 | 文件 / 说明 |
|---|------|-------------|
| 0.1 | 切 `very_good_analysis`（暂关 `public_member_api_docs`） | [analysis_options.yaml](analysis_options.yaml) |
| 0.2 | `dart format .` 全量修复 | 全项目 |
| 0.3 | GitHub Actions：`flutter analyze` + `flutter test` + `format --set-exit-if-changed` | `.github/workflows/ci.yml` |
| 0.4 | 删 [exceptions.dart](lib/core/error/exceptions.dart)（内容将在 Phase 2 重写为路径 3 版本） | 暂留空占位或直接删，Phase 2 重建 |
| 0.5 | 删 `authNotifierProvider` 兼容别名，全项目 rename 为 `authProvider` | [auth_notifier.dart:29](lib/features/auth/presentation/view_models/auth_notifier.dart:29) + 所有引用点 |
| 0.6 | 提 `kDefaultSeedColor` 到 [app_colors.dart](lib/core/theme/app_colors.dart) | 替换 [kv_storage.dart:163](lib/core/storage/kv_storage.dart:163)、[profile_page.dart:19](lib/features/home/presentation/pages/profile_page.dart:19) |
| 0.7 | 拆 `connectTimeoutMs` / `receiveTimeoutMs` / `sendTimeoutMs` | [app_constants.dart](lib/core/constants/app_constants.dart) |
| 0.8 | [login_page.dart:42](lib/features/auth/presentation/pages/login_page.dart:42) `const TextStyle` → `Theme.of(context).textTheme.headlineSmall` | 顺手 |
| 0.9 | [profile_page.dart](lib/features/home/presentation/pages/profile_page.dart) 英文注释改中文 | 顺手 |

### Phase 1 — 登录链路正确性（1d）

| # | 任务 | 文件 / 说明 |
|---|------|-------------|
| 1.1 | **S2** 新增 `authRefreshDioProvider` + `authRefreshDataSourceProvider`（无 TokenInterceptor） | [dio_client.dart](lib/core/network/dio_client.dart)、[auth_remote_datasource.dart](lib/features/auth/data/datasources/auth_remote_datasource.dart) |
| 1.2 | **S2** `TokenInterceptor.refreshAction` 改调 `authRefreshDataSourceProvider`；删除自建 refreshDio 与硬编码 URL | [dio_client.dart:40-64](lib/core/network/dio_client.dart:40) |
| 1.3 | **S3** `_waitQueue` 在刷新失败时改 `completeError(err)`；新增并发 401 单元测试 | [token_interceptor.dart:70-80](lib/core/network/token_interceptor.dart:70) |
| 1.4 | **S4** 新建 `AuthListenable(ref)`（`ChangeNotifier` 订阅 `authProvider`）；`AuthGuard.reevaluateListenable` 接入 | [app_router.dart](lib/app/app_router.dart) |
| 1.5 | **S5** 删 dev magic password 分支 | [auth_repository_impl.dart:46-59](lib/features/auth/data/repositories/auth_repository_impl.dart:46) |
| 1.6 | **Q5** `AuthRemoteDataSource` 加 `logout()`；Repository `logout()` best-effort 调远端后清本地 | [auth_remote_datasource.dart](lib/features/auth/data/datasources/auth_remote_datasource.dart)、[auth_repository_impl.dart:69-72](lib/features/auth/data/repositories/auth_repository_impl.dart:69) |
| 1.7 | **Q2a** [profile_page.dart:94](lib/features/home/presentation/pages/profile_page.dart:94) `_UserHeader` 改为从 `kvStorageProvider.getUserMap()` 或新增 `currentUserProvider` 读取真实用户 | Profile 页 |
| 1.8 | [auth_repository_impl.dart:93-103](lib/features/auth/data/repositories/auth_repository_impl.dart:93) `getCurrentUser` 去掉防御性 `on Object catch`（纯本地读 Hive，异常不会发生） | 顺手 |
| 1.9 | **决策**：`refreshTokenUseCase` **保留**（给未来 UI 主动刷新 / 测试使用），在 [auth_repository_impl.dart:128-131](lib/features/auth/data/repositories/auth_repository_impl.dart:128) 补注释说明 | 标注 |

### Phase 2 — 架构一致性 + 错误模型（1.8d）

#### 2a. 全局 Singleton → Provider (A1)

| # | 任务 | 说明 |
|---|------|------|
| 2.1 | 新建 `appEnvProvider(keepAlive)`，删 `AppEnv.current` 静态字段 | bootstrap 先 `container.read(appEnvProvider.notifier).setup(flavor)` 再传给 `ProviderScope` |
| 2.2 | `AppLogger` 只保留 provider，删 `AppLogger.instance` static | — |
| 2.3 | `HiveKvStorage.ensureInitialized()` 只允许 bootstrap 调用；其他位置必须 `ref.read(kvStorageProvider)` | 修 [bootstrap.dart:16](lib/app/bootstrap.dart:16) 直接访问单例的地方 |
| 2.4 | bootstrap 返回 `AppBootstrapResult { ProviderContainer container; ... }`；预热 `dioProvider` / `kvStorageProvider` 等 keepAlive provider | 配合 Phase 3 Q3 |

#### 2b. 错误模型重构 (A2 + 路径 3)

| # | 任务 | 说明 |
|---|------|------|
| 2.5 | 新建 `core/error/failure_code.dart`（枚举） | 参见 §4.2 |
| 2.6 | 新建 `core/error/app_exception.dart`（sealed + 7 子类） | 参见 §4.2 |
| 2.7 | 新建 `core/error/failure.dart`（单类 + `fromException`）；删除旧 `NetworkFailure/AuthFailure/UnknownFailure` 子类 | 参见 §4.2 |
| 2.8 | 新建 `core/error/app_exception_mapper.dart`（迁移旧 `ErrorHandler.map`） | 参见 §4.3 |
| 2.9 | 新建 `core/network/dio_ext.dart`（`.asApi()` 扩展） | 参见 §4.3 |
| 2.10 | [api_interceptor.dart](lib/core/network/api_interceptor.dart) `onError` 改填 `AppException` | 参见 §4.3 |
| 2.11 | DataSource 所有方法改 `.asApi()` 风格 | [auth_remote_datasource.dart](lib/features/auth/data/datasources/auth_remote_datasource.dart) |
| 2.12 | Repository 所有方法改 `on AppException catch → Failure.fromException` | [auth_repository_impl.dart](lib/features/auth/data/repositories/auth_repository_impl.dart) |
| 2.13 | slang 字符串新增 `errors.{network,timeout,badResponse,auth,validation,cancelled,unknown}` | [i18n/](lib/i18n/) |
| 2.14 | 新增 `BuildContext.failureMessage(Failure)` 扩展 | [build_context_ext.dart](lib/core/extensions/build_context_ext.dart) |
| 2.15 | [login_form.dart:21-33](lib/features/auth/presentation/widgets/login_form.dart:21) 改为 `AppDialog.showError(context, context.failureMessage(next.error!))` | 去除 Failure 子类 switch |
| 2.16 | [login_view_model.dart](lib/features/auth/presentation/view_models/login_view_model.dart) 校验空串改抛 `ValidationException` → Repository 不再硬编码"账号密码不能为空" | 或在 VM 内直接构造 `Failure(code: FailureCode.validation)` |

#### 2c. Result API 与 Observer (Q1 + Q4)

| # | 任务 | 说明 |
|---|------|------|
| 2.17 | Result 补 `when / map / mapFailure / getOrElse / getOrNull` 扩展 | 参见 §4.4 |
| 2.18 | `AppProviderObserver` 补 `providerDidFail` / `didAddProvider` / `didDisposeProvider` | [error_handler.dart:40-60](lib/core/error/error_handler.dart:40) |

### Phase 3 — 工程化闭环（1.1d）

| # | 任务 | 说明 |
|---|------|------|
| 3.1 | **E3** bootstrap 用 `runZonedGuarded`；注册 `FlutterError.onError` / `PlatformDispatcher.instance.onError` → Talker | [bootstrap.dart](lib/app/bootstrap.dart) |
| 3.2 | **E4** dev flavor 在 ProfilePage `_UserHeader` 头像长按 5 下进 `TalkerScreen`；prod 入口不生成（`kDebugMode` 或 `AppEnv.flavor == dev` 条件） | [profile_page.dart](lib/features/home/presentation/pages/profile_page.dart) |
| 3.3 | **E5** 引入 `flutter_native_splash` + `flutter_launcher_icons`；pubspec 配置块 + `assets/splash/logo.png` + `assets/icon/app_icon.png` 占位 | pubspec + README |
| 3.4 | **E6** `AppEnv.baseUrl` 改为 `String.fromEnvironment('API_BASE_URL', defaultValue: ...)`；新增 `env/dev.example.json`、`env/prod.example.json`；`.gitignore` 忽略真实 env | — |
| 3.5 | **E6** `tool/run_dev.sh` / `tool/run_prod.sh` 演示 `--dart-define-from-file=env/dev.json` | `tool/` 目录 |
| 3.6 | **Q3** SplashPage 改等 `bootstrap` 返回的 `AppBootstrapResult.ready` future；删除 `Future.delayed(350ms)` | [splash_page.dart:27](lib/features/splash/presentation/pages/splash_page.dart:27) |
| 3.7 | 新增架构测试 `test/core/architecture_test.dart`（规则见 §7） | — |

### Phase 4 — 文档与模板体验（0.5d）

| # | 任务 | 说明 |
|---|------|------|
| 4.1 | 开启 `public_member_api_docs`；补未注释的公共 API | analysis_options |
| 4.2 | `docs/ai/TEMPLATE_GUIDE.md`（新项目衍生 checklist、命名约定、新增 feature 步骤） | 本目录 |
| 4.3 | `docs/ai/SECURITY.md`（威胁模型 + S1 TODO + secret 注入约定） | 本目录 |
| 4.4 | `docs/ai/ARCHITECTURE.md`（分层图 + Failure 流 + Provider 拓扑） | 本目录 |
| 4.5 | `tool/gen.sh`（`dart run build_runner build -d`）/ `tool/clean.sh` / `tool/test.sh` / `tool/format.sh` | `tool/` |
| 4.6 | 重写 [README.md](README.md)：新架构图、错误模型、`--dart-define` 流程、CI 徽章、模板衍生命令 | — |

---

## 6. 测试策略

### 6.1 每 Phase 同步追加的测试

| Phase | 新增测试 |
|-------|----------|
| Phase 0 | CI 生效自测 |
| Phase 1 | `TokenInterceptor` 并发 refresh 单元测试、`AuthGuard` reevaluate widget test、`logout` 远端失败仍清本地测试 |
| Phase 2 | `AppExceptionMapper.fromDio` 全 type 快照测试、`Failure.fromException` roundtrip 测试、`FailureCode → t.errors.*` 映射测试、`Result` 扩展 API 用例 |
| Phase 3 | `runZonedGuarded` 异常进 Talker 的集成测试、Splash 等 bootstrap 完成的 widget test |
| Phase 4 | 架构测试完整跑通 |

### 6.2 保留现有测试

[auth_architecture_test.dart](test/features/auth/domain/auth_architecture_test.dart) 继续保留；Phase 3 的 `core/architecture_test.dart` 补齐层级约束。

### 6.3 超出本计划范围（TODO）

- Integration test（`integration_test/` 目录 + 典型 golden path）
- Golden widget tests（视觉回归）
- 性能 profiling baseline

---

## 7. 架构约束（靠测试守住）

`test/core/architecture_test.dart` 规则：

1. `lib/features/**/domain/**` 不得 import `dio`、`hive`、`retrofit`。
2. `lib/features/**/data/datasources/**` 公开签名不得出现 `DioException`。
3. `lib/features/**/domain/**` 与 `lib/features/**/presentation/**` 不得 import `AppException` 及其子类。
4. `lib/features/**/data/repositories/**` 方法签名不得出现 `AppException`（返回/抛出）。
5. `lib/core/**` 不得 import `lib/features/**`。
6. 任意 `features/<X>` 不得 import 其他 `features/<Y>`（feature 隔离）。

---

## 8. 延后事项 / TODO

### 8.1 S1 — Hive cipher key 安全存储

**当前状态**：cipher key 以明文存于未加密 Hive 盒，安全等同"空保护"。
**触发升级时机**：上线生产环境前 / 接入鸿蒙 / 存储内容涉及敏感 PII 时。
**预选方案**：方案 A（纯 MethodChannel 抽象）
- iOS / macOS → Keychain
- Android → Keystore
- HarmonyOS → `@ohos.security.huks`
- 不设通用 fallback，未实现平台抛 `UnimplementedError`

**文档链接**：`docs/ai/SECURITY.md` 将在 Phase 4 内建立完整威胁模型与接入指南。

### 8.2 其他可选增强

- `connectivity_plus` 网络状态检测
- 基于 `sentry` / `firebase_crashlytics` 的错误上报（当前仅落 Talker 本地日志）
- Integration tests / Golden tests
- Pre-commit hooks（`lefthook` / `husky`）
- Melos 多包拆分（当前单包足够）

---

## 9. 附录：决策记录

### 9.1 为什么选路径 3（双层 Exception / Result）

详见对话记录与 §4.1；核心理由：
- Data 层不向上泄露 `DioException` / `HiveError`，为未来扩展多传输层预留空间
- Domain 层纯净，`Failure + Result` 强制调用方处理失败
- 用 `ApiInterceptor + .asApi()` 把转换样板压缩到每方法一行
- 代价：两个错误概念，架构测试守护契约

### 9.2 为什么 S2 选 a（拆 `authRefreshDio`）

- 彻底解决 `dio ↔ datasource` 循环依赖
- 其他无 Token 端点（未来的 `/auth/register`、`/auth/verify-email`）可复用同一模式
- 代价：多一个 provider；但职责清晰

### 9.3 为什么 D4 选 a（删 dev fallback）

- 生产代码不应含 dev 特例（即便被 `kDebugMode` 包裹也有误操作风险）
- 如需 fake 数据，正确做法是在 dev flavor 的 `ProviderScope.overrides` 注入 `FakeAuthRemoteDataSource`
- 模板不预置 fake 实现，留给使用者按需添加

### 9.4 为什么 D5 选 b（完整集）

- 模板的价值在于"一次投入、N 个项目复用"，Phase 3/4 的工程化设施是高 ROI 的边际投入
- 独立开发者时间有限，这些设施逐项自建会重复消耗

---

## 10. 总工期与节奏

| Phase | 工期 | 可并行 |
|-------|------|--------|
| Phase 0 | 0.5d | — |
| Phase 1 | 1.0d | 内部 1.1~1.9 基本串行（`S2 → S3 → S4` 有依赖） |
| Phase 2 | 1.8d | 2a / 2b 可并行；2c 依赖 2b |
| Phase 3 | 1.1d | 3.1~3.5 互不依赖 |
| Phase 4 | 0.5d | 内部并行 |
| **合计** | **~4.9d** | — |

### 合并节奏

- 每 Phase 独立 PR；Phase 内每任务 1~2 commit
- Phase 1 合并后再进 Phase 2（错误模型有依赖）
- Phase 3 / Phase 4 可在 Phase 2 合并后并行进行
- 关键评审节点：Phase 1 完成（安全相关）、Phase 2 完成（架构契约）

---

## 11. 修订历史

| 日期 | 版本 | 变更 |
|------|------|------|
| 2026-04-17 | v1.0 | 初稿；D1 搁置；采用路径 3 双层错误模型 |
