/// 服务器异常
class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);
}

/// 缓存异常
class CacheException implements Exception {
  final String? message;
  CacheException([this.message]);
}

/// 网络异常
class NetworkException implements Exception {
  final String? message;
  NetworkException([this.message]);
}

/// 未授权异常
class UnauthorizedException implements Exception {
  final String? message;
  UnauthorizedException([this.message]);
}

/// 输入验证异常
class ValidationException implements Exception {
  final String? message;
  ValidationException([this.message]);
}


