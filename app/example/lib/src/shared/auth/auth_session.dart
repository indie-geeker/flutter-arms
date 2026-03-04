import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth_status.dart';

part 'auth_session.freezed.dart';

/// 全局认证会话模型（不可变）
///
/// 存储跨 feature 共享的会话信息，如当前用户标识和认证状态。
/// 由 [AuthSessionNotifier] 管理，其他 feature 通过 watch/read 获取。
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    /// 当前认证状态
    @Default(AuthStatus.unknown) AuthStatus status,

    /// 当前用户 ID（未认证时为 null）
    String? userId,

    /// 当前用户名（未认证时为 null）
    String? username,

    // 若后续接入真实后端 token，在此添加：
    // String? accessToken,
    // DateTime? tokenExpiry,
  }) = _AuthSession;
}

/// 扩展方法
extension AuthSessionX on AuthSession {
  /// 是否已认证
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// 是否处于初始未知状态（应用启动时）
  bool get isUnknown => status == AuthStatus.unknown;
}
