# ADR-003: Result Sealed Class Over dartz Either

## Status

Accepted (migrated in v1.1.0)

## Context

The project initially used [dartz](https://pub.dev/packages/dartz) `Either`
for typed error handling. With Dart 3's introduction of **sealed classes**
and **exhaustive pattern matching**, the language now provides native support
for the same pattern without external dependencies.

### Problems with dartz Either

| Issue | Detail |
|-------|--------|
| External dependency | Adds ~50 KB to the package graph |
| Non-idiomatic | Haskell naming (`Left`/`Right`) confuses Dart developers |
| No exhaustive matching | `fold()` callback-based; easy to forget a case |
| Maintenance risk | dartz is community-maintained with infrequent updates |

## Decision

Replace `dartz Either<Failure, Success>` with a project-owned
`Result<F, S>` sealed class:

```dart
sealed class Result<F, S> {
  const Result();
}

final class Success<F, S> extends Result<F, S> {
  final S value;
  const Success(this.value);
}

final class Failure<F, S> extends Result<F, S> {
  final F error;
  const Failure(this.error);
}
```

Usage:

```dart
switch (result) {
  case Success(:final value): handleSuccess(value);
  case Failure(:final error): handleError(error);
}
```

## Consequences

### Positive

- **Zero external dependencies** for error handling.
- **Exhaustive pattern matching** — compiler enforces all cases are handled.
- **Idiomatic Dart 3** — `Success`/`Failure` naming is self-documenting.
- ~50 lines of code vs. pulling in the entire dartz package.

### Negative

- Missing convenience methods (`map`, `flatMap`, `getOrElse`) that dartz
  provided — can be added as extensions if needed.
- Existing tutorials referencing dartz patterns may confuse newcomers.
