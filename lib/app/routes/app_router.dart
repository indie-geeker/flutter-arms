import 'package:auto_route/auto_route.dart';

import '../../features/authorization/presentation/screen/auth_screen.dart';
import '../../features/home/presentation/screen/home_screen.dart';
import '../../features/splash/presentation/screen/splash_screen.dart';
import 'app_routes.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        // Splash 路由
        AutoRoute(
          path: AppRoutes.splash,
          page: SplashRoute.page,
          initial: true,
        ),

        // 认证路由
        AutoRoute(
          path: AppRoutes.auth,
          page: AuthRoute.page,
        ),

        // 主页路由
        AutoRoute(
          path: AppRoutes.home,
          page: HomeRoute.page,
        ),

        // 可以添加更多路由
        // AutoRoute(
        //   path: AppRoutes.profile,
        //   page: ProfileRoute.page,
        // ),

        // 嵌套路由示例
        // AutoRoute(
        //   path: AppRoutes.settings,
        //   page: SettingsRoute.page,
        //   children: [
        //     AutoRoute(
        //       path: 'account', // 相对路径，完整路径是 /settings/account
        //       page: AccountSettingsRoute.page,
        //     ),
        //     AutoRoute(
        //       path: 'appearance', // 相对路径，完整路径是 /settings/appearance
        //       page: AppearanceSettingsRoute.page,
        //     ),
        //   ],
        // ),
      ];
}

// 空路由页面 - 用于重定向
@RoutePage()
class EmptyRouterPage extends AutoRouter {
  const EmptyRouterPage({super.key});
}

final appRouter = AppRouter();
