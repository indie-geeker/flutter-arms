# flutter-arms example

Reference app demonstrating the framework's default bootstrap path.

## What It Initializes

- `LoggerModule` (debug level)
- `StorageModule` with `enableSecureStorage: true`

The cache and network modules are available in the workspace but are not enabled by default in this demo app.

## Run

```bash
cd app/example
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Test

```bash
cd app/example
flutter test
```
