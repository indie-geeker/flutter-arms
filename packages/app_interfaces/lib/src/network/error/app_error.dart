import 'package:app_interfaces/src/common/result/result.dart';

/// 网络错误
///
/// 表示网络层面的错误，如超时、连接失败等
class NetworkError extends AppError {
  @override
  final String message;

  @override
  final String code;

  @override
  final dynamic details;

  /// HTTP 状态码
  final int? statusCode;

  /// 原始错误消息
  final String? originalMessage;

  const NetworkError({
    required this.message,
    required this.code,
    this.statusCode,
    this.originalMessage,
    this.details,
  });

  @override
  bool get isRetryable {
    // 如果没有状态码（网络层错误）或服务器错误（5xx），则可重试
    return statusCode == null || (statusCode! >= 500 && statusCode! < 600);
  }

  @override
  String toString() =>
      'NetworkError(code: $code, message: $message, statusCode: $statusCode)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkError &&
        other.code == code &&
        other.message == message &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode => code.hashCode ^ message.hashCode ^ statusCode.hashCode;

  /// 创建连接超时错误
  factory NetworkError.connectionTimeout({String? details}) {
    return NetworkError(
      message: 'Connection timeout',
      code: 'connection_timeout',
      details: details,
    );
  }

  /// 创建接收超时错误
  factory NetworkError.receiveTimeout({String? details}) {
    return NetworkError(
      message: 'Receive timeout',
      code: 'receive_timeout',
      details: details,
    );
  }

  /// 创建发送超时错误
  factory NetworkError.sendTimeout({String? details}) {
    return NetworkError(
      message: 'Send timeout',
      code: 'send_timeout',
      details: details,
    );
  }

  /// 创建请求取消错误
  factory NetworkError.requestCancelled({String? details}) {
    return NetworkError(
      message: 'Request cancelled',
      code: 'request_cancelled',
      details: details,
    );
  }

  /// 创建无网络连接错误
  factory NetworkError.noConnection({String? details}) {
    return NetworkError(
      message: 'No internet connection',
      code: 'no_connection',
      details: details,
    );
  }

  /// 创建服务器错误
  factory NetworkError.serverError({
    required int statusCode,
    String? message,
    String? details,
  }) {
    return NetworkError(
      message: message ?? 'Server error',
      code: 'server_error',
      statusCode: statusCode,
      details: details,
    );
  }

  /// 创建未知错误
  factory NetworkError.unknown({
    String? message,
    String? details,
  }) {
    return NetworkError(
      message: message ?? 'Unknown network error',
      code: 'unknown_error',
      details: details,
    );
  }
}

/// 业务错误
///
/// 表示业务逻辑层面的错误，由服务器返回的业务错误码
class BusinessError extends AppError {
  @override
  final String message;

  @override
  final String code;

  @override
  final dynamic details;

  /// 业务错误码
  final int businessCode;

  /// 额外的业务数据
  final Map<String, dynamic>? extraData;

  const BusinessError({
    required this.message,
    required this.code,
    required this.businessCode,
    this.details,
    this.extraData,
  });

  @override
  bool get isRetryable => false; // 业务错误通常不可重试

  @override
  String toString() =>
      'BusinessError(code: $code, businessCode: $businessCode, message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessError &&
        other.code == code &&
        other.businessCode == businessCode &&
        other.message == message;
  }

  @override
  int get hashCode =>
      code.hashCode ^ businessCode.hashCode ^ message.hashCode;
}

/// 验证错误
///
/// 表示数据验证失败的错误，通常包含字段级别的错误信息
class ValidationError extends AppError {
  @override
  final String message;

  @override
  final String code;

  @override
  final dynamic details;

  /// 字段级别的错误信息
  final Map<String, String> fieldErrors;

  const ValidationError({
    required this.message,
    this.code = 'validation_error',
    this.details,
    this.fieldErrors = const {},
  });

  @override
  bool get isRetryable => false; // 验证错误不可重试

  @override
  String toString() =>
      'ValidationError(code: $code, message: $message, fieldErrors: $fieldErrors)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationError &&
        other.code == code &&
        other.message == message;
  }

  @override
  int get hashCode => code.hashCode ^ message.hashCode;
}

/// 认证错误
///
/// 表示认证相关的错误，如 token 过期、未授权等
class AuthError extends AppError {
  @override
  final String message;

  @override
  final String code;

  @override
  final dynamic details;

  /// 是否为 token 过期
  final bool isTokenExpired;

  const AuthError({
    required this.message,
    this.code = 'auth_error',
    this.details,
    this.isTokenExpired = false,
  });

  @override
  bool get isRetryable => isTokenExpired; // token 过期后刷新 token 可重试

  @override
  String toString() =>
      'AuthError(code: $code, message: $message, isTokenExpired: $isTokenExpired)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthError &&
        other.code == code &&
        other.message == message &&
        other.isTokenExpired == isTokenExpired;
  }

  @override
  int get hashCode =>
      code.hashCode ^ message.hashCode ^ isTokenExpired.hashCode;

  /// 创建未授权错误
  factory AuthError.unauthorized({String? message, String? details}) {
    return AuthError(
      message: message ?? 'Unauthorized',
      code: 'unauthorized',
      details: details,
    );
  }

  /// 创建 token 过期错误
  factory AuthError.tokenExpired({String? message, String? details}) {
    return AuthError(
      message: message ?? 'Token expired',
      code: 'token_expired',
      details: details,
      isTokenExpired: true,
    );
  }

  /// 创建权限不足错误
  factory AuthError.forbidden({String? message, String? details}) {
    return AuthError(
      message: message ?? 'Forbidden',
      code: 'forbidden',
      details: details,
    );
  }
}

/// 数据解析错误
///
/// 表示数据解析失败的错误
class ParseError extends AppError {
  @override
  final String message;

  @override
  final String code;

  @override
  final dynamic details;

  /// 原始数据
  final dynamic rawData;

  const ParseError({
    required this.message,
    this.code = 'parse_error',
    this.details,
    this.rawData,
  });

  @override
  bool get isRetryable => false; // 解析错误不可重试

  @override
  String toString() => 'ParseError(code: $code, message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParseError &&
        other.code == code &&
        other.message == message;
  }

  @override
  int get hashCode => code.hashCode ^ message.hashCode;
}
