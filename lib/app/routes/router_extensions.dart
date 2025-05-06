import 'app_router.dart';


/// 全局路由扩展方法
/// 
/// 不需要 BuildContext 的导航方法，可以在任何地方使用
extension GlobalRouterExtensions on AppRouter {
  /// 导航到首页
  Future<void> navigateToHome() {
    return navigate(const HomeRoute());
  }
  
  /// 导航到认证页面
  Future<void> navigateToAuth() {
    return navigate(const AuthRoute());
  }
  
  /// 导航到启动页面
  Future<void> navigateToSplash() {
    return navigate(const SplashRoute());
  }
  
  /// 替换当前路由为首页
  Future<void> replaceWithHome() {
    return replace(const HomeRoute());
  }
  
  /// 替换当前路由为认证页面
  Future<void> replaceWithAuth() {
    return replace(const AuthRoute());
  }
  
  /// 替换当前路由为启动页面
  Future<void> replaceWithSplash() {
    return replace(const SplashRoute());
  }
}
