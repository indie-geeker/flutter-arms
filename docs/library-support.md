# Library Support Matrix (Current)

This matrix tracks **current direct runtime dependencies** used by the template
workspace (core/modules/example). Stale or no-longer-used entries were removed.

| Dependency | Used In | Platform Support | Notes |
| --- | --- | --- | --- |
| `get_it` | `packages/core` | ✅ Android/iOS/macOS/Windows/Linux/Web | Service locator |
| `flutter_riverpod` | `packages/core`, `app/example` | ✅ All Flutter targets | State management |
| `hive` | `packages/modules/module_storage` | ✅ Android/iOS/macOS/Windows/Linux/Web | Key-value storage core |
| `hive_flutter` | `packages/modules/module_storage` | ✅ Android/iOS/macOS/Windows/Linux/Web | Flutter integration for Hive |
| `dio` | `packages/modules/module_network` | ✅ Android/iOS/macOS/Windows/Linux/Web | HTTP client |
| `http_parser` | `packages/modules/module_network` | ✅ All (Dart) | MIME/media type parsing |
| `crypto` | `packages/modules/module_network` | ✅ All (Dart) | Cache key hashing |
| `web` | `packages/modules/module_network` | ✅ Web-only | Web platform interop helpers |
| `auto_route` | `app/example` | ✅ Android/iOS/macOS/Windows/Linux/Web | Router in example app |
| `dartz` | `app/example` | ✅ All (Dart) | Functional result types |
| `intl` | `app/example` | ✅ All (Dart) | Localization/date formatting |

## Notes

- The table intentionally excludes dev-only dependencies (`build_runner`, test frameworks, lints).
- For plugin-specific caveats (permissions, keystore, entitlements), refer to each package's upstream docs.
