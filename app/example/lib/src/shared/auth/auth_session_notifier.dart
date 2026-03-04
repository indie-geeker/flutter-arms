import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_session.dart';
import 'auth_status.dart';

part 'auth_session_notifier.g.dart';

/// 全局认证会话状态管理器
///
/// 这是跨 feature 共享的单一认证状态来源（Single Source of Truth）。
///
/// **写入方**：`features/authentication` 在登录/登出后调用本 Notifier
/// **读取方**：其他 feature、路由守卫通过 `ref.watch/read(authSessionNotifierProvider)` 获取
///
/// 使用示例：
/// ```dart
/// // 登录成功后（在 login_notifier 中）
/// ref.read(authSessionNotifierProvider.notifier).setAuthenticated(
///   userId: user.id,
///   username: user.username,
/// );
///
/// // 读取当前认证状态（在任意 feature 中）
/// final session = ref.watch(authSessionNotifierProvider);
/// if (session.isAuthenticated) { ... }
/// ```
@Riverpod(keepAlive: true)
class AuthSessionNotifier extends _$AuthSessionNotifier {
  @override
  AuthSession build() => const AuthSession();

  /// 设置为已认证（登录成功后调用）
  void setAuthenticated({
    required String userId,
    required String username,
  }) {
    state = AuthSession(
      status: AuthStatus.authenticated,
      userId: userId,
      username: username,
    );
  }

  /// 设置为未认证（登出成功或 session 过期后调用）
  void setUnauthenticated() {
    state = const AuthSession(status: AuthStatus.unauthenticated);
  }
}
