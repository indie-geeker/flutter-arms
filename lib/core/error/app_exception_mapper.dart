import 'package:dio/dio.dart';
import 'package:flutter_arms/core/error/app_exception.dart';

/// Dio → [AppException] 映射工具。
///
/// 只处理"网络 → 数据层"方向的映射，供 `ApiInterceptor.onError` 使用。
class AppExceptionMapper {
  const AppExceptionMapper._();

  /// 将 [DioException] 映射为对应 [AppException] 子类。
  static AppException fromDio(DioException e, [StackTrace? st]) {
    final stack = st ?? e.stackTrace;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(cause: e, stackTrace: stack);
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return AuthException(
            cause: e,
            stackTrace: stack,
            detail: _extractMsg(e),
          );
        }
        return BadResponseException(
          cause: e,
          stackTrace: stack,
          detail: _extractMsg(e),
        );
      case DioExceptionType.cancel:
        return CancelledException(cause: e, stackTrace: stack);
      case DioExceptionType.connectionError:
        return NetworkException(cause: e, stackTrace: stack);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnknownException(cause: e, stackTrace: stack);
    }
  }

  static String? _extractMsg(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'] ?? data['msg'] ?? data['error'];
      if (msg is String && msg.isNotEmpty) {
        return msg;
      }
    }
    return null;
  }
}
