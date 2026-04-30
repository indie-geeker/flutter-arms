# Routing: AutoRoute patterns

## Declaring a page

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

Use `ConsumerWidget` (and take `(context, ref)`) if the page reads Riverpod state. After adding `@RoutePage()`, run `tool/gen.sh` — the AutoRoute generator creates `%Feature%Route` inside `lib/app/app_router.gr.dart`.

## Registering the route

Edit `lib/app/app_router.dart`, add to the `routes` list:

```dart
AutoRoute(page: %Feature%Route.page),
```

For guarded routes:

```dart
AutoRoute(
  page: %Feature%Route.page,
  guards: <AutoRouteGuard>[_authGuard],
),
```

For nested (tab / shell) routes — see how `HomeRoute` wraps `Feed/Explore/Profile`:

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

## Passing data between pages

Use typed constructor args — AutoRoute's generator produces the matching route with those params:

```dart
@RoutePage()
class DetailPage extends StatelessWidget {
  const DetailPage({required this.id, super.key});
  final String id;
  // ...
}

// Navigation:
context.router.push(DetailRoute(id: 'abc123'));
```

For complex payloads, pass them through the page constructor (NOT `extras` if types matter). AutoRoute handles code generation for the route class automatically.

## Navigation calls

```dart
context.router.push(const %Feature%Route());          // push onto stack
context.router.replace(const %Feature%Route());       // replace current
context.router.replaceAll([const HomeRoute()]);        // reset stack
context.router.maybePop();                             // pop if possible
context.router.popUntilRoot();                         // back to root
```

Use `context.router`, not `Navigator.of(context)`, for top-level nav.

## Redirect-on-auth pattern

`AuthGuard` (in `app_router.dart`) reads `authProvider`:

- If authed → `resolver.next(true)`.
- If not → `resolver.redirectUntil(const LoginRoute())`.

The router listens to auth changes via `AuthListenable` — a `ChangeNotifier` wrapping `ref.listenManual<bool>(authProvider, …)`. When the bool flips, `MaterialApp.router`'s `reevaluateListenable` re-runs all guards. So logging out from any page auto-redirects to `LoginRoute`.

To protect a new page, just add the `authGuard` to its `AutoRoute(guards: [...])`. No extra wiring needed.

## Writing your own guard

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

If the guard depends on Riverpod state that can change at runtime, register a `Listenable` against the relevant provider and pass it to `MaterialApp.router`'s `reevaluateListenable` (see `AuthListenable`).

## Where `MaterialApp.router` is configured

In `lib/app/app.dart`. The `AppRouter` is constructed once with a `WidgetRef` so guards can read providers. `reevaluateListenable` points to `router.authListenable`.

## What to AVOID

- `Navigator.of(context).push(MaterialPageRoute(...))` for top-level navigation. Reserve it for local dialogs/modals or special cases (e.g. opening the Talker screen from Profile is an intentional local nav).
- GoRouter / raw Navigator 2.0 APIs. This project is AutoRoute-only.
- Hardcoding string paths — always use the generated `%Feature%Route` class.
- Creating a new `AppRouter` instance manually — it's a `ChangeNotifier`-backed singleton wired up in `bootstrap.dart`.
