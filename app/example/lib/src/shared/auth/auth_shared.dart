/// shared/auth — Cross-feature authentication state layer
///
/// 提供全局认证状态模型和管理器，供多个 feature 或路由守卫共享使用。
///
/// **依赖方向**：features/ → shared/auth → di/ → packages/
library;

export 'auth_status.dart';
export 'auth_session.dart';
export 'auth_session_notifier.dart';
export 'auth_interceptor.dart';
