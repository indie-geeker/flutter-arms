# Repository error-handling flow

This is where AppException becomes Failure, and where `.asApi()` earns its keep. Every Repository in `lib/features/*/data/repositories/` must follow these patterns.

## Canonical pattern (happy path + error)

```dart
import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/network/dio_ext.dart';
import 'package:flutter_arms/core/result/result.dart';

@override
Future<Result<Post>> getPost(String id) async {
  try {
    final dto = await _remote.getPost(id).asApi();
    return Result.success(dto.toEntity());
  } on AppException catch (e) {
    return Result.failure(Failure.fromException(e));
  }
}
```

Three parts, in order:
1. Retrofit call **with `.asApi()`** (mandatory).
2. `on AppException catch` — NOT `catch (e)`, NOT `on Exception catch`. The specific type keeps the compiler honest.
3. `return Result.failure(Failure.fromException(e))` — preserves `code`, `detail`, `cause`, `stackTrace`.

## When the remote call has side effects (combine with local)

From `auth_repository_impl.dart`'s login:

```dart
@override
Future<Result<User>> login({required String username, required String password}) async {
  try {
    final token = await _remote.login(
      <String, dynamic>{'username': username, 'password': password},
    ).asApi();
    await _local.saveToken(token);

    final userModel = await _remote.me().asApi();
    await _local.saveUser(userModel);

    return Result.success(userModel.toEntity());
  } on AppException catch (e) {
    return Result.failure(Failure.fromException(e));
  }
}
```

Both `.asApi()` calls live inside the same `try`. If either remote call fails, the `on AppException catch` captures it and the local saves that would have followed are skipped.

## Partial-failure pattern (remote optional, local definite)

When the remote call is a best-effort "tell the server we did this" but the local cleanup must happen regardless (typical for logout):

```dart
@override
Future<void> logout() async {
  try {
    await _remote.logout().asApi();
  } on AppException catch (e, st) {
    _logger.warning('remote logout failed, clearing local anyway', e, st);
  }
  await _local.clearAuth();   // always runs
}
```

Rules for partial-failure:
- Log via `_logger.warning(...)` so the error isn't silent.
- Do NOT return `Result.failure(...)` — the overall operation succeeded (locally) even if the server side didn't.
- Return type can be `Future<void>` if no meaningful success payload.

## When there's a pure-local method (no remote involved)

Use normal error handling, no `.asApi()`:

```dart
@override
Future<Result<User>> getCurrentUser() async {
  final localUser = _local.getUser();
  if (localUser == null) {
    return const Result.failure(Failure(code: FailureCode.auth));
  }
  return Result.success(localUser.toEntity());
}
```

Construct the `Failure` directly with the appropriate `FailureCode`. `FailureCode.auth` here means "not authenticated". `FailureCode.validation` for bad input. `FailureCode.unknown` as a last resort (avoid — prefer a specific code).

## Logging vs returning

- **Log-and-propagate** (most cases): just `return Result.failure(...)`. The ViewModel will surface it. No need to log at the Repository — `TalkerDioLogger` already captured the network event.
- **Log-and-swallow** (rare, partial-failure scenarios like logout): `_logger.warning(...)` + continue. Use when the business operation can reasonably succeed despite the error.
- **Never**: throw. Repositories NEVER throw upward.

## Retries

Don't retry inside the Repository. The UI should show the error and the user should trigger the retry (by tapping a refresh button, pulling to refresh, etc.). The two exceptions:

1. **401 auto-refresh**: handled by `TokenInterceptor` at the network layer — the Repository never sees the refresh logic.
2. **Idempotent reads on transient errors**: if you really need this, do it in the UseCase, not the Repository. UseCase can wrap Repository with a `mapFailure` + `.when(success: …, failure: …)` retry loop.

## What each piece forbids

- **No `try { ... } catch (e) { ... }` with a bare type**: too loose, catches Dart-level bugs. Always `on AppException catch`.
- **No throw from a Repository method**: the contract is `Future<Result<T>>`, not "returns Result or throws".
- **No `DioException` above the Repository**: `.asApi()` unwraps to `AppException`. If you see `DioException` in a Repository, `.asApi()` was skipped.
- **No domain import leaking into data**: this is the other direction. Data CAN import Domain (DTO.toEntity()). Domain CANNOT import Data.
- **No mixing Result-returning and throwing methods in the same Repository interface**: either all methods that can fail return `Result`, or none do. Mixing creates confusion about which need `try/catch` at the call site.

## Checklist for a new Repository method

- [ ] Method signature returns `Future<Result<T>>` or `Future<void>` (for side-effectful ops like logout).
- [ ] Retrofit call wrapped in `.asApi()`.
- [ ] `on AppException catch (e)` (not a bare catch).
- [ ] `Failure.fromException(e)` used — never hand-constructed when origin is a Retrofit call.
- [ ] If mixing remote + local writes, both are inside the single try block.
- [ ] If partial-failure is acceptable, log with `_logger.warning(...)` and continue.
- [ ] No `try/catch` at call sites in Domain or Presentation — the `Result` is enough.
