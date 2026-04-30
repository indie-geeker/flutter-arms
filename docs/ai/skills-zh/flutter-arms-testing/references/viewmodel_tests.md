# ViewModel 测试

ViewModel 就是 Riverpod Notifier。测试要验证：

1. 用户动作引起的状态迁移（initial → loading → success/failure）。
2. 对应的 UseCase 以正确参数被调用。
3. UseCase 未触发前就短路的客户端校验路径。

## 文件位置

`test/features/<f>/presentation/view_models/<f>_view_model_test.dart` —— 镜像 `lib/`。

## 骨架

```dart
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/<f>/data/repositories/<f>_repository_impl.dart';
import 'package:flutter_arms/features/<f>/domain/entities/<f>.dart';
import 'package:flutter_arms/features/<f>/domain/usecases/get_<f>_usecase.dart';
import 'package:flutter_arms/features/<f>/presentation/view_models/<f>_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGet<F>UseCase extends Mock implements Get<F>UseCase {}

void main() {
  late _MockGet<F>UseCase mockUseCase;

  setUp(() {
    mockUseCase = _MockGet<F>UseCase();
  });

  // tests follow...
}
```

注意：之所以 import `data/repositories/<f>_repository_impl.dart`，是因为 UseCase 的 provider 就放在 Repository 同一文件（就近声明）。测试不会直接把 `domain/usecases/*` 当类型源——我们 mock 的是类，不是实例。

## 标准测试

```dart
test('should update state to success when load succeeds', () async {
  when(() => mockUseCase()).thenAnswer(
    (_) async => const Result.success(<Post>[
      Post(id: '1', title: 'Hello'),
    ]),
  );

  final container = ProviderContainer(
    overrides: [
      get<F>UseCaseProvider.overrideWithValue(mockUseCase),
    ],
  );
  addTearDown(container.dispose);

  final notifier = container.read(<f>ViewModelProvider.notifier);
  await notifier.load();

  final state = container.read(<f>ViewModelProvider);
  expect(state.isLoading, isFalse);
  expect(state.items, hasLength(1));
  expect(state.error, isNull);
});
```

五步：

1. Stub UseCase 返回期望的 `Result`。
2. 创建 `ProviderContainer` 并 override UseCase provider。
3. `addTearDown(container.dispose)` —— 关键，不要跳过。
4. 读取 notifier，调用待测动作，`await` 它。
5. 读取 state 并断言。

## 失败测试

```dart
test('should set typed failure when load fails', () async {
  when(() => mockUseCase()).thenAnswer(
    (_) async => const Result.failure(
      Failure(code: FailureCode.network, detail: 'no connection'),
    ),
  );

  final container = ProviderContainer(
    overrides: [
      get<F>UseCaseProvider.overrideWithValue(mockUseCase),
    ],
  );
  addTearDown(container.dispose);

  await container.read(<f>ViewModelProvider.notifier).load();

  final state = container.read(<f>ViewModelProvider);
  expect(state.isLoading, isFalse);
  expect(state.error?.code, FailureCode.network);
  expect(state.error?.detail, 'no connection');
});
```

## 校验短路测试

如果 ViewModel 在调 UseCase 前会做校验（比如 `LoginViewModel` 校验空用户名/密码）：

```dart
test('should set validation failure when input is empty', () async {
  final container = ProviderContainer(
    overrides: [
      loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
    ],
  );
  addTearDown(container.dispose);

  final notifier = container.read(loginViewModelProvider.notifier);
  await notifier.login();  // 没设 username/password

  final state = container.read(loginViewModelProvider);
  expect(state.error?.code, FailureCode.validation);

  // 验证 UseCase 根本没被调：
  verifyNever(
    () => mockLoginUseCase(
      username: any(named: 'username'),
      password: any(named: 'password'),
    ),
  );
});
```

`verifyNever` 断言零次调用。这能守住"校验意外穿透"的回归。

## mocktail 的具名参数

UseCase 常用具名参数（如 `login({required String username, required String password})`）：

```dart
when(
  () => mockLoginUseCase(username: 'tester', password: '123456'),
).thenAnswer((_) async => Result.success(user));
```

用 `any(named: 'username')` 做通配：

```dart
when(
  () => mockLoginUseCase(
    username: any(named: 'username'),
    password: any(named: 'password'),
  ),
).thenAnswer((_) async => Result.success(user));
```

## 测试中间态

如果要断言 `isLoading: true` 的中间态（多数测试不需要，看终态就够），用 `Completer`：

```dart
test('sets isLoading while UseCase is pending', () async {
  final completer = Completer<Result<List<Post>>>();
  when(() => mockUseCase()).thenAnswer((_) => completer.future);

  final container = ProviderContainer(
    overrides: [get<F>UseCaseProvider.overrideWithValue(mockUseCase)],
  );
  addTearDown(container.dispose);

  final future = container.read(<f>ViewModelProvider.notifier).load();

  expect(container.read(<f>ViewModelProvider).isLoading, isTrue);

  completer.complete(const Result.success(<Post>[]));
  await future;

  expect(container.read(<f>ViewModelProvider).isLoading, isFalse);
});
```

## 测试 build() 里的读取（AuthNotifier 风格）

如果 Notifier 的 `build()` 会读其它 provider（比如 `AuthNotifier.build()` 读 `kvStorageProvider`）：

```dart
class _MockKvStorage extends Mock implements KvStorage {}

test('starts authenticated when access token present', () {
  final storage = _MockKvStorage();
  when(() => storage.getAccessToken()).thenReturn('stored-token');

  final container = ProviderContainer(
    overrides: [kvStorageProvider.overrideWithValue(storage)],
  );
  addTearDown(container.dispose);

  expect(container.read(authProvider), isTrue);
});
```

读 provider 会触发 `build()`，此时 stub 被命中。

## 避免清单

- 直接 `new` 出 `<F>ViewModel()` —— 会绕过 Riverpod，`ref` 不可用。始终走 `container.read(provider.notifier)`。
- Override `<f>RepositoryProvider` 而不是 UseCase provider —— 过深，还把测试绑死到 UseCase 实现细节。
- 断言 Notifier 内部方法 —— 测可观测的 state，不测路径。
- 忘了 `await` 异步动作 —— 断言时状态还没迁移。
- 在测试间共享 `ProviderContainer` —— 测试变成顺序敏感。每个测试新建一个。
- 手动调 `build()` 测副作用 —— 直接 `container.read(provider)` 或 `.notifier` 即可。

## ViewModel 覆盖率清单

- [ ] 初始状态与 `build()` 返回的一致。
- [ ] 每个动作的成功路径：状态迁移正确。
- [ ] 每个动作的失败路径：`error` 设成正确的 `FailureCode`。
- [ ] 客户端校验（如有）：UseCase 不被调用。
- [ ] 中间 `isLoading` 状态（仅当业务重要时，多数可跳过）。
