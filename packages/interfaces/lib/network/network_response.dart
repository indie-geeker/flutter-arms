
import 'network_exception.dart';

/// 网络响应封装
class NetworkResponse<T> {
  final T? data;
  final int statusCode;
  final String? statusMessage;
  final Map<String, dynamic>? headers;
  final bool isSuccess;
  final NetworkException? error;

  NetworkResponse({
    this.data,
    required this.statusCode,
    this.statusMessage,
    this.headers,
    this.isSuccess = true,
    this.error,
  });

  /// 创建成功响应
  factory NetworkResponse.success(
      T data, {
        int statusCode = 200,
        String? statusMessage,
        Map<String, dynamic>? headers,
      }) {
    return NetworkResponse(
      data: data,
      statusCode: statusCode,
      statusMessage: statusMessage,
      headers: headers,
      isSuccess: true,
    );
  }

  /// 创建失败响应
  factory NetworkResponse.failure(
      NetworkException error, {
        int statusCode = 500,
        String? statusMessage,
      }) {
    return NetworkResponse(
      statusCode: statusCode,
      statusMessage: statusMessage,
      isSuccess: false,
      error: error,
    );
  }
}