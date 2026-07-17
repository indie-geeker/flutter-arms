# State management: Riverpod 3 + ViewModel patterns

## Naming convention

| Kind | Name | Lifetime | Annotation | Location |
|---|---|---|---|---|
| Page-level Notifier | `<Feature>ViewModel` | bound to route, auto-disposed | `@riverpod` | `presentation/view_models/<f>_view_model.dart` |
| Global Notifier | `<Feature>Notifier` | survives page changes | `@Riverpod(keepAlive: true)` | `presentation/view_models/<f>_notifier.dart` or `core/<area>/<f>_notifier.dart` |
| DI-only provider | `<f>Provider` (function form) | singleton | `@Riverpod(keepAlive: true)` | co-located with the impl |

Page-level ViewModel is the default. Reach for a global Notifier only when state genuinely needs to outlive the page (auth, theme, locale, or something app-wide).

## Class Notifier template (page-level ViewModel)

```dart
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/%feature%/data/repositories/%feature%_repository_impl.dart';
import 'package:flutter_arms/features/%feature%/presentation/states/%feature%_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '%feature%_view_model.g.dart';

/// %Feature% 页面 ViewModel。
@riverpod
class %Feature%ViewModel extends _$%Feature%ViewModel {
  @override
  %Feature%State build() => const %Feature%State();

  /// 执行业务动作。
  Future<void> doSomething() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await ref.read(doSomethingUseCaseProvider)(/* params */);

    switch (result) {
      case Success(:final data):
        state = state.copyWith(isLoading: false, data: data);
      case FailureResult(:final failure):
        state = state.copyWith(isLoading: false, error: failure);
    }
  }
}
```

Key points:

- `build()` is **pure** — no async work, no side effects. It just returns the initial state.
- All async work lives in methods called by the UI (`onPressed`, etc.).
- Always clear `error: null` when starting a new attempt, so stale errors don't re-fire.
- Use pattern matching (`switch` on the sealed `Result<T>`), not `if (result.isSuccess)`.
- For client-side validation, set `error: Failure(code: FailureCode.validation)` and return early.

## Functional provider template (DI)

Prefer this shape for repositories, datasources, mappers, and use cases:

```dart
@Riverpod(keepAlive: true)
%Feature%Repository %feature%Repository(Ref ref) {
  return %Feature%RepositoryImpl(
    ref.read(%feature%RemoteDataSourceProvider),
    ref.read(%feature%LocalDataSourceProvider),
    ref.read(appLoggerProvider),
  );
}
```

Co-locate it with the concrete class (e.g. put the `%feature%Repository` provider in `%feature%_repository_impl.dart`). This keeps the composition root small — the pattern from `auth_repository_impl.dart` declares repository + 3 UseCases in one file.

## State classes with Freezed

```dart
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/features/%feature%/domain/entities/%feature%.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '%feature%_state.freezed.dart';

/// %Feature% 页面状态。
@freezed
abstract class %Feature%State with _$%Feature%State {
  const factory %Feature%State({
    @Default(false) bool isLoading,
    @Default(<%Feature%>[]) List<%Feature%> items,
    Failure? error,
  }) = _%Feature%State;
}
```

Rules:

- The error field is always typed `Failure? error`, never `String?` — UI localizes via `context.failureMessage(failure)`.
- Booleans use auxiliary verbs: `isLoading`, `hasMore`, `canSubmit`, `isSubmitSuccess`.
- Defaults are baked in via `@Default(...)` so `const %Feature%State()` is valid.
- Don't put `List<DTO>` or `DioException` in state — only domain entities and `Failure`.

## ConsumerWidget patterns

```dart
class %Feature%View extends ConsumerWidget {
  const %Feature%View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Side effects (dialogs, navigation): ref.listen
    ref.listen(%feature%ViewModelProvider, (previous, next) {
      final failure = next.error;
      if (failure != null && failure != previous?.error) {
        AppDialog.showError(context.failureMessage(failure));
      }
      if (next.isSubmitSuccess && previous?.isSubmitSuccess != true) {
        context.router.replace(const NextRoute());
      }
    });

    // Rebuild: ref.watch
    final state = ref.watch(%feature%ViewModelProvider);
    final notifier = ref.read(%feature%ViewModelProvider.notifier);

    // ... render using state and wire actions via notifier.xxx
  }
}
```

Rules:

- `ref.listen` for side effects (dialog / navigation / snackbar). Never trigger a rebuild from a listener.
- `ref.watch` for values that drive rendering.
- `ref.read(provider.notifier)` once per build — cache the handle, don't re-read inside loops.
- Guard side-effect triggers with `previous != next` / `previous?.flag != true` checks so identical rebuilds don't double-fire dialogs.

## Watching derived state

If a widget only cares about part of the state, use `select` to minimize rebuilds:

```dart
final isLoading = ref.watch(
  %feature%ViewModelProvider.select((s) => s.isLoading),
);
```

## What to AVOID

- `StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider` — legacy. Use `@riverpod class` instead.
- `.family` providers — we don't use families here; pass params to the method instead.
- Creating Notifier instances manually (`MyNotifier()`) — always go through Riverpod.
- Business logic in `build()` — it should synthesize state and nothing else.
- Reading one provider inside another's `build()` just to chain them — use `ref.watch` for reactivity, `ref.read` only in event handlers.

## Overriding providers (for testing / bootstrap)

The base pattern is `provider.overrideWithValue(x)` or `provider.overrideWith((ref) => ...)`. In production, infrastructure providers (`appEnvProvider`, `appLoggerProvider`) are overridden in `bootstrap.dart`'s `ProviderScope(overrides: [...])`. In tests, override the UseCase provider to inject a mock — see the `flutter-arms-testing` skill.
