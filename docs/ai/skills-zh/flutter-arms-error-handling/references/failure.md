# Failure + FailureCode + failureMessage

## Failure 值类

位置：`lib/core/error/failure.dart`。

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

`Failure` 是 Domain 和 Presentation 能见到的东西。它的结构**刻意**与 `AppException` 类似——区别在语义（跨越了边界）和结构上（它是一个具体值类，不是 sealed 层级）。转换在 Repository 内部通过 `Failure.fromException(e)` 完成。

## FailureCode 枚举

位置：`lib/core/error/failure_code.dart`。

```dart
enum FailureCode {
  network,       // 连接错误
  timeout,       // 连接/发送/接收超时
  badResponse,   // 非 2xx，不含 401
  auth,          // 401 或刷新失败
  validation,    // 客户端校验失败
  cancelled,     // 请求被取消
  unknown,       // 其它
}
```

每个值都必须在 `en.i18n.json` 和 `zh.i18n.json` 中有对应的 `errors.<code>` 键，否则 slang 代码生成会抛错。

## Failure.fromException

仅在 Repository 内部使用：

```dart
try {
  final dto = await _remote.xxx().asApi();
  return Result.success(dto.toEntity());
} on AppException catch (e) {
  return Result.failure(Failure.fromException(e));
}
```

跨越边界时完整携带 `code`、`detail`、`cause`、`stackTrace`。

## 直接构造 Failure（非传输错误）

对于未经网络的客户端校验或领域规则违反：

```dart
// 在 ViewModel 或 UseCase 中：
if (state.username.trim().isEmpty) {
  state = state.copyWith(
    error: const Failure(code: FailureCode.validation),
  );
  return;
}

// 带明确消息（会逐字展示）：
state = state.copyWith(
  error: const Failure(
    code: FailureCode.validation,
    detail: 'Username must be at least 3 characters',
  ),
);
```

`validation` 的 `detail` 会直接显示给用户（详见下面的优先级）。

## context.failureMessage

位置：`lib/core/extensions/build_context_ext.dart`。

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

### detail 优先级

| Code | 行为 |
|---|---|
| `network` | 始终 `t.errors.network` |
| `timeout` | 始终 `t.errors.timeout` |
| `badResponse` | 有 `detail` 就用（服务端消息），否则 `t.errors.badResponse` |
| `auth` | 始终 `t.errors.auth`（401 的服务端消息对用户通常不友好） |
| `validation` | 有 `detail` 就用（校验/服务端提示），否则 `t.errors.validation` |
| `cancelled` | 始终 `t.errors.cancelled` |
| `unknown` | 始终 `t.errors.unknown` |

如果你希望某个目前走 i18n 的 code 也让 `detail` 优先（比如希望 `auth` 显示服务端消息），去改 `build_context_ext.dart` 的 switch。

## 新增 FailureCode

1. 在 `failure_code.dart` 加上枚举值。
2. 若错误来自 Data 层，增加对应的 `AppException` 子类。
3. 若是 Dio 到 AppException 的映射，更新 `AppExceptionMapper`。
4. 更新 `context.failureMessage` 的 switch —— 分析器会在枚举穷尽缺失时拒绝编译。
5. 在 `lib/i18n/en.i18n.json` 和 `lib/i18n/zh.i18n.json` 都加上 `errors.<newCode>`。
6. 运行 `tool/gen.sh`。

## 禁用清单

- 展示 `failure.toString()` 或 `failure.cause.toString()` —— 会把栈和类名暴露给最终用户。始终走 `context.failureMessage`。
- 在 state 里用 `String? error` 而不是 `Failure? error` —— 丢了 `code`，也没法正确本地化。
- 把 `Failure` 当异常 catch —— 它是值类，不是 `Exception`。它是通过 `Result.failure(...)` 传递的。
- 在 `core/network/` 内部使用 `Failure` —— 那一层仍在用 `AppException`。`Failure` 属于 Domain/Presentation。
- 不对称的 i18n key —— 如果你在 `en.i18n.json` 加了 `errors.conflict` 但忘了 `zh.i18n.json`，slang 代码生成会失败。
