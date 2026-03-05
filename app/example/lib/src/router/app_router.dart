import 'package:auto_route/auto_route.dart';
import 'package:example/src/features/authentication/authentication.dart';
import 'package:example/src/features/network_demo/network_demo.dart';
import 'package:example/src/features/settings/settings.dart';

// Web optimization: To enable deferred loading for route-level code splitting,
// replace the eager imports above with deferred imports:
//
//   import 'package:example/src/features/settings/settings.dart'
//       deferred as settings;
//   import 'package:example/src/features/network_demo/network_demo.dart'
//       deferred as network_demo;
//
// Then run: dart run build_runner build --delete-conflicting-outputs
// auto_route will generate async loaders automatically.
// See docs/advanced/web-optimization.md for details.
import 'package:example/src/shared/auth/auth_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_router.gr.dart';

/// Authentication route guard.
///
/// Protects routes that require authentication.
/// Redirects unauthenticated users to the login page.
class AuthGuard extends AutoRouteGuard {
  final Ref _ref;

  AuthGuard(this._ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final session = _ref.read(authSessionProvider);

    if (session.isAuthenticated) {
      // Authenticated, allow access.
      resolver.next(true);
    } else if (session.isUnknown) {
      // Session not yet restored (app just started), allow and let LoginScreen handle.
      resolver.next(true);
    } else {
      // Unauthenticated, redirect to login.
      router.push(const LoginRoute());
    }
  }
}

/// Application routing configuration.
///
/// Uses auto_route for navigation management.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final Ref? _ref;

  AppRouter([this._ref]);

  @override
  List<AutoRoute> get routes => [
        /// Login page (initial route, no guard needed).
        AutoRoute(page: LoginRoute.page, path: '/', initial: true),

        /// Home page (protected by auth guard).
        AutoRoute(
          page: HomeRoute.page,
          path: '/home-route',
          guards: [if (_ref != null) AuthGuard(_ref)],
        ),

        /// Settings screen.
        AutoRoute(page: SettingsRoute.page, path: '/settings'),

        /// Network demo page.
        AutoRoute(page: NetworkDemoRoute.page, path: '/network-demo'),
      ];
}
