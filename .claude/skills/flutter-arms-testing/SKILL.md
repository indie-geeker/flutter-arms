---
name: flutter-arms-testing
description: Write and debug tests for a flutter_arms project using flutter_test + mocktail + ProviderContainer + TranslationProvider. Use this skill whenever the task involves tests in a flutter_arms project — writing a unit test, widget test, repository test, ViewModel test, debugging a failing test, understanding an architecture_test failure, adding a test-helper, setting up fixtures with mocktail, or overriding Riverpod providers for tests. Also triggered by: "write a test for this", "this test is failing", "mock the repository", "ProviderContainer", "testWidgets", "给这个加个测试", "架构测试报错", "the architecture test is red". Do NOT use mockito (not on the deps list), do NOT hand-roll fake notifiers, do NOT instantiate Notifiers with `new` outside a ProviderContainer. Apply proactively when the user shows test code or mentions any testing concept, even if they don't explicitly say "skill".
---

# flutter-arms-testing

Testing in flutter_arms uses a specific combination: `flutter_test` (built in) + `mocktail` (for mocks) + `flutter_riverpod`'s `ProviderContainer` (for overriding providers) + `TranslationProvider` (for slang-backed widget tests). Plus an always-on architecture test that statically enforces layer boundaries.

## The four test shapes

| Shape | What it verifies | Tools | Reference |
|---|---|---|---|
| **Repository test** | Data → Domain conversion: remote/local calls, `.asApi()` unwrap, `on AppException catch` | mocktail `Mock` on DataSources | `references/repository_tests.md` |
| **ViewModel test** | State transitions on user actions, Result switching | `ProviderContainer` + `overrideWithValue` on UseCase | `references/viewmodel_tests.md` |
| **Widget test** | Page renders correctly, taps dispatch right action | `TranslationProvider` + `ProviderScope.overrides` | `references/widget_tests.md` |
| **Architecture test** | Static layer boundary rules | text scanning over `lib/`, no DI | `references/architecture_test.md` |

Pick the shape that matches what you're testing. A Repository test doesn't need a widget, a widget test shouldn't reach into Riverpod internals.

## Critical rules

1. **mocktail, not mockito.** mockito is not on the dependency list. mocktail uses `when(() => ...)` with a lambda and `registerFallbackValue` for non-primitive arg matchers. Don't mix them.

2. **Always `addTearDown(container.dispose)`** after creating a `ProviderContainer`. Otherwise Riverpod leaks between tests.

3. **Override the UseCase provider in ViewModel tests**, not the Repository. The ViewModel reads the UseCase; that's the seam. Overriding deeper makes tests brittle.

4. **Widget tests need `TranslationProvider`** around the `ProviderScope`, or `context.t.xxx` throws. Also `LocaleSettings.setLocaleSync(AppLocale.en)` in `setUp` for deterministic assertions.

5. **Stub every method mocktail's strict mode will call.** If the Mock fails with "MissingStubError", you forgot a `when(...)`. Prefer stubbing only what the test exercises — over-stubbing hides regressions.

6. **Test file mirrors `lib/` structure.** `lib/features/auth/data/repositories/auth_repository_impl.dart` → `test/features/auth/data/repositories/auth_repository_impl_test.dart`. No exceptions.

7. **Run `tool/test.sh` before declaring done.** It runs `flutter analyze` (very_good_analysis) + `flutter test` (including the architecture test). Don't assume individual test success means the suite passes.

## Test naming

- File: `<source_file_name>_test.dart`.
- `group('ClassName')` or `group('methodName')` at the top level.
- `test('should <expected outcome> when <condition>')` — "should" form makes assertions readable.
- Variables inside: `input*`, `mock*`, `actual*`, `expected*` (Arrange-Act-Assert).

## Quick examples

### Repository (happy path + error)

