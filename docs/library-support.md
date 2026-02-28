# Library Support Matrix (Current)

This matrix tracks direct dependencies across all workspace modules
(`packages/*`, `packages/modules/*`, `app/example`), excluding `dev_dependencies`.
It also separates "declared in pubspec" from "currently imported in source".

## Module Dependency Overview

| Module | Local Workspace Dependencies | External Runtime Dependencies |
| --- | --- | --- |
| `packages/interfaces` | - | - |
| `packages/core` | `interfaces` | `get_it`, `flutter_riverpod` |
| `packages/modules/module_logger` | `interfaces` | - |
| `packages/modules/module_cache` | `interfaces` | - |
| `packages/modules/module_network` | `interfaces` | `dio`, `http_parser`, `crypto`, `web` |
| `packages/modules/module_storage` | `interfaces` | `hive`, `hive_flutter`, `flutter_secure_storage` |
| `app/example` | `core`, `interfaces`, `module_storage`, `module_logger`, `module_cache`, `module_network` | `intl`, `flutter_riverpod`, `riverpod_annotation`, `auto_route`, `freezed_annotation`, `json_annotation`, `dartz`, `cupertino_icons` |

## External Library Support Matrix

| Library | Version (Constraint) | Declared In | Imported In Source | Platform Support | Notes |
| --- | --- | --- | --- | --- | --- |
| `get_it` | `^9.2.1` | `packages/core` | `packages/core` | ✅ All (Dart/Flutter) | DI/service locator |
| `flutter_riverpod` | `^3.1.0` | `packages/core`, `app/example` | `packages/core`, `app/example` | ✅ All Flutter targets | State management |
| `dio` | `^5.9.1` | `packages/modules/module_network` | `packages/modules/module_network` | ✅ Android/iOS/macOS/Windows/Linux/Web | HTTP client |
| `http_parser` | `^4.1.2` | `packages/modules/module_network` | `packages/modules/module_network` | ✅ All (Dart) | MIME/media type parsing |
| `crypto` | `^3.0.7` | `packages/modules/module_network` | `packages/modules/module_network` | ✅ All (Dart) | Request/cache hash helpers |
| `web` | `^1.1.1` | `packages/modules/module_network` | `packages/modules/module_network` | ✅ Web-focused | Used in web implementation file only |
| `hive` | `^2.2.3` | `packages/modules/module_storage` | Via `hive_flutter` APIs in module storage | ✅ Android/iOS/macOS/Windows/Linux/Web | Key-value storage core |
| `hive_flutter` | `^1.1.0` | `packages/modules/module_storage` | `packages/modules/module_storage` | ✅ Android/iOS/macOS/Windows/Linux/Web | Flutter integration for Hive |
| `flutter_secure_storage` | `^10.0.0` | `packages/modules/module_storage` | `packages/modules/module_storage` | ✅ Android/iOS/macOS/Windows/Linux/Web | Secure key-value storage plugin |
| `intl` | `^0.20.2` | `app/example` | `app/example` | ✅ All (Dart/Flutter) | l10n/date formatting |
| `riverpod_annotation` | `^4.0.0` | `app/example` | `app/example` | ✅ All (Dart/Flutter) | Annotation package for codegen |
| `auto_route` | `^11.1.0` | `app/example` | `app/example` | ✅ All Flutter targets | Router |
| `freezed_annotation` | `^3.1.0` | `app/example` | `app/example` | ✅ All (Dart/Flutter) | Immutable model annotations |
| `dartz` | `^0.10.1` | `app/example` | `app/example` | ✅ All (Dart) | Functional types (`Either`, etc.) |
| `json_annotation` | `^4.9.0` | `app/example` | ⚠️ No direct import found | ✅ All (Dart/Flutter) | Kept for JSON codegen compatibility |
| `cupertino_icons` | `^1.0.8` | `app/example` | ⚠️ No direct usage found | ✅ All Flutter targets | Optional icon font package |

## Notes

- This document excludes `dev_dependencies` (`build_runner`, generators, lint packages, test-only packages).
- `flutter`, `flutter_test`, `flutter_localizations` are SDK dependencies and are not listed as third-party libraries.
- "Imported In Source" was verified from current `app/**` and `packages/**` Dart imports.
