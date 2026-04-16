/// 应用异常基类。
class AppException implements Exception {
  /// 构造函数。
  const AppException(this.message);

  /// 异常描述。
  final String message;

  @override
  String toString() => 'AppException(message: $message)';
}

/// 网络异常。
class NetworkException extends AppException {
  /// 构造函数。
  const NetworkException(super.message);
}

/// 认证异常。
class AuthException extends AppException {
  /// 构造函数。
  const AuthException(super.message);
}
