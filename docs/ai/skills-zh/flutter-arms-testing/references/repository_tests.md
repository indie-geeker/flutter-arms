# Repository 测试

Repository 是 Data 与 Domain 之间的边界。测试要验证：

1. Success 路径：远端 + 本地调用顺序正确，`Result.success` 携带映射后的 Entity。
2. Failure 路径：远端抛出（经 `.asApi()` 转换）的 `AppException` 变成 `Result.failure(Failure.fromException(e))`，`FailureCode` 正确。
3. 部分失败路径（logout 式方法）：远端失败但本地清理仍然执行。

## 文件位置

`test/features/<f>/data/repositories/<f>_repository_impl_test.dart` —— 严格镜像 `lib/`。

## 骨架

```dart
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/features/<f>/data/datasources/<f>_local_datasource.dart';
import 'package:flutter_arms/features/<f>/data/datasources/<f>_remote_datasource.dart';
import 'package:flutter_arms/features/<f>/data/models/<f>_dto.dart';
import 'package:flutter_arms/features/<f>/data/repositories/<f>_repository_impl.dart';
import 'package:flutter_arms/features/<f>/domain/entities/<f>.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

class _MockRemote extends Mock implements <F>RemoteDataSource {}
class _MockLocal extends Mock implements <F>LocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late Talker logger;
  late <F>RepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    logger = Talker(settings: TalkerSettings(enabled: false));
    repository = <F>RepositoryImpl(remote, local, logger);
  });

  // groups follow...
}
```

要点：

- **Mock 类私有**（下划线前缀）—— 从不逃出测试文件。
- **`Talker` 用真实对象但 `enabled: false`** —— 比 mock 便宜。
- **Repository 用真实实例** —— 我们测的是它本身，不是 DataSource。
- **`setUp` 每个测试前都跑**；每个测试都拿到全新的 mock。

## Happy-path 测试

```dart
group('getPost', () {
  const postDto = PostDto(id: '1', title: 'Hello');
  const expectedPost = Post(id: '1', title: 'Hello');

  test('should return post on successful remote fetch', () async {
    when(() => remote.getPost('1')).thenAnswer((_) async => postDto);

    final result = await repository.getPost('1');

    expect(result.isSuccess, isTrue);
    expect(result.data, expectedPost);
  });
});
```

## 失败路径测试

方法能产生的每种 `FailureCode` 都要写一个测试。

```dart
test('should return auth failure when remote throws AuthException', () async {
  when(() => remote.getPost('1')).thenAnswer(
    (_) => Future<PostDto>.error(
      const AuthException(detail: 'token expired'),
    ),
  );

  final result = await repository.getPost('1');

  expect(result.isFailure, isTrue);
  expect(result.failure?.code, FailureCode.auth);
  expect(result.failure?.detail, 'token expired');
});
```

对"任何异常都会变成 unknown"这个兜底路径也要测，因为 `.asApi()` 会把非 `AppException` 的错误转成 `UnknownException`：

```dart
test('should return unknown failure when remote throws generic exception', () async {
  when(() => remote.getPost('1')).thenAnswer(
    (_) => Future<PostDto>.error(Exception('unexpected')),
  );

  final result = await repository.getPost('1');

  expect(result.isFailure, isTrue);
  expect(result.failure?.code, FailureCode.unknown);
});
```

这就是 `auth_repository_impl_test.dart` 里那条测试——演练 `.asApi()` 的 catch-all 路径。

## 部分失败测试（logout 式）

当方法容忍远端失败但一定执行本地清理：

```dart
test('should still clear local auth when remote logout fails', () async {
  when(() => remote.logout())
      .thenAnswer((_) => Future<void>.error(Exception('network down')));
  when(() => local.clearAuth()).thenAnswer((_) async {});

  await repository.logout();

  verify(() => remote.logout()).called(1);
  verify(() => local.clearAuth()).called(1);
});
```

`verify(() => ...).called(1)` 断言 mock 恰被调用 1 次。

## Stub 注意事项

- `thenAnswer((_) async => value)` 用于成功 Future。
- `thenAnswer((_) => Future<T>.error(e))` 用于错误。注意显式 `Future<T>` —— Dart 需要类型来解析错误 Future。
- `thenReturn(value)` 用于同步返回（比如 `local.getUser()`）。
- 对无参 getter，`when(s.method)`（不带括号和 lambda）即可 —— 例如 `when(s.getThemeMode).thenReturn(...)`。有参方法必须用 `when(() => s.method(arg))`。
- **不要 stub 测试里没调到的方法** —— 噪音会掩盖重点。

## mocktail fallback 值

当 `any()` 用于非原始参数类型时，在 `setUpAll` 里注册：

```dart
class _FakeRequestOptions extends Fake implements RequestOptions {}

setUpAll(() {
  registerFallbackValue(_FakeRequestOptions());
  registerFallbackValue(Colors.transparent); // 用于 Color 参数
});
```

缺 fallback 的症状是：`type 'Null' is not a subtype of type 'X'`。

## 直接测试 `.asApi()` 拆包

通常不必 —— Repository 测试已间接覆盖。真需要单独测 `.asApi()`，看 `test/core/network/` 或 `test/core/error/app_exception_mapper_test.dart` 里的映射规则。

## Repository 方法的覆盖率清单

- [ ] Happy path：远端返回 → Result.success 带映射后的 Entity。
- [ ] 网络错误：`NetworkException` → `FailureCode.network`。
- [ ] 超时：`TimeoutException` → `FailureCode.timeout`。
- [ ] 异常响应（如 500）：`BadResponseException` → `FailureCode.badResponse`，且 `detail` 透传。
- [ ] 未授权（401）：`AuthException` → `FailureCode.auth`。
- [ ] 一般异常：任意 `Exception` → `FailureCode.unknown`（覆盖 `.asApi()` 兜底）。
- [ ] 方法同时写本地：验证本地写入仅在成功时发生（或始终发生——部分失败方法）。
