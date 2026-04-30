# Failure + FailureCode + failureMessage

## Failure value class

Location: `lib/core/error/failure.dart`.

```dart
final class Failure {
  const Failure({
    required this.code,
    this.cause,
    this.stackTrace,
    this.detail,
  });

  factory Failure.fromException(AppException e) => Failure(
    code: e.code,
    cause: e.cause ?? e,
    stackTrace: e.stackTrace,
    detail: e.detail,
  );

  final FailureCode code;
  final Object? cause;
  final StackTrace? stackTrace;
  final String? detail;
}
```

`Failure` is what Domain and Presentation see. It is INTENTIONALLY similar in shape to `AppException` — the difference is semantic (a crossed boundary) and structural (it's a concrete value class, not a sealed hierarchy). The conversion is `Failure.fromException(e)` inside the Repository.

## FailureCode enum

Location: `lib/core/error/failure_code.dart`.

```dart
enum FailureCode {
  network,       // connection error
  timeout,       // connect/send/receive timeout
  badResponse,   // non-2xx, not 401
  auth,          // 401 or refresh failure
  validation,    // client-side validation failure
  cancelled,     // request cancelled
  unknown,       // anything else
}
```

Every value must have a matching i18n key at `errors.<code>` in BOTH `en.i18n.json` and `zh.i18n.json`. slang codegen will throw otherwise.

## Failure.fromException

Only used inside Repositories:

```dart
try {
  final dto = await _remote.xxx().asApi();
  return Result.success(dto.toEntity());
} on AppException catch (e) {
  return Result.failure(Failure.fromException(e));
}
```

Carries `code`, `detail`, `cause`, `stackTrace` across the boundary intact.

## Creating a Failure directly (non-transport errors)

For client-side validation or domain rule violations that never went through the network:

```dart
// In a ViewModel or UseCase:
if (state.username.trim().isEmpty) {
  state = state.copyWith(
    error: const Failure(code: FailureCode.validation),
  );
  return;
}

// With a specific message (will display verbatim):
state = state.copyWith(
  error: const Failure(
    code: FailureCode.validation,
    detail: 'Username must be at least 3 characters',
  ),
);
```

`detail` for `validation` is shown to the user directly (see precedence below).

## context.failureMessage

Location: `lib/core/extensions/build_context_ext.dart`.

```dart
String failureMessage(Failure failure) {
  final strings = t.errors;
  return switch (failure.code) {
    FailureCode.network => strings.network,
    FailureCode.timeout => strings.timeout,
    FailureCode.badResponse => failure.detail ?? strings.badResponse,
    FailureCode.auth => strings.auth,
    FailureCode.validation => failure.detail ?? strings.validation,
    FailureCode.cancelled => strings.cancelled,
    FailureCode.unknown => strings.unknown,
  };
}
```

### Detail precedence

| Code | Behavior |
|---|---|
| `network` | Always `t.errors.network` |
| `timeout` | Always `t.errors.timeout` |
| `badResponse` | `detail` if present (server message), else `t.errors.badResponse` |
| `auth` | Always `t.errors.auth` (the specific server message is usually not user-friendly for 401) |
| `validation` | `detail` if present (validator/server hint), else `t.errors.validation` |
| `cancelled` | Always `t.errors.cancelled` |
| `unknown` | Always `t.errors.unknown` |

If you need `detail` to take precedence for a code that currently uses i18n (e.g. you want server messages for `auth` errors), update the switch in `build_context_ext.dart`.

## Adding a new FailureCode

1. Add the enum value to `failure_code.dart`.
2. Add a corresponding `AppException` subclass if the error has a Data-layer source.
3. Update `AppExceptionMapper` if it's a Dio translation.
4. Update `context.failureMessage` switch — the analyzer will refuse to compile without it (exhaustive switch on enum).
5. Add `errors.<newCode>` to `lib/i18n/en.i18n.json` AND `lib/i18n/zh.i18n.json`.
6. Run `tool/gen.sh`.

## What to AVOID

- Displaying `failure.toString()` or `failure.cause.toString()` — they expose stack traces and class names to end users. Always go through `context.failureMessage`.
- Storing `String? error` in state instead of `Failure? error` — you lose the `code` and can't localize correctly.
- Catching `Failure` as if it were an exception — it's a value class, not an `Exception`. It flows via `Result.failure(...)`.
- Using `Failure` inside `core/network/` — at that layer you're still working with `AppException`. `Failure` is a Domain/Presentation type.
- Asymmetric i18n keys — if you add `errors.conflict` to `en.i18n.json` but forget `zh.i18n.json`, slang codegen fails.
