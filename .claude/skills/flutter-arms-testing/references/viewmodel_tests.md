# ViewModel tests

ViewModels are Riverpod Notifiers. Tests verify:

1. State transitions on user actions (initial → loading → success/failure).
2. The right UseCase is invoked with the right arguments.
3. Client-side validation paths that short-circuit before the UseCase runs.

## File location

`test/features/<f>/presentation/view_models/<f>_view_model_test.dart` — mirrors `lib/`.

## Setup skeleton

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

Note: `data/repositories/<f>_repository_impl.dart` is imported because that's where the UseCase provider lives (co-located with the Repository). No test imports `domain/usecases/*` directly as a type-source — the Mock is a class, not an instance.

## Canonical test

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

Five steps:

1. Stub the UseCase to return the desired `Result`.
2. Create a `ProviderContainer` with the UseCase provider overridden.
3. `addTearDown(container.dispose)` — critical, don't skip.
4. Read the notifier, call the action under test, `await` it.
5. Read the state and assert.

## Failure test

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

## Validation short-circuit test

If the ViewModel validates before calling the UseCase (like `LoginViewModel` with empty username/password):

```dart
test('should set validation failure when input is empty', () async {
  final container = ProviderContainer(
    overrides: [
      loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
    ],
  );
  addTearDown(container.dispose);

  final notifier = container.read(loginViewModelProvider.notifier);
  await notifier.login();  // no username/password set

  final state = container.read(loginViewModelProvider);
  expect(state.error?.code, FailureCode.validation);

  // Verify the UseCase was NEVER called:
  verifyNever(
    () => mockLoginUseCase(
      username: any(named: 'username'),
      password: any(named: 'password'),
    ),
  );
});
```

`verifyNever` asserts zero invocations. This guards against regressions where validation accidentally falls through.

## Named arguments in mocktail

For UseCases with named params (common — `login({required String username, required String password})`):

```dart
when(
  () => mockLoginUseCase(username: 'tester', password: '123456'),
).thenAnswer((_) async => Result.success(user));
```

Use `any(named: 'username')` as a wildcard:

```dart
when(
  () => mockLoginUseCase(
    username: any(named: 'username'),
    password: any(named: 'password'),
  ),
).thenAnswer((_) async => Result.success(user));
```

## Intermediate-state testing

If you need to assert the `isLoading: true` intermediate state (most tests don't — final state is enough), use a `Completer`:

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

## Testing reads (AuthNotifier-style)

If the Notifier's `build()` reads from another provider (e.g. `AuthNotifier.build()` reads `kvStorageProvider`):

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

Reading the provider triggers `build()`, which is when the stubs are consulted.

## What to AVOID

- Constructing `<F>ViewModel()` directly — bypasses Riverpod wiring, breaks `ref`. Always go through `container.read(provider.notifier)`.
- Overriding `<f>RepositoryProvider` instead of the UseCase provider — deeper than needed, couples the test to the UseCase implementation.
- Asserting on internal Notifier methods — test the observable state, not the path.
- Forgetting `await` on async actions — the state won't have transitioned yet when you assert.
- Sharing a `ProviderContainer` across tests — tests become order-dependent. Build a fresh one per test.
- Testing `build()` side effects by calling `build()` manually — just call `container.read(provider)` or `.notifier`.

## Coverage checklist for a ViewModel

- [ ] Initial state matches what `build()` returns.
- [ ] Each action's success path: state transitions correctly.
- [ ] Each action's failure path: `error` is set with the right `FailureCode`.
- [ ] Client-side validation (if any): UseCase is NOT called.
- [ ] Intermediate `isLoading` state (only if business-critical, often skippable).
