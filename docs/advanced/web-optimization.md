# Web Optimization: Deferred Loading

Flutter Web bundles all Dart code into a single JavaScript file by default. For
large apps this causes slow initial loads. **Deferred imports** let you split
code at route boundaries so each page is downloaded only when the user navigates
to it.

## How Deferred Imports Work

```dart
// Eager import (default) — included in main bundle
import 'package:example/src/features/settings/settings.dart';

// Deferred import — loaded on demand
import 'package:example/src/features/settings/settings.dart' deferred as settings;
```

When a deferred library is first used, Dart downloads its JavaScript chunk from
the server. You must call `loadLibrary()` before accessing any symbols:

```dart
await settings.loadLibrary();
final widget = settings.SettingsScreen();
```

## Route-Level Code Splitting with auto_route

auto_route supports deferred loading natively. Convert an eager route to a
deferred route in two steps:

### Step 1: Change the import to `deferred as`

```diff
-import 'package:example/src/features/settings/settings.dart';
+import 'package:example/src/features/settings/settings.dart'
+    deferred as settings;
```

### Step 2: Regenerate the router

```bash
cd app/example
dart run build_runner build --delete-conflicting-outputs
```

auto_route's code generator recognises deferred imports and wraps the route
page in an async loader automatically — no manual `loadLibrary()` call needed in
the router file.

## Best Practices

| Practice | Reason |
|----------|--------|
| Defer **feature screens**, not shared code | Shared code is needed everywhere — deferring it causes repeated downloads |
| Keep deferred imports at the **router level** | Clean separation; feature code remains unaware of loading strategy |
| **Measure** before and after | Use `flutter build web --analyze-size` to compare bundle composition |
| Provide a **loading indicator** | Users see a brief spinner while the chunk downloads |
| **Do not** defer the initial route | It's always needed — deferring it adds latency without benefit |

## Measuring Impact

```bash
# Build with size analysis
flutter build web --analyze-size

# Output includes:
#   app.dlib.js       — main bundle
#   main.dart.js_N    — deferred chunks (one per deferred import)
```

Compare total bundle sizes before and after to validate the optimisation is
worthwhile for your app.

## When to Use

- App has **≥ 3 feature routes** with non-trivial code
- Initial page load on slow networks is a concern
- You are targeting **mobile web** users (limited bandwidth)

For small apps with only 2–3 screens, the overhead of chunking may outweigh the
benefit. Always measure.
