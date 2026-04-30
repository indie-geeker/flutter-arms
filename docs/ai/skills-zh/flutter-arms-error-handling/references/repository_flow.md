# Repository 错误处理流程

这里是 AppException 变成 Failure、`.asApi()` 发挥作用的地方。`lib/features/*/data/repositories/` 下的每个 Repository 都必须遵循以下模式。

## 标准模式（happy path + 错误）

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

三个步骤，顺序不能变：
1. Retrofit 调用**加 `.asApi()`**（必需）。
2. `on AppException catch` —— 不是 `catch (e)`，也不是 `on Exception catch`。具体类型让编译器为你把关。
3. `return Result.failure(Failure.fromException(e))` —— 保留 `code`、`detail`、`cause`、`stackTrace`。

## 远端调用带副作用时（与本地组合）

取自 `auth_repository_impl.dart` 的 login：

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

两次 `.asApi()` 都在同一个 `try` 里。任意一次远端失败，`on AppException catch` 都能接住，且之后的本地写入会被跳过。

## 部分失败模式（远端可选 / 本地必达）

当远端调用是"告诉服务器我们做了什么"的尽力而为，但本地清理必须发生（logout 的典型场景）：

```dart
@override
Future<void> logout() async {
  try {
    await _remote.logout().asApi();
  } on AppException catch (e, st) {
    _logger.warning('remote logout failed, clearing local anyway', e, st);
  }
  await _local.clearAuth();   // 总会执行
}
```

部分失败的规则：
- 用 `_logger.warning(...)` 记录，别让错误无声消失。
- **不要** `return Result.failure(...)` —— 整体操作（本地层面）已经成功，即便服务器端失败了。
- 没有有意义的成功返回值时，返回类型可以是 `Future<void>`。

## 纯本地方法（不涉及远端）

用普通错误处理即可，不用 `.asApi()`：

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

直接用合适的 `FailureCode` 构造 `Failure`。这里的 `FailureCode.auth` 表示"未认证"，`FailureCode.validation` 用于非法输入。`FailureCode.unknown` 作最后兜底（能避免就避免，优先选更具体的 code）。

## 记录 vs 返回

- **记录并上抛**（大多数情况）：直接 `return Result.failure(...)`。ViewModel 会展示。Repository 无需打日志 —— `TalkerDioLogger` 已捕获了网络事件。
- **记录并吞掉**（少见，如 logout 这种部分失败场景）：`_logger.warning(...)` + 继续。只有当业务上可以"虽败犹成"时才用。
- **永远不**：throw。Repository 绝不向上 throw。

## 重试

不要在 Repository 内部重试。UI 显示错误后由用户触发重试（点刷新、下拉等）。两个例外：

1. **401 自动刷新**：由网络层的 `TokenInterceptor` 处理 —— Repository 看不到刷新逻辑。
2. **对幂等读做瞬时错误重试**：真有需要的话，放在 UseCase，不放在 Repository。UseCase 可以用 `mapFailure` + `.when(success: …, failure: …)` 包一个重试循环。

## 每一处的禁用项

- **不要用 `try { ... } catch (e) { ... }` 裸 catch**：太宽，会吞 Dart 层 bug。始终 `on AppException catch`。
- **Repository 方法不要 throw**：契约是 `Future<Result<T>>`，不是"要么返回 Result，要么抛异常"。
- **Repository 之上不要出现 `DioException`**：`.asApi()` 会拆成 `AppException`。Repository 里还能看到 `DioException`，就说明漏了 `.asApi()`。
- **不要让 Domain import 漏到 Data 之上**：这是反方向问题。Data **可以** import Domain（DTO.toEntity()）。Domain **不能** import Data。
- **不要在同一个 Repository 接口里混用 Result 返回和 throw 方法**：要么所有可能失败的方法都返回 `Result`，要么都不这样做。混用会让调用方不知道哪些需要 `try/catch`。

## 新增 Repository 方法的 checklist

- [ ] 方法签名返回 `Future<Result<T>>`，或 `Future<void>`（适用于 logout 这种副作用型操作）。
- [ ] Retrofit 调用包在 `.asApi()` 里。
- [ ] `on AppException catch (e)`（不是裸 catch）。
- [ ] 用了 `Failure.fromException(e)` —— 当来源是 Retrofit 调用时，禁止手工构造。
- [ ] 若同时写远端+本地，都在同一个 try 块里。
- [ ] 若允许部分失败，用 `_logger.warning(...)` 记录并继续。
- [ ] Domain / Presentation 的调用方没有 `try/catch` —— `Result` 足够了。
