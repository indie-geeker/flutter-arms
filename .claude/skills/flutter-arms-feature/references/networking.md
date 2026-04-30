# Networking: Retrofit + Dio + interceptor chain

## Retrofit datasource shape

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

Rules:

- `@RestApi()` with no `baseUrl` argument — the URL comes from `dioProvider`'s `BaseOptions`.
- Return DTOs (`%feature%_dto.dart`), never entities. Mapper lives as a `toEntity()` extension on the DTO.
- Request bodies are `Map<String, dynamic>` OR a typed request DTO with `@JsonSerializable`.
- Pass the factory `baseUrl` argument through — it's required by generated Retrofit code even when unused.

## Repository pattern

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

The `.asApi()` extension is on `Future<T>` and lives in `lib/core/network/dio_ext.dart`. Its job:

1. If the future threw `AppException`, rethrow it unchanged.
2. If it threw `DioException`, unwrap `ex.error` (which `ApiInterceptor` pre-filled with an `AppException`).
3. Anything else becomes `UnknownException(cause: e, stackTrace: st)`.

Without `.asApi()`, the `on AppException catch` clause will miss and a raw `DioException` leaks. This breaks the error contract.

## Interceptor chain (order matters — don't reorder)

Main Dio (`dioProvider`):

1. `MockApiInterceptor` — **dev flavor only**. Short-circuits `/auth/*` with canned responses. Must be first so it runs before Token/Api interceptors.
2. `TalkerDioLogger` — logs every request/response.
3. `TokenInterceptor` — injects `Authorization: Bearer <access>`; on 401 queues the request, calls `refreshAction`, retries.
4. `ApiInterceptor` — maps `DioException` → `AppException`, packs it into `DioException.error`.

Refresh Dio (`authRefreshDioProvider`):

- Same chain minus `TokenInterceptor` — this is how we avoid recursive refresh loops.

## Mock API (dev-only)

`env/dev.json` can set `USE_MOCK_API: "true"` to short-circuit `/auth/*` endpoints (login / refresh / me / logout) with canned responses. This is how the template demos a login flow without a backend.

Prod flavor hardcodes `useMockApi = false` in `AppEnv.fromFlavor` — even if `env/prod.json` tries to enable it, it's ignored. This prevents mocks leaking to production.

To add mocks for a new endpoint, edit `lib/core/network/mock_api_interceptor.dart` and add a case in its `onRequest` method. Match the exact path and return via `handler.resolve(...)`.

## Timeouts

Defined in `lib/core/constants/app_constants.dart`:

- `connectTimeoutMs`
- `receiveTimeoutMs`
- `sendTimeoutMs`

Change there, not per-call.

## Adding a new endpoint

1. Add a method to the `@RestApi()` interface.
2. Add a Repository method that wraps it with `.asApi()` + `on AppException catch`.
3. Add a UseCase if the business layer needs coordination beyond a single repository call.
4. Add a provider for the UseCase (same file as the repository provider).

## What to AVOID

- Raw `http` package — not on the dependency list; won't get interceptor benefits.
- Manually constructing a `Dio()` — always go through `dioProvider` or `authRefreshDioProvider`.
- `try { await _remote.xxx(); } catch (e) { ... }` without `.asApi()` — catches `DioException` instead of `AppException`.
- Calling `/auth/*` endpoints directly from a feature — go through `authRepositoryProvider` (and add `// arch-exempt:` if genuinely needed).
- Hardcoding base URL — it's in `AppEnv.baseUrl`, injected by `--dart-define-from-file=env/<flavor>.json`.
