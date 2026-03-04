import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_shared.dart';

/// HTTP 请求认证拦截辅助类
///
/// 从全局 [AuthSessionNotifier] 读取认证凭据，供 NetworkModule 配置使用。
/// 目前示例 app 使用本地 mock 认证，无真实 token，此类作为接入真实后端的扩展入口。
///
/// 接入真实 token 后，在 [buildAuthHeaders] 中返回：
/// ```dart
/// return {'Authorization': 'Bearer ${session.accessToken}'};
/// ```
class AuthInterceptor {
  final Ref _ref;

  const AuthInterceptor(this._ref);

  /// 返回当前请求所需的认证头
  ///
  /// 若未认证，返回 null（调用方可选择是否继续请求）
  Map<String, String>? buildAuthHeaders() {
    final session = _ref.read(authSessionProvider);
    if (!session.isAuthenticated) return null;

    // TODO(auth): 接入真实 token 后取消注释：
    // return {'Authorization': 'Bearer ${session.accessToken}'};
    return null;
  }

  /// 当前是否已认证
  bool get isAuthenticated =>
      _ref.read(authSessionProvider).isAuthenticated;
}
