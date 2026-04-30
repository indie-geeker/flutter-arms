# Test helpers and fixtures

Patterns that reappear across tests. Factor these out once per test file or promote to a shared fixture under `test/helpers/`.

## Mock KvStorage stub

Many widget tests and AuthNotifier tests need a stubbed `KvStorage`. Copy this into your test file (or into `test/helpers/mock_kv_storage.dart` if multiple files need it):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockKvStorage extends Mock implements KvStorage {}

MockKvStorage stubKvStorage({
  ThemeMode themeMode = ThemeMode.system,
  Color seedColor = const Color(0xFF1D4ED8),
  String? locale,
  String? accessToken,
  String? refreshToken,
  Map<String, dynamic>? userMap,
  bool onboardingDone = false,
}) {
  final s = MockKvStorage();
  when(s.getThemeMode).thenReturn(themeMode);
  when(s.getThemeSeedColor).thenReturn(seedColor);
  when(s.getLocale).thenReturn(locale);
  when(s.getAccessToken).thenReturn(accessToken);
  when(s.getRefreshToken).thenReturn(refreshToken);
  when(s.getUserMap).thenReturn(userMap);
  when(s.isOnboardingDone).thenReturn(onboardingDone);
  return s;
}
```

Usage:

```dart
final storage = stubKvStorage(accessToken: 'token-123');
// test uses storage...
```

## ProviderContainer builder

Reduces the boilerplate in ViewModel tests:

```dart
ProviderContainer buildContainer(List<Override> overrides) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

// Usage:
final container = buildContainer([
  loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
]);
```

Note `addTearDown` is called *inside* the helper, so the test body stays clean.

## Widget test wrapper

A generic pump helper with the standard wrappers:

```dart
Future<void> pumpWithProviders(
  WidgetTester tester, {
  required Widget child,
  List<Override> overrides = const [],
}) {
  return tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: overrides,
        child: MaterialApp(home: child),
      ),
    ),
  );
}

// Usage:
await pumpWithProviders(
  tester,
  child: const FeaturePage(),
  overrides: [
    kvStorageProvider.overrideWithValue(storage),
  ],
);
```

## mocktail registerFallbackValue checklist

Any time `any()` is used with a non-primitive type, register a fallback in `setUpAll`. Common ones:

```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

class _FakeRequestOptions extends Fake implements RequestOptions {}
class _FakeResponse extends Fake implements Response<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRequestOptions());
    registerFallbackValue(_FakeResponse());
    registerFallbackValue(Colors.transparent);           // for Color args
    registerFallbackValue(const Duration(seconds: 1));   // for Duration args
    registerFallbackValue(<String, dynamic>{});          // for Map<String, dynamic> args
  });

  // tests...
}
```

Symptom of a missing fallback: `type 'Null' is not a subtype of type 'RequestOptions'`.

## Deterministic locale in setUp

```dart
import 'package:flutter_arms/i18n/strings.g.dart';

setUp(() {
  LocaleSettings.setLocaleSync(AppLocale.en);
});
```

Without this, tests inherit the host locale or whatever the last test set. For locale-specific tests, override inline:

```dart
testWidgets('renders Chinese labels', (tester) async {
  LocaleSettings.setLocaleSync(AppLocale.zh);
  // ...
});
```

## Free-form async testing

When you need fine control over async completion:

```dart
import 'dart:async';

test('loading stays true until UseCase resolves', () async {
  final completer = Completer<Result<List<Post>>>();
  when(() => mockUseCase()).thenAnswer((_) => completer.future);

  final container = buildContainer([
    getPostUseCaseProvider.overrideWithValue(mockUseCase),
  ]);

  // Kick off the action — don't await.
  final future = container.read(postViewModelProvider.notifier).load();

  // State should be loading NOW.
  expect(container.read(postViewModelProvider).isLoading, isTrue);

  // Complete and settle.
  completer.complete(const Result.success(<Post>[]));
  await future;

  expect(container.read(postViewModelProvider).isLoading, isFalse);
});
```

## Silent Talker

Repository tests inject a real `Talker` but disabled, avoiding log spam:

```dart
import 'package:talker/talker.dart';

late Talker logger;
setUp(() {
  logger = Talker(settings: TalkerSettings(enabled: false));
});
```

Cheaper than mocking Talker, and the log API calls become no-ops.

## Shared fixture directory

If a helper is used in 3+ test files, move it to `test/helpers/<name>.dart`:

```
test/
├── helpers/
│   ├── mock_kv_storage.dart
│   ├── pump_with_providers.dart
│   └── fallback_values.dart
├── core/
├── features/
└── ...
```

Import with relative paths from the test file:

```dart
import '../../../helpers/mock_kv_storage.dart';
```

Keep helpers thin — each should do one thing. A helper that hides too much makes the test body cryptic.

## What to AVOID

- `late` fields set inside the test body but accessed in helpers — flaky ordering.
- Global state (top-level `var` in test files) — order-sensitive.
- `setUpAll` for non-idempotent initialization (e.g. opening Hive boxes) — use `setUp` per-test.
- Stubbing everything upfront "just in case" — tests become unreadable. Stub exactly what's exercised.
- `sleep` or `Future.delayed(Duration.zero)` to wait for async completion — use `tester.pumpAndSettle()` for widgets, `await future` for plain code.
