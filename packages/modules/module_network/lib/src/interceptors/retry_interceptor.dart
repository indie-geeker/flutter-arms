import 'package:dio/dio.dart';
import 'package:interfaces/interfaces.dart';

/// Network request retry interceptor.
class RetryInterceptor extends Interceptor {
  final ILogger _logger;
  final Dio _dio; // Uses the original Dio instance for retries.
  final int maxRetries;
  final Duration retryDelay;
  final bool exponentialBackoff;
  final Set<int> retryableStatusCodes;
  static const Set<String> _retryableMethods = {
    'GET',
    'PUT',
    'DELETE',
    'HEAD',
    'OPTIONS',
  };

  RetryInterceptor(
    this._logger,
    this._dio, {
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.exponentialBackoff = true,
    this.retryableStatusCodes = const {408, 429, 500, 502, 503, 504},
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check whether a retry should be attempted.
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    // Get the current retry count.
    final retryCount = err.requestOptions.extra['retry_count'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      _logger.warning('Max retries reached for: ${err.requestOptions.uri}');
      return handler.next(err);
    }

    final delay = exponentialBackoff
        ? retryDelay * (1 << retryCount)
        : retryDelay;
    await Future.delayed(delay);

    _logger.info(
      'Retrying request (${retryCount + 1}/$maxRetries): ${err.requestOptions.uri}',
    );

    // Update the retry count.
    err.requestOptions.extra['retry_count'] = retryCount + 1;

    try {
      // Re-issue the request using the original Dio instance, preserving baseUrl, headers, and interceptors.
      final response = await _dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Determines whether a retry should be attempted.
  bool _shouldRetry(DioException err) {
    final method = err.requestOptions.method.toUpperCase();
    if (!_retryableMethods.contains(method)) {
      return false;
    }

    // Only retry on network and timeout errors.
    final statusCode = err.response?.statusCode;

    if (statusCode != null && retryableStatusCodes.contains(statusCode)) {
      return true;
    }

    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (statusCode != null && statusCode >= 500);
  }
}
