
import 'package:dio/dio.dart';
import 'package:interfaces/interfaces.dart';

/// 网络错误处理器
///
/// 负责将底层网络库（Dio）的异常转换为统一的 NetworkException
class NetworkErrorHandler {
  /// 处理 Dio 异常
  static NetworkException handleDioException(DioException error) {
    NetworkExceptionType type;
    String message;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        type = NetworkExceptionType.timeout;
        message = _getTimeoutMessage(error.type);
        break;

      case DioExceptionType.badResponse:
        type = NetworkExceptionType.serverError;
        message = _getServerErrorMessage(error.response);
        break;

      case DioExceptionType.cancel:
        type = NetworkExceptionType.cancelled;
        message = 'Request cancelled';
        break;

      case DioExceptionType.connectionError:
        type = NetworkExceptionType.noInternet;
        message = 'No internet connection';
        break;

      case DioExceptionType.badCertificate:
        type = NetworkExceptionType.unknown;
        message = 'SSL certificate verification failed';
        break;

      case DioExceptionType.unknown:
      default:
        type = NetworkExceptionType.unknown;
        message = error.message ?? 'Unknown error occurred';
    }

    return NetworkException(
      message: message,
      type: type,
      statusCode: error.response?.statusCode,
      originalError: error,
    );
  }

  /// 处理通用异常
  static NetworkException handleGenericException(
      dynamic error,
      StackTrace? stackTrace,
      ) {
    String message;

    if (error is FormatException) {
      return NetworkException(
        message: 'Failed to parse response data',
        type: NetworkExceptionType.parseError,
        originalError: error,
      );
    }

    message = error.toString();

    return NetworkException(
      message: message,
      type: NetworkExceptionType.unknown,
      originalError: error,
    );
  }

  /// 获取超时错误消息
  static String _getTimeoutMessage(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      default:
        return 'Request timeout';
    }
  }

  /// 获取服务器错误消息
  static String _getServerErrorMessage(Response? response) {
    if (response == null) {
      return 'Server error';
    }

    final statusCode = response.statusCode;
    final statusMessage = response.statusMessage;

    // 尝试从响应体中提取错误消息
    try {
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final message = data['message'] ?? data['error'] ?? data['msg'];
        if (message != null) {
          return message.toString();
        }
      }
    } catch (_) {
      // 忽略解析错误
    }

    // 根据状态码返回默认消息
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Bad request';
        case 401:
          return 'Unauthorized';
        case 403:
          return 'Forbidden';
        case 404:
          return 'Not found';
        case 405:
          return 'Method not allowed';
        case 408:
          return 'Request timeout';
        case 409:
          return 'Conflict';
        case 422:
          return 'Validation failed';
        case 429:
          return 'Too many requests';
        case 500:
          return 'Internal server error';
        case 502:
          return 'Bad gateway';
        case 503:
          return 'Service unavailable';
        case 504:
          return 'Gateway timeout';
        default:
          return statusMessage ?? 'Server error';
      }
    }

    return statusMessage ?? 'Server error';
  }

  /// 判断错误是否可重试
  static bool isRetryable(NetworkException exception, Set<int> retryableStatusCodes) {
    // 超时错误可重试
    if (exception.isTimeout) {
      return true;
    }

    // 连接错误可重试
    if (exception.isConnectionError) {
      return true;
    }

    // 特定状态码可重试
    if (exception.statusCode != null &&
        retryableStatusCodes.contains(exception.statusCode)) {
      return true;
    }

    // 服务器错误（5xx）可重试
    if (exception.isServerError) {
      return true;
    }

    return false;
  }
}