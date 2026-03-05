# ADR-002: Four-Layer Module Architecture

## Status

Accepted

## Context

The framework needs clear separation between abstract contracts, concrete
implementations, orchestration logic, and application code. Without
explicit layers, imports become tangled and replacing an infrastructure
module requires touching business logic.

## Decision

Adopt a **four-layer architecture** with strict dependency direction:

```
interfaces  ←  modules
     ↑             ↑
    core    →  interfaces
     ↑
    app     →  core
```

| Layer | Responsibility | May depend on |
|-------|----------------|---------------|
| **interfaces** | Abstract contracts (`ILogger`, `IHttpClient`, etc.) | Dart SDK only |
| **modules** | Concrete implementations (Dio, Hive, etc.) | interfaces |
| **core** | DI container, lifecycle orchestration, module registry | interfaces, GetIt |
| **app** | Business logic, UI, state management | core, interfaces |

### Enforcement

- `scripts/check_architecture_deps.sh` validates import boundaries in CI.
- `architecture_structure_test.dart` asserts directory structure at test time.
- `docs/architecture-rules.md` documents allowed/forbidden imports.

## Consequences

### Positive

- Modules are **independently publishable** — each has its own `pubspec.yaml`.
- Replacing an implementation (e.g., Dio → http) only touches the module.
- `core` has **zero Flutter-UI dependency**, enabling CLI and test use.

### Negative

- More packages = more boilerplate (`pubspec.yaml`, barrel files).
- New contributors must understand the layer rules before contributing.
- Cross-cutting concerns (e.g., analytics that needs both network and
  storage) must carefully declare dependencies.
