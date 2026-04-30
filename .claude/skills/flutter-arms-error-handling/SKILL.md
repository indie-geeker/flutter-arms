---
name: flutter-arms-error-handling
description: Apply the flutter_arms error-handling contract — Result<T> (sealed class) + AppException (sealed, Data layer) + Failure/FailureCode (Domain/Presentation), with `.asApi()` as the conversion boundary and `context.failureMessage(failure)` as the UI sink. Use this skill whenever the task touches error handling in a flutter_arms project — including catching DioException, mapping HTTP errors, adding a new FailureCode, adding a new AppException subclass, wiring try/catch in a Repository, deciding whether to throw or return Result, displaying an error in the UI, writing retry logic, handling 401/refresh, or debugging "why is my error message not localized". Also use when the user says: "how do I handle errors here", "why is this throwing DioException", "add a new error type", "the error message shows a stack trace", "refresh token failed", "请求失败时弹什么", "这个 retrofit 报错没被 catch 住". Do NOT use Dartz Either, do NOT let DioException leak above the repository, do NOT use try/catch in UI. This skill is mandatory reading for any error-related change because flutter_arms has a specific two-layer error model that generic Flutter advice gets wrong.
---

# flutter-arms-error-handling

flutter_arms uses a **two-layer error model** with a strict conversion boundary. Getting it wrong leaks `DioException` or breaks i18n. Getting it right means the UI never touches raw exceptions and always shows localized messages.

## The three types

| Type | Layer | Purpose |
|---|---|---|
| **`AppException`** (sealed) | Data only | Normalized exceptions thrown by DataSources / Repositories internally. 7 subclasses: `NetworkException`, `TimeoutException`, `BadResponseException`, `AuthException`, `ValidationException`, `CancelledException`, `UnknownException`. Never imported by domain/presentation. |
| **`Failure`** (value class) | Domain + Presentation | What the UI sees. Has `code: FailureCode`, optional `detail: String?`, optional `cause` / `stackTrace`. Domain uses it in `Result.failure(...)`. |
| **`Result<T>`** (sealed) | Domain + Presentation | `Success<T>` or `FailureResult<T>`. Every Repository method that can fail returns `Future<Result<T>>`. |

## The flow (end-to-end)

```
┌────────────┐   DioException  ┌─────────────────┐  AppException  ┌──────────────┐  Result<T>  ┌────────────┐
│  Retrofit  │────────────────▶│ ApiInterceptor  │───────────────▶│  Repository  │────────────▶│  ViewModel │
│   (Dio)    │                 │   (maps Dio     │  (via .asApi())│  (on         │             │  (switch   │
│            │                 │   → AppEx,      │                │  AppException│             │   Result)  │
│            │                 │   packs in      │                │  catch →     │             │            │
│            │                 │   ex.error)     │                │  Failure)    │             │            │
└────────────┘                 └─────────────────┘                └──────────────┘             └────────────┘
                                                                                                    │
                                                                                                    ▼
                                                                                            ┌──────────────┐
                                                                                            │   UI: show   │
                                                                                            │  failure via │
                                                                                            │context.failure│
                                                                                            │  Message(f)  │
                                                                                            └──────────────┘
```

## CRITICAL rules

1. **`.asApi()` is mandatory on every Retrofit call in a Repository.** Without it, the `on AppException catch` clause will miss because `ApiInterceptor` packs the `AppException` inside `DioException.error` — the raw throw is still a `DioException`.

2. **Repositories return `Future<Result<T>>`, never throw.** Always have `try { ... } on AppException catch (e) { return Result.failure(Failure.fromException(e)); }`.

3. **Domain and Presentation never import `AppException`.** The architecture test will fail. They only know `Failure` + `FailureCode`.

4. **UI renders errors via `context.failureMessage(failure)`.** Never `failure.toString()`, never hardcoded strings, never bare `failure.detail`.

5. **All `FailureCode` values need a matching i18n key at `errors.<code>`** in BOTH `en.i18n.json` and `zh.i18n.json`. Missing keys break slang codegen.

## When to consult which reference

- **`references/result.md`** — `Result<T>` sealed type, pattern matching with `switch`, `ResultX` extensions (`when`, `map`, `mapFailure`, `getOrElse`, `getOrNull`), AVOID list.
- **`references/exceptions.md`** — `AppException` sealed hierarchy, `AppExceptionMapper` (DioException → subclass), `.asApi()` implementation, how `ApiInterceptor` pre-packs exceptions.
- **`references/failure.md`** — `Failure` shape, `FailureCode` enum, `Failure.fromException`, `context.failureMessage`, detail precedence for badResponse/validation.
- **`references/repository_flow.md`** — the canonical Repository try/catch shape, how to add a new method, how to handle partial failures (e.g. remote fails but local succeeds, like logout).
- **`references/ui_display.md`** — `AppDialog.showError`, `ErrorStateWidget`, `SelectableText.rich`, when to use each, the `ref.listen` pattern for dialog triggers.

## Quick decision tree

**"I'm catching a DioException somewhere outside `core/network/`"** → No. Use `.asApi()` + `on AppException catch`. `DioException` only lives inside the `core/network/` chain.

**"My error message shows 'Instance of DioException'"** → You forgot `.asApi()` on the Retrofit call, so the Repository caught a `DioException` and `Failure.fromException` was never called.

**"I need a new error category the existing `FailureCode` enum doesn't cover"** → Add a new `FailureCode` value, a matching `AppException` subclass, update `AppExceptionMapper` if it's Dio-side, update `Failure.fromException` automatically forwards the `code`, update `context.failureMessage`'s switch, and add an `errors.<newCode>` key to both i18n files.

**"I want to retry on specific failures"** → Check `failure.code` in the ViewModel and call the action again. Don't retry inside the Repository automatically (the user should see the error and choose). 401 is the exception — `TokenInterceptor` does refresh-and-retry transparently.

**"The UI needs to show the exact server message"** → For `badResponse` and `validation`, `context.failureMessage` already returns `failure.detail` when present. Make sure your API layer actually fills `detail` — `AppExceptionMapper._extractMsg` reads `message` / `msg` / `error` from the JSON body. If your backend uses a different key, adjust `_extractMsg`.

**"I want to throw from a ViewModel instead of returning Result"** → No. ViewModels update state with `error: failure`. The UI reads it via `ref.listen`.

## Example: adding a new endpoint with proper errors

```dart
// data/datasources/post_remote_datasource.dart
@GET('/posts/{id}')
Future<PostDto> detail(@Path('id') String id);

// data/repositories/post_repository_impl.dart
@override
Future<Result<Post>> detail(String id) async {
  try {
    final dto = await _remote.detail(id).asApi();
    return Result.success(dto.toEntity());
  } on AppException catch (e) {
    return Result.failure(Failure.fromException(e));
  }
}

// presentation/view_models/post_view_model.dart
Future<void> openDetail(String id) async {
  state = state.copyWith(isLoading: true, error: null);
  final result = await ref.read(getPostDetailUseCaseProvider)(id);
  switch (result) {
    case Success(:final data):
      state = state.copyWith(isLoading: false, detail: data);
    case FailureResult(:final failure):
      state = state.copyWith(isLoading: false, error: failure);
  }
}

// presentation/pages/post_page.dart
ref.listen(postViewModelProvider, (prev, next) {
  final failure = next.error;
  if (failure != null && failure != prev?.error) {
    AppDialog.showError(context, context.failureMessage(failure));
  }
});
```

That's the entire round-trip. No `try/catch` in the UI, no raw `DioException` anywhere above the Repository, localized message derived from `FailureCode` + optional server detail.
