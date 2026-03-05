# ADR-004: Cross-Feature Communication via Shared Abstractions

## Status

Accepted

## Context

In a feature-slice architecture, each feature owns its `data/domain/presentation`
layers. As the app grows, features inevitably need to communicate — e.g. the
"orders" feature needs to know whether the user is authenticated.

Two common anti-patterns emerge:

| Anti-Pattern | Problem |
|---|---|
| Direct imports (`features/a` → `features/b`) | Tight coupling; breaks feature isolation and makes removal/refactoring risky |
| Dumping everything into `shared/` | Shared layer becomes a god-module; changes to shared affect every feature |

## Decision

1. **Features must never import another feature's internal code.**
   - Enforced by lint rule (Rule 3 in `check_architecture_deps.sh`).

2. **Cross-feature communication must go through `shared/` abstractions.**
   - Allowed patterns:
     - **Shared abstract classes / interfaces** (e.g. `AuthSession`)
     - **Riverpod providers** declared in `shared/` or `di/providers.dart`
     - **Value objects / DTOs** in `shared/` that carry inter-feature data

3. **Adding to `shared/` requires justification.**
   - Is the concept used by ≥ 2 features? → belongs in `shared/`
   - Is it used by exactly 1 feature? → stays in that feature
   - Is it infrastructure? → belongs in `packages/interfaces`

4. **`shared/` must never import from `features/`.**
   - Enforced by lint rule (Rule 4 in `check_architecture_deps.sh`).

## Consequences

### Positive

- Features remain independently testable and removable.
- `shared/` stays lean with a clear addition criteria.
- Architecture lint catches violations before code review.

### Negative

- Minor indirection when features need to communicate — requires
  defining an abstraction rather than a direct import.
- Developers must learn the convention (documented in `architecture-rules.md`).
