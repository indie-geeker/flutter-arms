# 网络：Retrofit + Dio + 拦截器链

## Retrofit 数据源形态

```dart
import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/dio_client.dart';
import 'package:flutter_arms/features/%feature%/data/models/%feature%_dto.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '%feature%_remote_datasource.g.dart';

/// %Feature% 远程数据源。
@RestApi()
abstract class %Feature%RemoteDataSource {
  /// 构造函数。
  factory %Feature%RemoteDataSource(Dio dio, {String baseUrl}) =
      _%Feature%RemoteDataSource;

  /// 获取列表。
  @GET('/%feature%')
  Future<List<%Feature%Dto>> list();

  /// 获取详情。
  @GET('/%feature%/{id}')
  Future<%Feature%Dto> detail(@Path('id') String id);

  /// 创建。
  @POST('/%feature%')
  Future<%Feature%Dto> create(@Body() Map<String, dynamic> body);
}

/// %Feature% 远程数据源依赖注入。
@Riverpod(keepAlive: true)
%Feature%RemoteDataSource %feature%RemoteDataSource(Ref ref) {
  return %Feature%RemoteDataSource(ref.read(dioProvider));
}
```

规则：

- `@RestApi()` 不带 `baseUrl` 参数 —— URL 来自 `dioProvider` 的 `BaseOptions`。
- 返回 DTO（`%feature%_dto.dart`），不返回 entity。Mapper 以 DTO 上的 `toEntity()` 扩展存在。
- 请求体用 `Map<String, dynamic>` 或带 `@JsonSerializable` 的类型化请求 DTO。
- 工厂的 `baseUrl` 参数要透传——Retrofit 生成代码需要它，即便未使用。

## Repository 模式

```dart
import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/network/dio_ext.dart';
import 'package:flutter_arms/core/result/result.dart';

class %Feature%RepositoryImpl implements %Feature%Repository {
  const %Feature%RepositoryImpl(this._remote, this._logger);

  final %Feature%RemoteDataSource _remote;
  final Talker _logger;

  @override
  Future<Result<List<%Feature%>>> list() async {
    try {
      final dtos = await _remote.list().asApi();
      return Result.success(dtos.map((d) => d.toEntity()).toList());
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
```

`.asApi()` 扩展位于 `lib/core/network/dio_ext.dart`，是 `Future<T>` 的扩展。职责：

1. 若 future 抛 `AppException`，原样 rethrow。
2. 若抛 `DioException`，从 `ex.error`（被 `ApiInterceptor` 预填为 `AppException`）里拆出来。
3. 其它任何情况变 `UnknownException(cause: e, stackTrace: st)`。

没有 `.asApi()`，`on AppException catch` 就漏掉，裸 `DioException` 外泄，错误契约被打破。

## 拦截器链（顺序要紧，别调换）

主 Dio（`dioProvider`）：

1. `MockApiInterceptor` —— **仅 dev flavor**。对 `/auth/*` 短路，返回 canned 响应。必须在最前，才能在 Token/Api 之前生效。
2. `TalkerDioLogger` —— 打日志。
3. `TokenInterceptor` —— 注入 `Authorization: Bearer <access>`；401 时把请求排队，调用 `refreshAction`，重试。
4. `ApiInterceptor` —— 把 `DioException` 映射成 `AppException`，塞进 `DioException.error`。

刷新 Dio（`authRefreshDioProvider`）：

- 与上面一致，去掉 `TokenInterceptor` —— 这样避免递归刷新。

## Mock API（仅 dev）

`env/dev.json` 设 `USE_MOCK_API: "true"` 就能对 `/auth/*`（login / refresh / me / logout）走 canned 响应。模板借此在无后端的情况下演示登录流程。

Prod flavor 在 `AppEnv.fromFlavor` 里硬编码 `useMockApi = false` —— 即使 `env/prod.json` 尝试开启也无效。防 mock 泄漏到生产。

给新端点加 mock，去改 `lib/core/network/mock_api_interceptor.dart`，在 `onRequest` 里加一个 case。精确匹配 path 并用 `handler.resolve(...)` 返回。

## 超时

定义在 `lib/core/constants/app_constants.dart`：

- `connectTimeoutMs`
- `receiveTimeoutMs`
- `sendTimeoutMs`

改这里，不要单独 per-call。

## 新增一个端点

1. 在 `@RestApi()` 接口加方法。
2. 在 Repository 加方法，用 `.asApi()` + `on AppException catch` 包裹。
3. 若业务层要做单次仓库调用以外的协调，加一个 UseCase。
4. 给 UseCase 加 provider（与 repository provider 同一文件）。

## 避免清单

- 原生 `http` 包 —— 不在依赖里，无法享受拦截器。
- 手动构造 `Dio()` —— 始终走 `dioProvider` 或 `authRefreshDioProvider`。
- `try { await _remote.xxx(); } catch (e) { ... }` 不加 `.asApi()` —— 会 catch 到 `DioException` 而非 `AppException`。
- 在 feature 里直接调 `/auth/*` —— 经由 `authRepositoryProvider`（确有必要再加 `// arch-exempt:`）。
- 硬编码 base URL —— 放在 `AppEnv.baseUrl`，由 `--dart-define-from-file=env/<flavor>.json` 注入。
