import 'package:auto_route/auto_route.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        // Splash 路由
        AutoRoute(
          path: '/',
          page: SplashRoute.page,
          initial: true,
        ),
        
        // 主页路由
        AutoRoute(
          path: '/home',
          page: HomeRoute.page,
        ),
        
        // 可以添加更多路由
        // AutoRoute(
        //   path: '/profile',
        //   page: ProfileRoute.page,
        // ),
        
        // 嵌套路由示例
        // AutoRoute(
        //   path: '/settings',
        //   page: SettingsRoute.page,
        //   children: [
        //     AutoRoute(
        //       path: 'account',
        //       page: AccountSettingsRoute.page,
        //     ),
        //     AutoRoute(
        //       path: 'appearance',
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