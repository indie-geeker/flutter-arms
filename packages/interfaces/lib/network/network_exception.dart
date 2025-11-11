
/// 网络异常类型
enum NetworkExceptionType {
  /// 超时
  timeout,

  /// 无网络连接
  noInternet,

  /// 服务器错误（4xx, 5xx）
  serverError,

  /// 请求被取消
  cancelled,

  /// 解析错误
  parseError,

  /// 未知错误
  unknown,
}

/// 网络异常
class NetworkException implements Exception {
  /// 错误消息
  final String message;

  /// 异常类型
  final NetworkExceptionType type;

  /// HTTP 状态码
  final int? statusCode;

  /// 原始错误对象
  final dynamic originalError;

  NetworkException({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    return 'NetworkException: $message (type: $type, statusCode: $statusCode)';
  }

  /// 是否为客户端错误（4xx）
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// 是否为服务端错误（5xx）
  bool get isServerError =>
      statusCode != null && statusCode! >= 500 && statusCode! < 600;

  /// 是否为超时错误
  bool get isTimeout => type == NetworkExceptionType.timeout;

  /// 是否为网络连接错误
  bool get isConnectionError => type == NetworkExceptionType.noInternet;
}