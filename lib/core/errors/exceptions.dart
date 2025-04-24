
abstract class AppException implements Exception{
  final String message;
  final int? code;
  final dynamic details;
  AppException({
    required this.message,
    this.code,
    this.details
});
}

/// 缓存异常
class CacheException extends AppException {
  CacheException({
    required super.message,
    super.code,
    super.details
});
}

/// 网络异常
class NetworkException extends AppException {
  final int? statusCode;
  NetworkException({
    required super.message,
    super.code,
    super.details,
    this.statusCode
});
}

/// 未授权异常
class UnauthorizedException extends AppException {
  UnauthorizedException({
    required super.message,
    super.code,
    super.details
});
}

/// 访问被拒绝异常
class ForbiddenException extends AppException {
  ForbiddenException({
    required super.message,
    super.code,
    super.details
});
}


/// 超时异常
class TimeoutException extends AppException {
  TimeoutException({
    required super.message,
    super.code,
    super.details
});
}

/// 解析异常
class ParseException extends AppException {
  ParseException({
    required super.message,
    super.code,
    super.details
});
}

/// 服务器异常
class ServerException extends AppException {
  ServerException({
    required super.message,
    super.code,
    super.details
});
}

/// 数据库异常
class DatabaseException extends AppException {
  DatabaseException({
    required super.message,
    super.code,
    super.details
});
}

/// 服务器异常
class ServiceException extends AppException {
  ServiceException({
    required super.message,
    super.code,
    super.details
});
}

/// 验证异常
class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.code,
    super.details
});
}

/// 资源未找到异常
class NotFoundException extends AppException {
  NotFoundException({
    required super.message,
    super.code,
    super.details
});
}


/// 未知异常
class UnknownException extends AppException {
  UnknownException({
    required super.message,
    super.code,
    super.details
});
}


