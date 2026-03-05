import 'package:dio/dio.dart';
import 'package:interfaces/interfaces.dart';

/// Network error handler.
///
/// Converts low-level networking library (Dio) exceptions to unified NetworkException.
class NetworkErrorHandler {
  /// Handles Dio exceptions.
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
        type = NetworkExceptionType.unknown;
        message = error.message ?? 'Unknown error occurred';
        break;
    }

    return NetworkException(
      message: message,
      type: type,
      statusCode: error.response?.statusCode,
      originalError: error,
    );
  }

  /// Handles generic exceptions.
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

  /// Gets timeout error message.
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

  /// Gets server error message.
  static String _getServerErrorMessage(Response? response) {
    if (response == null) {
      return 'Server error';
    }

    final statusCode = response.statusCode;
    final statusMessage = response.statusMessage;

    // Try extracting error message from response body.
    try {
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final message = data['message'] ?? data['error'] ?? data['msg'];
        if (message != null) {
          return message.toString();
        }
      }
    } catch (_) {
      // Ignore parse errors.
    }

    // Return default message based on status code.
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

  /// Determines whether the error is retryable.
  static bool isRetryable(
    NetworkException exception,
    Set<int> retryableStatusCodes,
  ) {
    // Timeout errors are retryable.
    if (exception.isTimeout) {
      return true;
    }

    // Connection errors are retryable.
    if (exception.isConnectionError) {
      return true;
    }

    // Specific status codes are retryable.
    if (exception.statusCode != null &&
        retryableStatusCodes.contains(exception.statusCode)) {
      return true;
    }

    // Server errors (5xx) are retryable.
    if (exception.isServerError) {
      return true;
    }

    return false;
  }
}
