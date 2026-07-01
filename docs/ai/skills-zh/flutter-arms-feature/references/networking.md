# 网络：Retrofit / ApiClient + Dio + 拦截器链

## 远程数据源形态

远程数据源分三层：

1. 纯接口：Repository 只依赖它。
2. Retrofit adapter：默认实现，适合快速 REST CRUD。
3. ApiClient adapter：对照实现，便于未来替换 Dio/Retrofit。

### Retrofit adapter

```dart
import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/dio_client.dart';
import 'package:flutter_arms/core/network/dio_ext.dart';
import 'package:flutter_arms/features/%feature%/data/datasources/%feature%_remote_datasource.dart';
import 'package:flutter_arms/features/%feature%/data/models/%feature%_dto.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'retrofit_%feature%_remote_datasource.g.dart';

/// Retrofit %Feature% API。
@RestApi()
abstract class Retrofit%Feature%Api {
  /// 构造函数。
  factory Retrofit%Feature%Api(Dio dio, {String baseUrl}) =
      _Retrofit%Feature%Api;

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

final class Retrofit%Feature%RemoteDataSource
    implements %Feature%RemoteDataSource {
  const Retrofit%Feature%RemoteDataSource(this._api);

  final Retrofit%Feature%Api _api;

  @override
  Future<List<%Feature%Dto>> list() {
    return _api.list().asApi();
  }
}

/// %Feature% 远程数据源依赖注入。
@Riverpod(keepAlive: true)
%Feature%RemoteDataSource %feature%RemoteDataSource(Ref ref) {
  return Retrofit%Feature%RemoteDataSource(
    Retrofit%Feature%Api(ref.read(dioProvider)),
  );
}
```

规则：

- `@RestApi()` 不带 `baseUrl` 参数 —— URL 来自 `dioProvider` 的 `BaseOptions`。
- 返回 DTO（`%feature%_dto.dart`），不返回 entity。Mapper 以 DTO 上的 `toEntity()` 扩展存在。
- 请求体用 `Map<String, dynamic>` 或带 `@JsonSerializable` 的类型化请求 DTO。
- 工厂的 `baseUrl` 参数要透传——Retrofit 生成代码需要它，即便未使用。
- `.asApi()` 放在 Retrofit adapter 中，Repository 不再调用。

### ApiClient adapter

ApiClient adapter 只依赖应用级抽象，不 import `dio_api_client.dart`：

```dart
import 'package:flutter_arms/core/network/api_client.dart';
import 'package:flutter_arms/core/network/api_request.dart';
import 'package:flutter_arms/features/%feature%/data/datasources/%feature%_remote_datasource.dart';
import 'package:flutter_arms/features/%feature%/data/models/%feature%_dto.dart';

final class ApiClient%Feature%RemoteDataSource
    implements %Feature%RemoteDataSource {
  const ApiClient%Feature%RemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<%Feature%Dto> detail(String id) {
    return _client.send(
      ApiRequest<%Feature%Dto>.get(
        '/%feature%/$id',
        decode: _decodeDto,
      ),
    );
  }

  static %Feature%Dto _decodeDto(Object? json) {
    return %Feature%Dto.fromJson(json! as Map<String, dynamic>);
  }
}
```

需要 `apiClientProvider` 时，放到 `api_client_%feature%_remote_datasource_provider.dart` 这种接线文件中。

## Repository 模式

```dart
import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/result/result.dart';

class %Feature%RepositoryImpl implements %Feature%Repository {
  const %Feature%RepositoryImpl(this._remote, this._logger);

  final %Feature%RemoteDataSource _remote;
  final Talker _logger;

  @override
  Future<Result<List<%Feature%>>> list() async {
    try {
      final dtos = await _remote.list();
      return Result.success(dtos.map((d) => d.toEntity()).toList());
    } on AppException catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
```

Repository 不 import `dio_ext.dart`。传输层异常转换由 DataSource adapter 完成：

1. Retrofit adapter 在 `_api.xxx().asApi()` 处转换。
2. ApiClient adapter 通过 `DioApiClient.send(...)` 得到已转换的 `AppException`。
3. Repository 只接收纯 DataSource 接口返回值或 `AppException`。

## 拦截器链（顺序要紧，别调换）

主 Dio（`dioProvider`）：

1. `MockApiInterceptor` —— **仅 dev flavor**。对 `/auth/*` 短路，返回 canned 响应。必须在最前，才能在 Token/Api 之前生效。
2. `TalkerDioLogger` —— 打日志。
3. `TokenInterceptor` —— 对 `requiresAuth != false` 的请求注入 `Authorization: Bearer <access>`；401 时把请求排队，调用 `refreshAction`，重试。
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

1. 在纯远程数据源接口加方法。
2. 在 Retrofit adapter / ApiClient adapter 实现方法；Retrofit 调用在 adapter 内部 `.asApi()`。
3. 在 Repository 加方法，用 `on AppException catch` 包裹纯 DataSource 调用。
4. 若业务层要做单次仓库调用以外的协调，加一个 UseCase。
5. 给 UseCase 加 provider（与 repository provider 同一文件）。

## 避免清单

- 原生 `http` 包 —— 不在依赖里，无法享受拦截器。
- 手动构造 `Dio()` —— 始终走 `dioProvider` 或 `authRefreshDioProvider`。
- 在 Repository 里 import `dio_ext.dart` 或调用 `.asApi()` —— DataSource adapter 才是传输异常转换边界。
- 在 feature 里直接调 `/auth/*` —— 经由 `authRepositoryProvider`（确有必要再加 `// arch-exempt:`）。
- 硬编码 base URL —— 放在 `AppEnv.baseUrl`，由 `--dart-define-from-file=env/<flavor>.json` 注入。
