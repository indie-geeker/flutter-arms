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

`lib/core/**` 下的文件**禁止** import 任何 `lib/features/` 的东西。如果 `core` 真的需要跨切面能力，优先在 `core/` 定义端口，让 feature 在 app composition 层覆盖实现。例如 token 刷新现在走 `core/auth/AuthTokenRefresher` 端口，而不是让 `core/network` 直接 import auth datasource。

确有必要豁免时，在 import 正上方加一行注释：

```dart
// arch-exempt: Profile owns the logout entry point for auth UI state.
import 'package:flutter_arms/features/auth/presentation/view_models/auth_notifier.dart';
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

auth 的跨切面端口已经提升到 `core/auth/`。如果新的 feature 需要被 core 消费，先考虑同样的端口化，而不是增加 `arch-exempt`。

## 规则 5：ApiClient adapter 不得 import 具体 Dio provider

`lib/features/*/data/datasources/api_client_*_remote_datasource.dart` 只允许依赖应用级 `ApiClient` / `ApiRequest` 和本 feature 的纯接口/模型。不要 import `core/network/dio_api_client.dart`。

如果需要 provider 接线，把它放到单独的 datasource provider 文件里：

```dart
import 'package:flutter_arms/core/network/dio_api_client.dart';
import 'package:flutter_arms/features/post/data/datasources/api_client_post_remote_datasource.dart';

@Riverpod(keepAlive: true)
PostRemoteDataSource postApiClientRemoteDataSource(Ref ref) {
  return ApiClientPostRemoteDataSource(ref.read(apiClientProvider));
}
```

这样 ApiClient adapter 仍然是可替换网络库的对照写法。

## 规则 6：Repository / Application 不得调用 `.asApi()`

`.asApi()` 是 Retrofit DataSource adapter 的职责。Repository 和 application service 只依赖纯接口，并只在 `on AppException catch` 处处理已经规范化的异常。

失败消息里如果出现 `features/auth/data/repositories/auth_repository_impl.dart` 或 `features/auth/application/auth_token_refresher_impl.dart`，说明传输层细节又漏回了上层。

## 扩展架构测试

引入新的跨层关切（例如 analytics、feature flag）时，更新 `test/core/architecture_test.dart` 新增一条规则，或显式白名单新模式。不要用几十处 `arch-exempt` 绕开。
