# AppException hierarchy

Location: `lib/core/error/app_exception.dart`.

## Shape

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

Seven subclasses, one per `FailureCode`:

| Class | FailureCode | Typical source |
|---|---|---|
| `NetworkException` | `network` | `DioExceptionType.connectionError` — no connection, DNS fail |
| `TimeoutException` | `timeout` | connect/send/receive timeout |
| `BadResponseException` | `badResponse` | non-2xx response (and not 401) |
| `AuthException` | `auth` | HTTP 401, refresh-token failure |
| `ValidationException` | `validation` | client-side validation failure |
| `CancelledException` | `cancelled` | `DioExceptionType.cancel` |
| `UnknownException` | `unknown` | anything not matched; includes badCertificate |

All fields (`cause`, `stackTrace`, `detail`) are optional. `detail` carries server-provided human-readable messages (for `badResponse`) or form validator hints (for `validation`).

## AppExceptionMapper (Dio → AppException)

Location: `lib/core/error/app_exception_mapper.dart`. One static method, called from `ApiInterceptor.onError`:

```dart
static AppException fromDio(DioException e, [StackTrace? st]);
```

It switches on `e.type`:

- `connectionTimeout` / `sendTimeout` / `receiveTimeout` → `TimeoutException`
- `badResponse` + status 401 → `AuthException(detail: serverMsg)`
- `badResponse` + other status → `BadResponseException(detail: serverMsg)`
- `cancel` → `CancelledException`
- `connectionError` → `NetworkException`
- `badCertificate` / `unknown` → `UnknownException`

`detail` for `badResponse`/`auth` is extracted via `_extractMsg(e)` which reads `message`, `msg`, or `error` from the JSON body. If your backend uses a different key, adjust that method.

## ApiInterceptor (packs AppException into DioException.error)

Location: `lib/core/network/api_interceptor.dart`. Its `onError`:

```dart
void onError(DioException err, ErrorInterceptorHandler handler) {
  final appEx = AppExceptionMapper.fromDio(err, err.stackTrace);
  handler.next(DioException(
    requestOptions: err.requestOptions,
    response: err.response,
    type: err.type,
    error: appEx,       // ← AppException stashed here
    stackTrace: err.stackTrace,
  ));
}
```

This is the key trick: the throw from the Retrofit call is STILL a `DioException`, but its `error` field now holds an `AppException`. The unwrap happens in `.asApi()`.

## `.asApi()` extension (unwraps at the Repository boundary)

Location: `lib/core/network/dio_ext.dart`:

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

Every Retrofit call inside a Repository MUST be wrapped:

```dart
final dto = await _remote.getThing().asApi();
```

Without this, the caught exception is `DioException` and `on AppException catch` silently misses. This is the most common bug in this error model — watch for it.

## Adding a new AppException subclass

If you hit an error category the seven existing ones don't cover (rare), follow this sequence:

1. Add a new value to `FailureCode` (e.g. `conflict`).
2. Add a new `final class ConflictException extends AppException` in `app_exception.dart`.
3. Update `AppExceptionMapper.fromDio` to produce the new subclass under the right `DioException` shape (e.g. `badResponse` + status 409 → `ConflictException`).
4. `Failure.fromException` uses `e.code` automatically — no change needed.
5. Update `context.failureMessage` switch in `build_context_ext.dart` to include the new `FailureCode`.
6. Add `errors.conflict` to BOTH `en.i18n.json` and `zh.i18n.json`.
7. Run `tool/gen.sh` + `tool/test.sh`.

## What to AVOID

- Importing `app_exception.dart` anywhere outside `lib/core/`, `lib/features/*/data/`, or tests of those layers. The architecture test enforces this.
- Constructing `AppException` subclasses by hand outside of `AppExceptionMapper` or a test — the mapper is the single source of truth for DioException conversion.
- Throwing raw `Exception('something')` in a Repository — if you must throw, throw an `AppException` subclass so `on AppException catch` handles it.
- Re-mapping already-mapped errors — `.asApi()` handles re-entry safely, but wrapping it twice does nothing useful.