```dart
test('should return user on successful remote login', () async {
  when(() => remote.login(any())).thenAnswer((_) async => token);
  when(() => local.saveToken(token)).thenAnswer((_) async {});
  when(() => remote.me()).thenAnswer((_) async => userModel);
  when(() => local.saveUser(userModel)).thenAnswer((_) async {});

  final result = await repository.login(
    username: 'alice',
    password: 'secret',
  );

  expect(result.isSuccess, isTrue);
  expect(result.data, expectedUser);
});
```

### ViewModel (via ProviderContainer)

```dart
test('should set typed failure when login fails', () async {
  when(() => mockLoginUseCase(username: 'tester', password: 'wrong'))
      .thenAnswer((_) async => const Result.failure(
            Failure(code: FailureCode.auth, detail: 'invalid credentials'),
          ));

  final container = ProviderContainer(
    overrides: [loginUseCaseProvider.overrideWithValue(mockLoginUseCase)],
  );
  addTearDown(container.dispose);

  final notifier = container.read(loginViewModelProvider.notifier);
  notifier.updateUsername('tester');
  notifier.updatePassword('wrong');
  await notifier.login();

  final state = container.read(loginViewModelProvider);
  expect(state.error?.code, FailureCode.auth);
  expect(state.error?.detail, 'invalid credentials');
});
```

### Widget (via TranslationProvider + ProviderScope)

```dart
testWidgets('renders guest header when not authenticated', (tester) async {
  final storage = _stubStorage();
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [kvStorageProvider.overrideWithValue(storage)],
        child: const MaterialApp(home: ProfilePage()),
      ),
    ),
  );

  expect(find.text('Guest'), findsOneWidget);
});
```

### Architecture (runs automatically)

No code to write — `test/core/architecture_test.dart` scans `lib/` and fails if rules are broken. Use `// arch-exempt: <reason>` to whitelist legitimate cross-cuts.

## When to consult which reference

- **`references/repository_tests.md`** — mocktail setup, stubbing `remote.xxx().asApi()` indirectly, testing the `on AppException catch` branch, testing partial-failure (logout-style) methods.
- **`references/viewmodel_tests.md`** — `ProviderContainer` patterns, overriding UseCase providers, testing state transitions, testing validation paths that never hit the repository.
- **`references/widget_tests.md`** — `TranslationProvider` setup, overriding storage for Profile-style tests, `testWidgets` vs `pumpAndSettle`, finding widgets by predicate for custom painted elements.
- **`references/architecture_test.md`** — what the four rules check, how to read a failure, when to add `// arch-exempt`, when to extend the test file with new rules.
- **`references/test_helpers.md`** — reusable fixtures and helpers (mock storage stub, container builder, locale setup), mocktail `registerFallbackValue` checklist.

## Running tests

- `tool/test.sh` — analyze + full test suite (what CI runs). Required to pass before shipping.
- `flutter test test/features/<f>/` — single feature.
- `flutter test test/features/auth/data/repositories/auth_repository_impl_test.dart -r expanded` — single file with verbose output.
- `flutter test --name 'should return user'` — by test name substring (handy for debugging one failure).

## Coverage

Not enforced by a threshold in this project, but aim for:

- **Repositories**: 100% of branches (success + each AppException kind → Failure mapping).
- **ViewModels**: every public action, plus the validation-before-remote path.
- **Pages**: at least "renders" + key interactions (tap → action dispatched).
- **Architecture**: automatic — just don't violate the rules.

## What to AVOID

- `mockito` — not on the deps list.
- Creating Notifier instances manually (`MyViewModel()`) — always via `container.read(provider.notifier)`.
- Overriding too deep (mocking `dioProvider` directly when the real target is a UseCase). Mock at the seam.
- `testWidgets` without `TranslationProvider` — slang calls will fail with a type error on `context.t`.
- Asynchronous widget tests without `await tester.pump()` or `await tester.pumpAndSettle()` after every action.
- Depending on real network / real Hive in unit tests — override both.
- Skipping `addTearDown(container.dispose)` — leaks cause spooky test interference.
