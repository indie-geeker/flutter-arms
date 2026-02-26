# flutter-arms example

Reference app demonstrating two bootstrap profiles.

## Bootstrap Profiles

### Minimal (default)

- `LoggerModule` (debug level)
- `StorageModule` with `enableSecureStorage: true`

### Full-stack (optional)

Enable via `--dart-define=ARMS_EXAMPLE_FULL_STACK=true`:

- `LoggerModule`
- `StorageModule`
- `CacheModule`
- `NetworkModule(enableCache: true)`

## Run

```bash
cd app/example
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Run full-stack profile:

```bash
cd app/example
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=ARMS_EXAMPLE_FULL_STACK=true
```

## Test

```bash
cd app/example
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Generated files are intentionally not committed in this repository. Keep running
`build_runner` before local analyze/test and in CI.

## Profile Smoke

CI validates both bootstrap profiles with compile-time flags:

```bash
cd app/example
flutter test test/app_bootstrap_env_smoke_test.dart --dart-define=ARMS_EXPECT_FULL_STACK=false
flutter test test/app_bootstrap_env_smoke_test.dart --dart-define=ARMS_EXAMPLE_FULL_STACK=true --dart-define=ARMS_EXPECT_FULL_STACK=true
```
