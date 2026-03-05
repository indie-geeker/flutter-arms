# ADR-001: GetIt + Riverpod Dual DI Strategy

## Status

Accepted

## Context

Flutter apps need dependency injection for both **infrastructure services**
(logging, networking, storage) and **UI state management** (feature notifiers,
form state). Two popular options exist:

- **GetIt** — Service locator, lifecycle management, no Flutter dependency.
- **Riverpod** — Reactive state management with `ref.watch`, tightly
  integrated with Flutter widget tree.

Using only one is possible but creates friction:

| Single-DI Approach | Problem |
|---------------------|---------|
| GetIt everywhere | No reactive rebuilds; features must manually subscribe to state changes |
| Riverpod everywhere | Infrastructure modules (packages/modules) would depend on Flutter/Riverpod, preventing use in CLI or backend |

## Decision

Use **GetIt in the core/module layer** and **Riverpod in the app layer**,
connected by a thin **Provider bridge** (`di/providers.dart`).

```
packages/core      → GetIt (ServiceLocator)
packages/modules/* → register services into IServiceLocator
app/example/di     → Provider bridge (GetIt → Riverpod)
app/example/features → ref.watch(provider) for reactive access
```

## Consequences

### Positive

- Infrastructure packages remain **state-management-agnostic** and reusable
  across Flutter, CLI, and server-side Dart.
- Features get **reactive** access to infrastructure via `ref.watch`.
- Migrating to a different state management library only affects the app layer.

### Negative

- Two DI systems add conceptual overhead for newcomers.
- The bridge layer is manual boilerplate (one `Provider<T>` per service).
- Registration order matters: modules must initialize before Riverpod
  container reads from GetIt.
