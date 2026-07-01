# AppException 层级

位置：`lib/core/error/app_exception.dart`。

## 结构

```dart
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
```

7 个子类，一一对应 `FailureCode`：

| 类 | FailureCode | 典型来源 |
|---|---|---|
| `NetworkException` | `network` | `DioExceptionType.connectionError` —— 无连接、DNS 失败 |
| `TimeoutException` | `timeout` | 连接/发送/接收超时 |
| `BadResponseException` | `badResponse` | 非 2xx 响应（排除 401） |
| `AuthException` | `auth` | HTTP 401、刷新 token 失败 |
| `ValidationException` | `validation` | 客户端校验失败 |
| `CancelledException` | `cancelled` | `DioExceptionType.cancel` |
| `UnknownException` | `unknown` | 所有未匹配项，包含 badCertificate |

所有字段（`cause`、`stackTrace`、`detail`）都是可选。`detail` 用于承载服务端返回的人类可读消息（`badResponse`）或表单校验提示（`validation`）。

## AppExceptionMapper（Dio → AppException）

位置：`lib/core/error/app_exception_mapper.dart`。单个静态方法，由 `ApiInterceptor.onError` 调用：

```dart
static AppException fromDio(DioException e, [StackTrace? st]);
```

按 `e.type` 分支：

- `connectionTimeout` / `sendTimeout` / `receiveTimeout` → `TimeoutException`
- `badResponse` + 状态 401 → `AuthException(detail: serverMsg)`
- `badResponse` + 其它状态 → `BadResponseException(detail: serverMsg)`
- `cancel` → `CancelledException`
- `connectionError` → `NetworkException`
- `badCertificate` / `unknown` → `UnknownException`

`badResponse`/`auth` 的 `detail` 由 `_extractMsg(e)` 从 JSON body 中读取 `message`、`msg` 或 `error`。如果后端用了别的字段名，改这个方法即可。

## ApiInterceptor（把 AppException 塞进 DioException.error）

位置：`lib/core/network/api_interceptor.dart`。其 `onError`：

```dart
void onError(DioException err, ErrorInterceptorHandler handler) {
  final appEx = AppExceptionMapper.fromDio(err, err.stackTrace);
  handler.next(DioException(
    requestOptions: err.requestOptions,
    response: err.response,
    type: err.type,
    error: appEx,       // ← 把 AppException 塞在这里
    stackTrace: err.stackTrace,
  ));
}
```

这是关键技巧：Retrofit 调用抛出的**仍然**是 `DioException`，但它的 `error` 字段里藏着 `AppException`。真正拆包在 Retrofit DataSource adapter 的 `.asApi()` 里完成。

## `.asApi()` 扩展（在 Retrofit DataSource adapter 边界拆包）

位置：`lib/core/network/dio_ext.dart`：

```dart
extension ThrowAppExceptionX<T> on Future<T> {
  Future<T> asApi() {
    return catchError((Object e, StackTrace st) {
      if (e is AppException) throw e;
      if (e is DioException) {
        final inner = e.error;
        if (inner is AppException) throw inner;
        throw UnknownException(cause: e, stackTrace: st);
      }
      throw UnknownException(cause: e, stackTrace: st);
    });
  }
}
```

Retrofit DataSource adapter 里每一次 Retrofit 调用都**必须**包起来：

```dart
Future<ThingDto> getThing() {
  return _api.getThing().asApi();
}
```

Repository 只调用纯 DataSource 接口：

```dart
final dto = await _remote.getThing();
```

少了 adapter 里的 `.asApi()`，Repository 收到的就可能是 `DioException`，`on AppException catch` 会静默漏掉。这是本错误模型里最常见的 bug，要特别留意。

## 新增 AppException 子类

如果遇到现有 7 个都覆盖不到的错误类别（少见），按以下顺序：

1. 在 `FailureCode` 添加新枚举值（比如 `conflict`）。
2. 在 `app_exception.dart` 添加 `final class ConflictException extends AppException`。
3. 更新 `AppExceptionMapper.fromDio`，在合适的 `DioException` 形状下生成新子类（比如 `badResponse` + 状态 409 → `ConflictException`）。
4. `Failure.fromException` 会自动透传 `e.code`，无需改动。
5. 更新 `build_context_ext.dart` 里 `context.failureMessage` 的 switch，加入新的 `FailureCode`。
6. 在 `en.i18n.json` 和 `zh.i18n.json` 都加上 `errors.conflict`。
7. 运行 `tool/gen.sh` + `tool/test.sh`。

## 禁用清单

- 在 `lib/core/`、`lib/features/*/data/` 或这些层的测试之外 import `app_exception.dart`。架构测试强制这一条。
- 在 `AppExceptionMapper` 或测试以外的地方手工构造 `AppException` 子类 —— mapper 是 DioException 转换的唯一来源。
- 在 Repository 里裸抛 `Exception('something')` —— 如果必须 throw，抛一个 `AppException` 子类，这样 `on AppException catch` 才能接住。
- 在 Repository 或 application service 里调用 `.asApi()` —— 传输异常转换属于 DataSource adapter。
