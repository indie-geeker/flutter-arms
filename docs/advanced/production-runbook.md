# Production Operations Runbook

This runbook defines a baseline operational standard for `flutter-arms` deployments.
It focuses on environment consistency, module composition, runtime safety, and incident handling.

## 1. Deployment Baseline

- Flutter SDK: `3.35.6` (aligned with `.fvmrc` and CI)
- Dart SDK: `^3.9.2`
- Workspace bootstrapping: `melos bootstrap`
- Codegen (example app):
  - `cd app/example`
  - `dart run build_runner build --delete-conflicting-outputs`

## 2. Module Composition Matrix

| Environment | Required Modules | Optional Modules | Notes |
|---|---|---|---|
| Local Dev | `LoggerModule`, `StorageModule` | `CacheModule`, `NetworkModule` | Use verbose logs; permissive timeouts |
| CI | `LoggerModule`, `StorageModule`, `CacheModule`, `NetworkModule` | - | Must pass analyze/test/coverage gate |
| Staging | `LoggerModule`, `StorageModule`, `CacheModule`, `NetworkModule` | - | Mirror production config, lower traffic |
| Production | `LoggerModule`, `StorageModule`, `CacheModule`, `NetworkModule` | - | Disable debug-only behavior |

## 3. Recommended Config Matrix

| Domain | Dev | Staging | Production |
|---|---|---|---|
| Logger level | `debug` | `info` | `info` or `warning` |
| Network logging | Enabled | Enabled (redaction mandatory) | Enabled only when needed |
| Cache policy default | `cacheFirst` or `normal` | `normal` | `normal` |
| Network timeouts | relaxed | moderate | strict + retry policy |
| Proxy config | Optional | Optional | Optional (environment-dependent) |

## 4. Pre-Release Verification Checklist

Run in repository root:

```bash
melos bootstrap
cd app/example
dart run build_runner build --delete-conflicting-outputs
cd ../..
melos run analyze
melos run test:coverage
scripts/check_coverage.sh
```

Release only when all commands pass.

## 5. Incident Triage

### 5.1 Network Failures

1. Check whether `NetworkModule` is initialized and `baseUrl` is correct.
2. Validate timeout/retry settings (`connectTimeout`, `receiveTimeout`, `sendTimeout`, `retryConfig`).
3. If `networkFirst` cache policy is used, verify fallback cache behavior from logs.
4. If proxy is configured, confirm runtime platform supports IO proxy adapter.

### 5.2 Cache Consistency Issues

1. Confirm cache key generation inputs (`url + query`).
2. Verify request-level `NetworkCacheOptions` (`enabled`, `policy`, `duration`).
3. Check whether response payload is JSON-serializable for cache persistence.

### 5.3 Logging/Observability Issues

1. Confirm `LoggerModule` initialization level and outputs.
2. Verify redaction behavior for sensitive headers/data.
3. Confirm `extras` is propagated for structured logs.

## 6. Operational Guardrails

- Do not commit generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`).
- Keep CI and local Flutter versions aligned.
- Treat coverage gate failures as release blockers.
- Raise thresholds incrementally after each quality improvement cycle.

## 7. Suggested Threshold Ramp-Up Plan

Current CI baseline (enforced):

- Total coverage: `>=60%`
- Per-package coverage: `>=50%`

Recommended tightening path:

1. Stage B: total `65%`, package `55%`
2. Stage C: total `70%`, package `60%`

Advance to next stage only after two consecutive green CI runs.
