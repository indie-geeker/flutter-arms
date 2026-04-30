# Architecture rules

`test/core/architecture_test.dart` fails whenever one of these rules is violated. Read a failure as "what the scanner found" and fix at the source.

## Rule 1: Domain must not import Data-layer transport

Files under `lib/features/<any>/domain/**` must NOT contain:

- `import 'package:dio/…'`
- `import 'package:hive_ce/…'` or `hive_ce_flutter`
- `import 'package:retrofit/…'`

Keep domain pure Dart. If you think you need one of these types in domain, you're modelling at the wrong layer — define an interface in domain, implement it in data.

## Rule 2: Domain/Presentation must not import AppException

Files under `lib/features/<any>/{domain,presentation}/**` must NOT import:

- `package:flutter_arms/core/error/app_exception.dart`
- `package:flutter_arms/core/error/app_exception_mapper.dart`

Domain and Presentation only know `Failure` + `FailureCode`. The Repository implementation is the only place that sees both — `AppException` coming in from the data sources and `Failure` going out to domain.

## Rule 3: `core/` must not import `features/`

Files under `lib/core/**` must NOT import anything from `lib/features/`. If `core` truly needs it (auth is the typical case), add a line comment directly above the import:

```dart
// arch-exempt: TokenInterceptor needs auth's refresh datasource to rotate tokens.
import 'package:flutter_arms/features/auth/data/datasources/auth_remote_datasource.dart';
```

The comment must explain the cross-cut. Do not use `arch-exempt` as a blanket escape hatch — if a file has 3+ exemptions, consider promoting the dependency to `core/`.

## Rule 4: `features/<X>` must not import `features/<Y>`

Inside `lib/features/`, each feature is isolated. Cross-feature import fails the test. Same `// arch-exempt:` rule applies. Today the whitelist is auth-only:

- `features/home/presentation/pages/profile_page.dart` → `auth_notifier.dart` (logout from Profile)
- `features/splash/presentation/pages/splash_page.dart` → `auth_notifier.dart` (route on login state)

## How to read a failure

```
Expected: empty
Actual: ['features/settings/domain/settings.dart -> package:dio/']
```

means `features/settings/domain/settings.dart` imports `package:dio/...`, which is forbidden. Either move that type to `data/` or define a domain-pure alternative.

```
Expected: empty
Actual: ['features/profile/presentation/profile_page.dart -> features/auth']
```

means a cross-feature import. Either promote the shared capability to `core/`, or add `// arch-exempt: <real reason>` above the import line.

## When to promote to `core/`

Promote when the same capability is consumed by two or more features. Candidates:

- Cross-feature utilities (date formatting, string extensions — already in `core/extensions/`).
- Shared DI providers (logger, storage, dio client — already in `core/{logger,storage,network}/`).
- Cross-cutting concerns (error model, Result, theming — already in `core/{error,result,theme}/`).

Auth itself could be promoted to `core/auth/` if it grows more arch-exempts. Today it has three, all documented.

## Extending the architecture test

If you introduce a new cross-cut concern (e.g. analytics, feature-flags), update `test/core/architecture_test.dart` to add a new rule OR explicitly whitelist the new pattern. Don't work around it with arch-exempt in dozens of places.
