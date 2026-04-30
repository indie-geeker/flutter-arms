# 路由：AutoRoute 模式

## 声明一个页面

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// %Feature% 页。
@RoutePage()
class %Feature%Page extends StatelessWidget {
  /// 构造函数。
  const %Feature%Page({super.key});

  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

若要读 Riverpod 状态，用 `ConsumerWidget`（签名变成 `(context, ref)`）。加了 `@RoutePage()` 后跑 `tool/gen.sh` —— AutoRoute 生成器会在 `lib/app/app_router.gr.dart` 里生成 `%Feature%Route`。

## 注册路由

编辑 `lib/app/app_router.dart`，往 `routes` 列表里加：

```dart
AutoRoute(page: %Feature%Route.page),
```

需要 guard：

```dart
AutoRoute(
  page: %Feature%Route.page,
  guards: <AutoRouteGuard>[_authGuard],
),
```

嵌套路由（tab/shell）—— 参考 `HomeRoute` 包装 `Feed/Explore/Profile` 的写法：

```dart
AutoRoute(
  page: HomeRoute.page,
  guards: <AutoRouteGuard>[_authGuard],
  children: <AutoRoute>[
    AutoRoute(page: FeedRoute.page, initial: true),
    AutoRoute(page: ExploreRoute.page),
    AutoRoute(page: ProfileRoute.page),
  ],
),
```

## 页面间传值

用构造器参数——AutoRoute 生成器会生成带同样参数的路由类：

```dart
@RoutePage()
class DetailPage extends StatelessWidget {
  const DetailPage({required this.id, super.key});
  final String id;
  // ...
}

// 导航：
context.router.push(DetailRoute(id: 'abc123'));
```

复杂 payload 走构造器（不要用 `extras` —— 类型会丢）。AutoRoute 会为路由类自动生成代码。

## 导航调用

```dart
context.router.push(const %Feature%Route());          // 推入栈
context.router.replace(const %Feature%Route());       // 替换当前
context.router.replaceAll([const HomeRoute()]);        // 清栈重置
context.router.maybePop();                             // 可 pop 则 pop
context.router.popUntilRoot();                         // 回到根
```

顶层导航用 `context.router`，不用 `Navigator.of(context)`。

## 登录态联动路由

`AuthGuard`（在 `app_router.dart`）读 `authProvider`：

- 已登录 → `resolver.next(true)`。
- 未登录 → `resolver.redirectUntil(const LoginRoute())`。

路由通过 `AuthListenable`（一个 `ChangeNotifier`，包装 `ref.listenManual<bool>(authProvider, …)`）监听登录态变化。bool 翻转时，`MaterialApp.router` 的 `reevaluateListenable` 会重新评估所有 guard。因此从任何页面 logout 都会自动跳回 `LoginRoute`。

保护新页面只需在它的 `AutoRoute(guards: [...])` 加 `authGuard`。没有其它接线。

## 自定义 guard

```dart
class FeatureFlagGuard extends AutoRouteGuard {
  FeatureFlagGuard(this.ref);
  final WidgetRef ref;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final enabled = ref.read(featureFlagProvider).betaUi;
    if (enabled) {
      resolver.next(true);
      return;
    }
    resolver.next(false);
  }
}
```

如果 guard 依赖运行时可能变化的 Riverpod 状态，为相关 provider 注册一个 `Listenable` 并作为 `MaterialApp.router` 的 `reevaluateListenable`（参考 `AuthListenable`）。

## `MaterialApp.router` 配置位置

在 `lib/app/app.dart`。`AppRouter` 带一个 `WidgetRef` 一次性构造，好让 guard 能读 provider。`reevaluateListenable` 指向 `router.authListenable`。

## 避免清单

- 顶层导航用 `Navigator.of(context).push(MaterialPageRoute(...))`。只在本地对话框/弹层或特殊情形（例如 Profile 打开 Talker 屏幕是有意的本地导航）保留。
- GoRouter / 原生 Navigator 2.0 API。本项目仅用 AutoRoute。
- 硬编码字符串路径——始终用生成的 `%Feature%Route` 类。
- 手动 new 一个 `AppRouter` —— 它是由 `bootstrap.dart` 接线、`ChangeNotifier` 支撑的单例。
