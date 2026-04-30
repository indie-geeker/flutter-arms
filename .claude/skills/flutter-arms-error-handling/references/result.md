# Result<T> sealed type

Location: `lib/core/result/result.dart`.

## Shape

```dart
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess;
  bool get isFailure;

  T? get data;          // null on failure
  Failure? get failure; // null on success
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  @override final T data;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  @override final Failure failure;
}
```

## Pattern matching (prefer `switch`)

Canonical form — Dart 3 pattern matching on the sealed hierarchy:

```dart
switch (result) {
  case Success(:final data):
    state = state.copyWith(isLoading: false, value: data);
  case FailureResult(:final failure):
    state = state.copyWith(isLoading: false, error: failure);
}
```

The analyzer knows `Result` is sealed and will complain if you miss a branch. Never use `if (result.isSuccess)` + casts — it defeats the exhaustiveness check.

## Extension methods (`ResultX`)

```dart
extension ResultX<T> on Result<T> { ... }
```

Available methods:

### `when<R>({required success, required failure})`

Fold into a single value:

```dart
final message = result.when(
  success: (post) => 'Loaded: ${post.title}',
  failure: (f) => context.failureMessage(f),
);
```

Use for render-time computations. For state updates inside a Notifier, prefer `switch` — it's clearer and the compiler enforces exhaustiveness.

### `map<R>(R Function(T) transform)`

Transform the success branch, pass failure through unchanged:

```dart
final Result<List<String>> titles = postsResult.map(
  (posts) => posts.map((p) => p.title).toList(),
);
```

### `mapFailure(Failure Function(Failure) transform)`

Transform the failure branch, pass success through unchanged. Useful when a UseCase wants to add context to an error:

```dart
return repoResult.mapFailure(
  (f) => Failure(code: f.code, detail: 'During post creation: ${f.detail}'),
);
```

### `getOrElse(T fallback)`

Shorthand for "use the data if success, fall back otherwise":

```dart
final items = result.getOrElse(const <Post>[]);
```

### `getOrNull()`

Same but returns `T?`. Use in defaults:

```dart
final post = result.getOrNull() ?? Post.empty();
```

## Chaining

`Result` is NOT a functor/monad with full `flatMap` — don't try to chain multiple repository calls with `.flatMap(...)`. The pattern is:

```dart
final a = await repo.stepOne();
if (a case FailureResult(:final failure)) {
  return Result.failure(failure);
}
final b = await repo.stepTwo((a as Success).data);
// ...
```

or more cleanly with a helper:

```dart
Future<Result<C>> compose() async {
  final a = await repo.stepOne();
  switch (a) {
    case FailureResult(:final failure):
      return Result.failure(failure);
    case Success(:final data):
      return repo.stepTwo(data);
  }
}
```

Keep this logic in the UseCase layer, not in the ViewModel.

## What to AVOID

- `Dartz` `Either<L, R>` — not on the dependency list. Don't add it.
- `Result<T>` from other packages (`result_type`, `fpdart`) — we use the custom sealed class.
- Throwing inside a function that's declared to return `Result` — always wrap in `try/catch` and return `Result.failure`.
- `result.isSuccess ? (result as Success<T>).data : null` — use `getOrNull()` or pattern match.
- Discarding errors: `result.getOrElse(null)` without logging — if you're swallowing an error, at least `_logger.warning(...)` it.
- Declaring methods as `Future<T>` when they can fail with an expected business error — use `Future<Result<T>>`.
