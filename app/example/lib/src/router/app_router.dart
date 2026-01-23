import 'package:auto_route/auto_route.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/settings_screen.dart';

part 'app_router.gr.dart';

/// 应用路由配置
///
/// 使用 auto_route 管理应用导航
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    /// 登录页面（初始路由）
    AutoRoute(page: LoginRoute.page, initial: true),

    /// 主页
    AutoRoute(page: HomeRoute.page),

    /// 设置页面
    AutoRoute(page: SettingsRoute.page),
  ];
}
