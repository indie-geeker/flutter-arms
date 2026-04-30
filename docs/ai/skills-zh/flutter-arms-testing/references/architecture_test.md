# 架构测试

位置：`test/core/architecture_test.dart`。随 `flutter test` 和 `tool/test.sh` 自动运行。没有 DI、没有 widget —— 只是用 `RegExp` 扫描 `lib/` 下的文件。

## 强制什么（四条规则）

### 规则 1：Domain 不得 import Data 层传输依赖

`lib/features/*/domain/**` 下的文件不得出现以下 import：

- `import 'package:dio/...'`
- `import 'package:hive_ce/...'`
- `import 'package:hive_ce_flutter/...'`
- `import 'package:retrofit/...'`

每处违规在失败消息里形如 `features/<f>/domain/<path> -> package:dio/`。

### 规则 2：Domain/Presentation 不得 import AppException

`lib/features/*/{domain,presentation}/**` 下不得 import：

- `package:flutter_arms/core/error/app_exception.dart`
- `package:flutter_arms/core/error/app_exception_mapper.dart`

匹配用 `RegExp(r"import\s+['\x22]package:flutter_arms/core/error/app_exception(?:_mapper)?\.dart['\x22]")` —— 单引号和双引号两种形式都会被捕获。

### 规则 3：`core/` 不得 import `features/`

`lib/core/**` 下的文件不得 import `package:flutter_arms/features/...`。例外口子：在文件任意位置加一行 `// arch-exempt`（约定写在被豁免 import 的上一行），整个文件就被跳过。

当前合法的豁免：

- `lib/core/network/dio_client.dart` —— 需要 `features/auth/data/datasources/auth_remote_datasource.dart` 给 TokenInterceptor 刷新链用。

### 规则 4：`features/<X>` 不得 import `features/<Y>`

`lib/features/<X>/**` 下的文件不得 import `package:flutter_arms/features/<Y>/...`（`Y != X`）。同样的 `// arch-exempt` 口子可用。

当前合法的豁免：

- `lib/features/home/presentation/pages/profile_page.dart` —— 从 Profile 调 logout，import `AuthNotifier`。
- `lib/features/splash/presentation/pages/splash_page.dart` —— 根据登录状态路由，import `AuthNotifier`。

## 解读失败消息

示例输出：

```
Expected: empty
Actual: ['features/settings/domain/settings.dart -> package:dio/']
```

含义：`lib/features/settings/domain/settings.dart` 里有 `import 'package:dio/...'`，违反规则 1。

修法：要么把需要 `dio` 的类型挪到 `lib/features/settings/data/`，要么在 domain 定义纯 Dart 替身，由 data 映射。

```
Expected: empty
Actual: ['features/post/presentation/post_page.dart -> features/user']
```

含义：规则 4 —— `post/presentation/...` import 了 `features/user/`。要么把共享能力提升到 `core/`（优先），要么在 import 上方加 `// arch-exempt: <理由>`。

## 使用 `// arch-exempt`

格式：

```dart
// arch-exempt: <简短理由>
import 'package:flutter_arms/features/auth/presentation/view_models/auth_notifier.dart';
```

测试寻找的是 `// arch-exempt` 字面子串，文件内任何位置均可。约定写在违规 import 的上一行（理由就近贴着代码）。一份豁免注释就能覆盖整个文件里的所有跨层 import。

**什么时候加豁免：**

- ✅ 认证相关跨层（登录态、token 刷新）。
- ✅ 路由 / 启动接线（core/app 需要访问 feature 入口）。
- ❌ 图方便（我现在不想重构）。
- ❌ 同一文件多次豁免 —— 如果某文件有 3 个以上，设计可能错了，应提升到 `core/`。

每一次豁免都是可读性的成本。用一句像样的理由 justify，而不是 "arch-exempt: needed"。

## 扩展测试

新增一类跨层关切（分析、feature flag 等）时，更新 `architecture_test.dart`：

1. 按现有模式再写一个 `test(...)` 块。
2. 要么全局禁某 import，要么只在指定目录允许。
3. 失败消息保持可操作 —— 含文件路径和违规模式。

示例骨架：

```dart
test('features must not import analytics directly', () {
  final offenders = <String>[];
  final forbidden = RegExp(
    r"import\s+['\x22]package:flutter_arms/core/analytics/",
  );
  for (final feature in featuresDir.listSync().whereType<Directory>()) {
    for (final file in dartFiles(feature)) {
      final content = file.readAsStringSync();
      if (content.contains('// arch-exempt')) continue;
      if (forbidden.hasMatch(content)) {
        offenders.add(rel(file));
      }
    }
  }
  expect(offenders, isEmpty, reason: 'features use AnalyticsPort instead');
});
```

## 调试技巧

- **只跑架构测试**：`flutter test test/core/architecture_test.dart`。
- **是哪条规则挂了？** 失败消息里的 `reason:` 参数会说。
- **哪个文件违规？** 在 `Actual:` 列表里，打开它。
- **修法几乎永远是下列之一：**
  1. 把文件移到正确的层（domain → data，或 features/X → core）。
  2. 把 import 换成一个 domain 纯净替身。
  3. 若跨层确有必要，加 `// arch-exempt: <真实理由>`。

## 避免清单

- "先把测试禁了把 PR 推过去" —— 一旦禁用，约束迅速腐烂。
- 加 `// arch-exempt` 不写真实理由 —— 让未来的自己在扩大豁免前多想一步。
- 为了放过某一处违规去改测试规则 —— 收紧设计，而不是放宽测试。
- 写通过测试但违背精神的代码（比如用 domain 文件 re-export `dio`）。测试是必要条件，不是充分条件；设计仍然重要。
