/// 应用异常基类
///
/// 所有应用内部异常的基类，提供统一的异常处理接口
abstract class AppException implements Exception {
  /// 创建应用异常
  ///
  /// [message] 异常消息
  /// [code] 异常代码
  const AppException({
    required this.message,
    this.code = 'unknown_error',
    this.details,
    this.stackTrace,
  });

  /// 异常消息
  final String message;

  /// 异常代码，用于唯一标识异常类型
  final String code;

  /// 异常详情，可以是任何类型的数据
  final dynamic details;

  /// 异常堆栈
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException: [$code] $message';
}

/// 网络异常
///
/// 表示网络相关的异常
class NetworkException extends AppException {
  /// 创建网络异常
  const NetworkException({
    required super.message,
    super.code = 'network_error',
    super.details,
    this.statusCode,
    super.stackTrace,
  });

  /// HTTP状态码
  final int? statusCode;
}

/// 认证异常
///
/// 表示认证相关的异常，如登录失败、token过期等
class AuthException extends AppException {
  /// 创建认证异常
  const AuthException({
    required super.message,
    super.code = 'auth_error',
    super.details,
    super.stackTrace,
  });
}

/// 权限异常
///
/// 表示权限相关的异常，如用户无权限访问某资源
class PermissionException extends AppException {
  /// 创建权限异常
  const PermissionException({
    required super.message,
    super.code = 'permission_denied',
    super.details,
    super.stackTrace,
  });
}

/// 数据异常
///
/// 表示数据处理相关的异常，如数据解析失败、数据格式错误等
class DataException extends AppException {
  /// 创建数据异常
  const DataException({
    required super.message,
    super.code = 'data_error',
    super.details,
    super.stackTrace,
  });
}

/// 资源异常
///
/// 表示资源相关的异常，如资源不存在、资源已被占用等
class ResourceException extends AppException {
  /// 创建资源异常
  const ResourceException({
    required super.message,
    super.code = 'resource_error',
    super.details,
    super.stackTrace,
  });
}

/// 缓存异常
///
/// 表示缓存相关的异常，如缓存读取失败、缓存写入失败等
class CacheException extends AppException {
  /// 创建缓存异常
  const CacheException({
    required super.message,
    super.code = 'cache_error',
    super.details,
    super.stackTrace,
  });
}

/// 业务异常
///
/// 表示业务逻辑相关的异常，如业务规则验证失败等
class BusinessException extends AppException {
  /// 创建业务异常
  const BusinessException({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
  });
}
