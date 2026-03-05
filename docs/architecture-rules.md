# Architecture Rules (app/example)

This document defines dependency boundaries for `app/example` after feature-slice migration.

## 1) Directory Responsibilities

- `lib/src/bootstrap/`: module composition and profile selection.
- `lib/src/features/<feature>/`: feature-local code (`data/domain/presentation/di`).
- `lib/src/shared/`: app-wide constants and shared primitives.
- `lib/src/di/providers.dart`: provider export facade only.
- `lib/src/router/`: route declarations and wiring.

## 2) Allowed Imports

- `bootstrap` may import `package:module_*` packages.
- Feature `data` may import its own feature `domain` and stable interfaces.
- Feature `presentation` may import its own feature `domain`/`di` and `shared` abstractions.
- Feature-to-feature communication must go through `shared` abstractions (no internal cross imports).

## 3) Forbidden Imports

- Any `package:module_*` import outside `lib/src/bootstrap/module_composition.dart`.
- Any `ServiceLocator()` usage inside `lib/src/features/**/presentation/**`.
- Any direct import from `features/<A>/...` into `features/<B>/...` where `A != B`.

## 4) Automated Guard

Run:

```bash
melos run lint:arch
```

Current script location:

- `scripts/check_architecture_deps.sh`

CI workflows execute this check before analyze/test stages.

## 5) Feature Structure Tiers

### Full Feature (complex business logic)
Required dirs: `data/datasources/`, `data/models/`, `data/repositories/`,
`domain/entities/`, `domain/failures/`, `domain/repositories/`, `domain/usecases/`,
`presentation/`, `di/`.

### Lite Feature (simple UI + read/write)
Required dirs: `presentation/`, `di/`.
Optional dirs: `data/repositories/`, `domain/repositories/`.

### Tier Selection Criteria
- Independent domain entities + complex rules + multiple data sources → **Full**
- Primarily UI interaction + simple data read/write → **Lite**

## 6) Cross-Feature Communication

Features must **never** import another feature's internal code directly.
All inter-feature communication flows through `shared/` abstractions.

### Allowed Patterns

| Pattern | Example |
|---------|---------|
| Shared abstract class / interface | `shared/auth/auth_session.dart` |
| Riverpod provider in `shared/` or `di/` | `authSessionProvider` |
| Shared value objects / DTOs | `shared/models/user_summary.dart` |

### `shared/` Addition Checklist

1. Is the concept used by **≥ 2 features**? → belongs in `shared/`
2. Is it used by **exactly 1 feature**? → stays in that feature
3. Is it **infrastructure**? → belongs in `packages/interfaces`
4. `shared/` must **never** import from `features/` (enforced by Rule 4 in CI).

See [ADR-004](decisions/004-cross-feature-communication.md) for full rationale.
