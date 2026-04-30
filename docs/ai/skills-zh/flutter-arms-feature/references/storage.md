# 存储：KvStorage（Hive + AES）

`lib/core/storage/kv_storage.dart` 定义了 `KvStorage` 接口和 `HiveKvStorage` 实现。它打开两个 box：

- **common box** —— 不加密（主题模式、主色、locale、onboarding 标记、用户 JSON）。
- **secure box** —— AES 加密，32 字节密钥存放在独立的 "key" box 里。

> 注意：cipher key 本身以明文存在磁盘上（为兼容 HarmonyOS 的折中——详见 `docs/ai/SECURITY.md §2.1`）。在上生产前必须改为 `flutter_secure_storage` 或等效的平台方案。

访问始终通过 `ref.read(kvStorageProvider)`，不要直接开 Hive box。

## 现有的类型化方法

| 关切 | 方法 | Box |
|---|---|---|
| Access token | `getAccessToken()` / `saveAccessToken(String)` / `clearTokens()` | secure |
| Refresh token | `getRefreshToken()` / `saveRefreshToken(String)` | secure |
| 用户 JSON | `getUserMap()` / `saveUserMap(Map)` / `clearUser()` | common |
| 主题模式 | `getThemeMode()` / `setThemeMode(String)` | common |
| 主题主色 | `getThemeSeedColor()` / `setThemeSeedColor(Color)` | common |
| Onboarding | `isOnboardingDone()` / `markOnboardingDone()` | common |
| Locale | `getLocale()` / `setLocale(String)` | common |

## 读与写

```dart
final storage = ref.read(kvStorageProvider);
final token = storage.getAccessToken();
await storage.saveAccessToken(newToken);
```

写是异步（`Future<void>`），读是同步。

## 新增持久化键

假如要持久化 `notifyEnabled` 标记。

1. 在 `lib/core/constants/app_constants.dart` 加键常量：

   ```dart
   static const notifyEnabledKey = 'notify_enabled';
   ```

2. 在 `KvStorage` 接口加方法：

   ```dart
   /// 是否启用通知。
   bool isNotifyEnabled();

   /// 设置是否启用通知。
   Future<void> setNotifyEnabled({required bool enabled});
   ```

3. 在 `HiveKvStorage` 用合适的 box 实现：

   ```dart
   @override
   bool isNotifyEnabled() =>
       (_commonBox.get(AppConstants.notifyEnabledKey) as bool?) ?? false;

   @override
   Future<void> setNotifyEnabled({required bool enabled}) async {
     await _commonBox.put(AppConstants.notifyEnabledKey, enabled);
   }
   ```

   非敏感数据用 `_commonBox`，token/PII 用 `_secureBox`。

4. 通过 `ref.read(kvStorageProvider).isNotifyEnabled()` 使用。

## feature 本地数据源

如果 feature 的持久化数据并不只是一个标记，就用 feature 本地数据源包一层 `KvStorage`。镜像 `auth_local_datasource.dart`：

```dart
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '%feature%_local_datasource.g.dart';

/// %Feature% 本地数据源。
class %Feature%LocalDataSource {
  /// 构造函数。
  const %Feature%LocalDataSource(this._storage);

  final KvStorage _storage;

  // 在这里放类型化读/写方法。优先用领域语义命名
  // ("getDraft"、"saveDraft")，而不是泛化的 "getString"。
}

/// %Feature% 本地数据源依赖注入。
@Riverpod(keepAlive: true)
%Feature%LocalDataSource %feature%LocalDataSource(Ref ref) {
  return %Feature%LocalDataSource(ref.read(kvStorageProvider));
}
```

## 存结构化数据

这两个 box 里 Hive 值都是 `dynamic`。约定：

- 原始类型（`String`、`int`、`bool`、`Color` 转 `toARGB32`）→ 直接存。
- Map / list / 对象 → 用 `jsonEncode(...)` 序列化，读取时 `jsonDecode(...)`。参考 `getUserMap`/`saveUserMap`。

本项目**不**注册 Hive TypeAdapter —— 用 JSON 字符串让 schema 升级故事更简单。

## 登出时清理

Auth 的 `clearAuth()` 调 `clearTokens()` + `clearUser()`。如果你的 feature 按用户存敏感数据，加一个 `clear%Feature%()` 方法并在仓库的 logout 钩子里调用（或者订阅 `authProvider` 翻转为 false 时执行）。

## 避免清单

- `shared_preferences` —— 不在依赖里。
- 直接 `Hive.box(...)` —— 绕过接口和加密故事。
- 存裸 Dart 对象 —— 始终序列化为 JSON 或原始类型。
- 把 token 写进 common（未加密）box —— 始终 `_secureBox`。
