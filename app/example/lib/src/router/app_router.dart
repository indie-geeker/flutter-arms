import 'package:auto_route/auto_route.dart';
import 'package:example/src/features/authentication/authentication.dart';
import 'package:example/src/features/network_demo/network_demo.dart';
import 'package:example/src/features/settings/settings.dart';
import 'package:example/src/shared/auth/auth_shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_router.gr.dart';

/// 认证路由守卫
///
/// 保护需要登录才能访问的路由。
/// 未认证用户访问受保护页面时，自动重定向至登录页。
class AuthGuard extends AutoRouteGuard {
  final Ref _ref;

  AuthGuard(this._ref);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final session = _ref.read(authSessionProvider);

    if (session.isAuthenticated) {
      // 已认证，放行
      resolver.next(true);
    } else if (session.isUnknown) {
      // session 尚未恢复（应用刚启动），放行并依赖 LoginScreen 处理
      resolver.next(true);
    } else {
      // 未认证，重定向到登录页
      router.push(const LoginRoute());
    }
  }
}

/// 应用路由配置
///
/// 使用 auto_route 管理应用导航
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final Ref? _ref;

  AppRouter([this._ref]);

  @override
  List<AutoRoute> get routes => [
        /// 登录页面（初始路由，无须守卫）
        AutoRoute(page: LoginRoute.page, path: '/', initial: true),

        /// 主页（受认证守卫保护）
        AutoRoute(
          page: HomeRoute.page,
          path: '/home-route',
          guards: [if (_ref != null) AuthGuard(_ref)],
        ),

        /// 设置页面
        AutoRoute(page: SettingsRoute.page, path: '/settings'),

        /// 网络演示页面
        AutoRoute(page: NetworkDemoRoute.page, path: '/network-demo'),
      ];
}
