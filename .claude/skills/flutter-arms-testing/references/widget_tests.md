# Widget tests

Widget tests verify UI behavior: rendering, taps, navigation, and wiring to providers. They need two wrappers that unit tests don't:

- `TranslationProvider` — otherwise `context.t.xxx` throws.
- `ProviderScope` — otherwise any Riverpod reads fail.

## File location

`test/features/<f>/presentation/pages/<f>_page_test.dart` — mirrors `lib/`.

## Setup skeleton

```dart
import 'package:flutter/material.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/<f>/presentation/pages/<f>_page.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockKvStorage extends Mock implements KvStorage {}
// Add other mocks as needed (UseCase, Repository, etc.)

/// Pumps <F>Page with all required providers wired.
Future<void> _pump<F>Page(
  WidgetTester tester, {
  required _MockKvStorage storage,
  // add more dependencies as named params
}) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          kvStorageProvider.overrideWithValue(storage),
          // + any other overrides
        ],
        child: const MaterialApp(home: <F>Page()),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    // Register any non-primitive fallback values here.
  });

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  group('<F>Page', () {
    testWidgets('renders initial state', (tester) async {
      final storage = _MockKvStorage();
      // Stub whatever the page reads in initState / build.
      when(() => storage.getAccessToken()).thenReturn(null);

      await _pump<F>Page(tester, storage: storage);
      await tester.pumpAndSettle();

      expect(find.text('Expected text'), findsOneWidget);
    });
  });
}
```

Key points:

- **`TranslationProvider` wraps `ProviderScope`** (not the other way around). slang needs to be outermost so any page inside can access `context.t`.
- **`LocaleSettings.setLocaleSync(AppLocale.en)` in `setUp`** makes text assertions deterministic. If you're testing Chinese-specific behavior, set `AppLocale.zh` and assert on Chinese strings instead.
- **`MaterialApp(home: ...)`** supplies the default Material theme and MediaQuery that most widgets depend on.
- **`_pump<F>Page` is a helper** — factor it out so each test focuses on the scenario, not the boilerplate.

## Common patterns

### Finding text

```dart
expect(find.text('Logout'), findsOneWidget);
expect(find.textContaining('error'), findsWidgets);
```

Text assertions match the currently-set locale. If you set `AppLocale.zh` in setUp, assert Chinese strings.

### Finding by icon / widget type

```dart
expect(find.byIcon(Icons.person), findsOneWidget);
expect(find.byType(AppButton), findsOneWidget);
```

### Finding by predicate (for custom-painted widgets)

From `profile_page_test.dart`:

```dart
final purpleCircle = find.byWidgetPredicate((widget) {
  if (widget is Container) {
    final decoration = widget.decoration;
    if (decoration is BoxDecoration) {
      return decoration.color == const Color(0xFF7C3AED);
    }
  }
  return false;
});
expect(purpleCircle, findsOneWidget);
```

Use this when a widget has no accessible text/semantics label to target.

### Tapping and pumping

```dart
await tester.tap(find.byIcon(Icons.add));
await tester.pumpAndSettle();  // drain animations + microtasks

expect(find.byType(AlertDialog), findsOneWidget);
```

Always `await tester.pump()` (single frame) or `pumpAndSettle()` (run until idle) after an action. Otherwise widgets haven't rebuilt yet and assertions race.

### Verifying an action dispatched to a provider

```dart
Color? capturedColor;
when(() => storage.setThemeSeedColor(any())).thenAnswer((inv) async {
  capturedColor = inv.positionalArguments.first as Color;
});

await _pump<F>Page(tester, storage: storage);
await tester.tap(find.byWidgetPredicate(/* matches purple */));
await tester.pump();

expect(capturedColor, equals(const Color(0xFF7C3AED)));
```

Capture the call via `thenAnswer` side effect, then assert. Useful when you can't easily observe the provider state change.

### Asserting on a SegmentedButton's selection

```dart
final segmented = tester.widget<SegmentedButton<ThemeMode>>(
  find.byType(SegmentedButton<ThemeMode>),
);
expect(segmented.selected, equals({ThemeMode.system}));
```

`tester.widget<T>(finder)` extracts the widget instance for direct property access.

## Stubbing KvStorage (common enough to factor out)

```dart
_MockKvStorage _stubStorage() {
  final s = _MockKvStorage();
  when(s.getThemeMode).thenReturn(ThemeMode.system);
  when(s.getThemeSeedColor).thenReturn(const Color(0xFF1D4ED8));
  when(s.getLocale).thenReturn(null);
  when(s.getAccessToken).thenReturn(null);
  when(s.getUserMap).thenReturn(null);
  return s;
}
```

Tag this helper as private (`_stubStorage`) at the top of the test file, or promote to a shared fixture if multiple test files need it.

### Mocking the UseCase for a ViewModel-backed page

If the page reads a ViewModel whose UseCase hits the network, override the UseCase provider the same way ViewModel tests do:

```dart
class _MockGet<F>UseCase extends Mock implements Get<F>UseCase {}

Future<void> _pump<F>Page(
  WidgetTester tester, {
  required _MockGet<F>UseCase useCase,
}) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          get<F>UseCaseProvider.overrideWithValue(useCase),
        ],
        child: const MaterialApp(home: <F>Page()),
      ),
    ),
  );
}
```

The page will read the ViewModel, which reads the UseCase (now the mock), so the page ends up driven by stubbed data.

## Navigation tests with AutoRoute

AutoRoute's default nav uses `context.router.push(...)`. To test that a tap triggers navigation:

- Simplest: wrap with `MaterialApp(home: ...)` and assert the destination page appears (if it's a sub-widget) OR that a dialog/bottom sheet opens.
- More thorough: use `AutoRoute`'s `RootStackRouter` in the test with a stub, and verify on push. Usually overkill — most widget tests stay focused on the single page.

For top-level nav (like Login → Home), prefer a ViewModel test on the `isLoginSuccess` flag instead.

## What to AVOID

- `testWidgets` without `TranslationProvider` — `context.t.xxx` will throw immediately with a type error.
- Missing `setUp` with `LocaleSettings.setLocaleSync` — assertions become locale-sensitive and flake based on environment.
- Asserting against English text while locale is Chinese (or vice versa) — check what you set in `setUp`.
- Not awaiting `pump` / `pumpAndSettle` after an action — state hasn't propagated yet.
- Overriding `dioProvider` just to make a widget test pass — instead, override the UseCase or Repository, whichever the page actually reads.
- Using `find.byKey` everywhere — prefer semantic queries (`find.text`, `find.byIcon`, `find.byType`). Keys only when unavoidable (e.g. distinguishing identical list items).
- Letting the Page's real `initState` auto-trigger a network call — if the page uses `WidgetsBinding.instance.addPostFrameCallback` to call `load()`, you MUST stub the UseCase so the test doesn't hang waiting for a real Future.

## Coverage checklist for a Page

- [ ] Initial render: all expected text/icons present, error/empty state not shown.
- [ ] Key interactions: button taps dispatch the right action (verify via mock side effect or state change).
- [ ] Loading state: while an async action is pending, loading indicator is visible.
- [ ] Error state: when state.error is set, `AppDialog.showError` or inline error renders.
- [ ] Empty state: when list is empty and not loading, `EmptyStateWidget` shows.
- [ ] Localization: at least one test asserts a translated string to catch i18n regressions.
