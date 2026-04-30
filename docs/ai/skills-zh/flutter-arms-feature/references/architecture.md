# 架构规则

以下任何一条被违反，`test/core/architecture_test.dart` 就会失败。把失败消息当作"扫描器发现了什么"来读，然后在源头修。

## 规则 1：Domain 不得 import Data 层传输依赖

`lib/features/<any>/domain/**` 下的文件**禁止**含有：

- `import 'package:dio/…'`
- `import 'package:hive_ce/…'` 或 `hive_ce_flutter`
- `import 'package:retrofit/…'`

保持 domain 为纯 Dart。如果你觉得 domain 需要其中某种类型，那说明分层错了——在 domain 定义接口，在 data 实现。

## 规则 2：Domain/Presentation 不得 import AppException

`lib/features/<any>/{domain,presentation}/**` 下的文件**禁止** import：

- `package:flutter_arms/core/error/app_exception.dart`
- `package:flutter_arms/core/error/app_exception_mapper.dart`

Domain 与 Presentation 只认 `Failure` + `FailureCode`。Repository 实现是唯一同时见到两种类型的地方——`AppException` 从 data source 进来，`Failure` 从这里出去到 domain。

## 规则 3：`core/` 不得 import `features/`

`lib/core/**` 下的文件**禁止** import 任何 `lib/features/` 的东西。如果 `core` 真的需要（auth 是典型场景），在 import 正上方加一行注释：

```dart
// arch-exempt: TokenInterceptor needs auth's refresh datasource to rotate tokens.
import 'package:flutter_arms/features/auth/data/datasources/auth_remote_datasource.dart';
```

注释要说明跨层理由。不要把 `arch-exempt` 当通用逃生口——如果一个文件有 3+ 处豁免，请把依赖提升到 `core/`。

## 规则 4：`features/<X>` 不得 import `features/<Y>`

在 `lib/features/` 内部，每个 feature 相互隔离。跨 feature import 会让测试失败。同样的 `// arch-exempt:` 规则适用。当前白名单仅限 auth：

- `features/home/presentation/pages/profile_page.dart` → `auth_notifier.dart`（Profile 里 logout）
- `features/splash/presentation/pages/splash_page.dart` → `auth_notifier.dart`（按登录态决定路由）

## 如何解读失败消息

```
Expected: empty
Actual: ['features/settings/domain/settings.dart -> package:dio/']
```

意思是 `features/settings/domain/settings.dart` import 了 `package:dio/...`，这是禁止的。要么把该类型挪到 `data/`，要么在 domain 定义纯 Dart 替身。

```
Expected: empty
Actual: ['features/profile/presentation/profile_page.dart -> features/auth']
```

意思是跨 feature import。要么把共享能力提升到 `core/`，要么在 import 上方加 `// arch-exempt: <真实理由>`。

## 什么时候提升到 `core/`

当同一能力被 2+ 个 feature 消费时提升。候选：

- 跨 feature 工具（日期格式化、String 扩展——已在 `core/extensions/`）。
- 共享 DI provider（logger、storage、dio client——已在 `core/{logger,storage,network}/`）。
- 跨层关切（错误模型、Result、主题——已在 `core/{error,result,theme}/`）。

auth 本身如果 arch-exempt 越来越多，可以提升到 `core/auth/`。目前是 3 处，都有记录。

## 扩展架构测试

引入新的跨层关切（例如 analytics、feature flag）时，更新 `test/core/architecture_test.dart` 新增一条规则，或显式白名单新模式。不要用几十处 `arch-exempt` 绕开。
