/// 业务失败基类。
sealed class Failure {
  /// 构造函数。
  const Failure(this.message);

  /// 错误信息。
  final String message;
}

/// 网络失败。
class NetworkFailure extends Failure {
  /// 构造函数。
  const NetworkFailure(super.message);
}

/// 认证失败。
class AuthFailure extends Failure {
  /// 构造函数。
  const AuthFailure(super.message);
}

/// 未知失败。
class UnknownFailure extends Failure {
  /// 构造函数。
  const UnknownFailure(super.message);
}
