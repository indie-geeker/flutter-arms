# module_crash

Crash reporting module for the FlutterArms framework — records errors to HTTP endpoints, local files, or both.

## Features

- **`ICrashReporter`** interface in `packages/interfaces`
- **`HttpCrashReporter`** — sends crash data as JSON via `IHttpClient`
- **`FileCrashReporter`** — writes `.txt` crash reports to local storage
- **`CompositeCrashReporter`** — fans out to multiple reporters with isolated failures

## Sentry Integration

Implement `SentryCrashReporter` using the `sentry_flutter` SDK:

```dart
class SentryCrashReporter implements ICrashReporter {
  @override
  Future<void> recordError(dynamic error, {StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    await Sentry.captureException(error, stackTrace: stackTrace);
  }
  // ...
}
```

Use `CompositeCrashReporter` to combine Sentry with custom reporting:

```dart
CrashModule(factory: (locator) => CompositeCrashReporter([
  SentryCrashReporter(),
  HttpCrashReporter(httpClient: locator.get<IHttpClient>(), endpoint: '/api/crashes'),
  FileCrashReporter(),
]))
```

## Usage

```dart
// Default: file reporter
CrashModule()

// Custom: composite with Sentry + HTTP
CrashModule(factory: (locator) => CompositeCrashReporter([...]))
```

> **Note**: `SentryCrashReporter` is not included — implement it with the `sentry_flutter` SDK dependency.
