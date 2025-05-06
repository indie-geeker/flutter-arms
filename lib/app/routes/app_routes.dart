/// 应用路由路径常量
/// 
/// 集中管理所有路由路径，方便在代码中引用
class AppRoutes {
  // 私有构造函数，防止实例化
  AppRoutes._();
  
  // 基础路由
  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';

  
  // 嵌套路由示例
  // static const String settingsAccount = '/settings/account';
  // static const String settingsAppearance = '/settings/appearance';
}
