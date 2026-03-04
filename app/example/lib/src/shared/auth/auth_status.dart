/// 全局认证状态枚举
enum AuthStatus {
  /// 初始未知状态（应用启动时）
  unknown,

  /// 已认证
  authenticated,

  /// 未认证（已登出或从未登录）
  unauthenticated,
}
