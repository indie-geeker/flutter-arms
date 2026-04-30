# Storage: KvStorage (Hive + AES)

`lib/core/storage/kv_storage.dart` defines the `KvStorage` interface and `HiveKvStorage` implementation. It opens two boxes:

- **common box** — unencrypted (theme mode, seed color, locale, onboarding flag, user JSON).
- **secure box** — AES-encrypted via a 32-byte key stored in a separate "key" box.

> Note: the cipher key itself is stored in plaintext on disk (a HarmonyOS-compat tradeoff — see `docs/ai/SECURITY.md` §2.1). This must be revisited before prod with `flutter_secure_storage` or platform-specific equivalent.

Access is always via `ref.read(kvStorageProvider)`, never by opening Hive boxes directly.

## Existing typed methods

| Concern | Methods | Box |
|---|---|---|
| Access token | `getAccessToken()` / `saveAccessToken(String)` / `clearTokens()` | secure |
| Refresh token | `getRefreshToken()` / `saveRefreshToken(String)` | secure |
| User JSON | `getUserMap()` / `saveUserMap(Map)` / `clearUser()` | common |
| Theme mode | `getThemeMode()` / `setThemeMode(String)` | common |
| Theme seed color | `getThemeSeedColor()` / `setThemeSeedColor(Color)` | common |
| Onboarding | `isOnboardingDone()` / `markOnboardingDone()` | common |
| Locale | `getLocale()` / `setLocale(String)` | common |

## Reading and writing

```dart
final storage = ref.read(kvStorageProvider);
final token = storage.getAccessToken();
await storage.saveAccessToken(newToken);
```

Writes are async (`Future<void>`); reads are sync.

## Adding a new persistent key

Say you want to persist a `notifyEnabled` flag.

1. Add the key constant to `lib/core/constants/app_constants.dart`:

   ```dart
   static const notifyEnabledKey = 'notify_enabled';
   ```

2. Add methods to the `KvStorage` interface:

   ```dart
   /// 是否启用通知。
   bool isNotifyEnabled();

   /// 设置是否启用通知。
   Future<void> setNotifyEnabled({required bool enabled});
   ```

3. Implement in `HiveKvStorage` using the appropriate box:

   ```dart
   @override
   bool isNotifyEnabled() =>
       (_commonBox.get(AppConstants.notifyEnabledKey) as bool?) ?? false;

   @override
   Future<void> setNotifyEnabled({required bool enabled}) async {
     await _commonBox.put(AppConstants.notifyEnabledKey, enabled);
   }
   ```

   Use `_commonBox` for non-sensitive data, `_secureBox` for tokens/PII.

4. Consume via `ref.read(kvStorageProvider).isNotifyEnabled()`.

## Feature-local datasource

If a feature's persistent data is non-trivial (not just one flag), wrap `KvStorage` in a feature-local datasource. Mirror `auth_local_datasource.dart`:

```dart
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '%feature%_local_datasource.g.dart';

/// %Feature% 本地数据源。
class %Feature%LocalDataSource {
  /// 构造函数。
  const %Feature%LocalDataSource(this._storage);

  final KvStorage _storage;

  // Typed read/write methods go here. Prefer domain-friendly names
  // ("getDraft", "saveDraft") over generic "getString".
}

/// %Feature% 本地数据源依赖注入。
@Riverpod(keepAlive: true)
%Feature%LocalDataSource %feature%LocalDataSource(Ref ref) {
  return %Feature%LocalDataSource(ref.read(kvStorageProvider));
}
```

## Storing structured data

Hive values in these boxes are `dynamic`. Convention:

- Primitives (`String`, `int`, `bool`, `Color` via `toARGB32`) → stored directly.
- Maps / lists / objects → serialize with `jsonEncode(...)`, decode with `jsonDecode(...)` on read. See `getUserMap`/`saveUserMap` for the canonical pattern.

Do NOT register Hive TypeAdapters in this project — we stick with JSON strings to keep the schema upgrade story simple.

## Clearing on logout

Auth's `clearAuth()` calls `clearTokens()` + `clearUser()`. If your feature stores sensitive data per-user, add a `clear%Feature%()` method and call it from the repository's logout hook (or register it to run when `authProvider` flips to false).

## What to AVOID

- `shared_preferences` — not on the dependency list.
- Direct `Hive.box(...)` — bypasses the interface and the encryption story.
- Storing raw `Dart` objects — always serialize to JSON or primitives.
- Writing tokens to the common (unencrypted) box — always `_secureBox`.
