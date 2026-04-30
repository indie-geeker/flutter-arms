# Architecture test

Location: `test/core/architecture_test.dart`. Runs automatically with `flutter test` and `tool/test.sh`. No DI, no widgets — just text scanning over `lib/` files with `RegExp`.

## What it enforces (four rules)

### Rule 1: Domain must not import Data-layer transport

Files under `lib/features/*/domain/**` are checked for these forbidden imports:

- `import 'package:dio/...'`
- `import 'package:hive_ce/...'`
- `import 'package:hive_ce_flutter/...'`
- `import 'package:retrofit/...'`

Each offense produces an entry like `features/<f>/domain/<path> -> package:dio/` in the failure message.

### Rule 2: Domain/Presentation must not import AppException

Files under `lib/features/*/{domain,presentation}/**` must not import:

- `package:flutter_arms/core/error/app_exception.dart`
- `package:flutter_arms/core/error/app_exception_mapper.dart`

Matched via `RegExp(r"import\s+['\x22]package:flutter_arms/core/error/app_exception(?:_mapper)?\.dart['\x22]")` — so both `'...'` and `"..."` quoting styles are caught.

### Rule 3: `core/` must not import `features/`

Files under `lib/core/**` must not import `package:flutter_arms/features/...`. Escape hatch: add `// arch-exempt` anywhere in the file (convention: on the line above the import), and the whole file is skipped.

Today's legitimate exempts:

- `lib/core/network/dio_client.dart` — needs `features/auth/data/datasources/auth_remote_datasource.dart` for TokenInterceptor's refresh chain.

### Rule 4: `features/<X>` must not import `features/<Y>`

Files under `lib/features/<X>/**` must not import `package:flutter_arms/features/<Y>/...` for any `Y != X`. Same `// arch-exempt` escape.

Today's legitimate exempts:

- `lib/features/home/presentation/pages/profile_page.dart` — imports `AuthNotifier` for logout.
- `lib/features/splash/presentation/pages/splash_page.dart` — imports `AuthNotifier` for route-on-login-state.

## Reading a failure

Sample output:

```
Expected: empty
Actual: ['features/settings/domain/settings.dart -> package:dio/']
```

Meaning: `lib/features/settings/domain/settings.dart` has `import 'package:dio/...'`, which Rule 1 forbids.

Fix: either move the type that requires `dio` into `lib/features/settings/data/`, or define a pure-Dart alternative in domain and have data map to it.

```
Expected: empty
Actual: ['features/post/presentation/post_page.dart -> features/user']
```

Meaning: Rule 4 — `post/presentation/...` imports from `features/user/`. Either promote the shared capability to `core/` (preferred), or add `// arch-exempt: <why>` above the import.

## Using `// arch-exempt`

Format:

```dart
// arch-exempt: <short reason>
import 'package:flutter_arms/features/auth/presentation/view_models/auth_notifier.dart';
```

The test looks for the literal substring `// arch-exempt` anywhere in the file content. The comment above the offending import is the conventional position (keeps the reason near the code it applies to). One comment per file suffices to exempt all cross-cuts in that file.

**Guidance on when to add an exemption:**

- ✅ Auth cross-cuts (login state, token refresh).
- ✅ Router / bootstrap wiring (core/app needs access to feature entry points).
- ❌ Convenience (I don't want to refactor right now).
- ❌ Multiple exemptions per file — if a file has 3+, the design is wrong; promote to `core/`.

Every exemption costs readability. Justify it with a real sentence, not "arch-exempt: needed".

## Extending the test

When adding a new category of cross-cutting concern (analytics, feature flags, etc.), update `architecture_test.dart` to:

1. Add a new `test(...)` block following the existing pattern.
2. Either forbid a specific import globally, OR allow it only from a designated directory.
3. Keep the failure message actionable — include the file path and the offending pattern.

Example structure:

```dart
test('features must not import analytics directly', () {
  final offenders = <String>[];
  final forbidden = RegExp(
    r"import\s+['\x22]package:flutter_arms/core/analytics/",
  );
  for (final feature in featuresDir.listSync().whereType<Directory>()) {
    for (final file in dartFiles(feature)) {
      final content = file.readAsStringSync();
      if (content.contains('// arch-exempt')) continue;
      if (forbidden.hasMatch(content)) {
        offenders.add(rel(file));
      }
    }
  }
  expect(offenders, isEmpty, reason: 'features use AnalyticsPort instead');
});
```

## Debugging tips

- **Run just the architecture test**: `flutter test test/core/architecture_test.dart`.
- **Which rule failed?** The `reason:` argument names the rule in the failure message.
- **Which file is the offender?** It's in the `Actual:` list. Open it.
- **The fix almost always is one of:**
  1. Move the file to the right layer (domain → data, or features/X → core).
  2. Replace the import with a domain-pure alternative.
  3. Add `// arch-exempt: <real reason>` if the cross-cut is genuinely necessary.

## What to AVOID

- Disabling the test to "get unblocked" — once disabled, invariants erode fast.
- Adding `// arch-exempt` without a real reason — the reason makes future-you think twice before extending the escape.
- Editing the test rules to permit a specific violation — tighten the design instead.
- Writing code that passes the test but violates the spirit (e.g. re-exporting `dio` through a domain file). The test is necessary, not sufficient — design still matters.
