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
