import 'dart:math';

import 'package:app_interfaces/app_interfaces.dart';

import 'base_interceptor.dart';

/// Enhanced retry interceptor with configuration support
class RetryInterceptor extends BaseInterceptor {
  final RetryConfig _config;
  final ILogger? _logger;

  RetryInterceptor({
    RetryConfig? config,
    ILogger? logger,
  })  : _config = config ?? const RetryConfig(),
        _logger = logger;

  @override
  int get priority => 50;

  @override
  Future<Object> onError(Object error, RequestOptions options) async {
    // Check if retry is disabled
    if (_config.maxRetries == 0) {
      return error;
    }

    // Check if this error should be retried
    if (!_shouldRetry(error, options)) {
      return error;
    }

    final retryCount = _getRetryCount(options);
    if (retryCount >= _config.maxRetries) {
      _logger?.warning(
        'Max retries (${_config.maxRetries}) reached for ${options.path}',
      );
      return error;
    }

    // Calculate delay with exponential backoff
    final delay = _calculateDelay(retryCount);
    _logger?.info(
      'Retrying request (${retryCount + 1}/${_config.maxRetries}) '
          'after ${delay.inMilliseconds}ms: ${options.path}',
    );

    await Future.delayed(delay);

    final newOptions = _incrementRetryCount(options);

    return RetryableNetworkException(
      message: 'Retrying request (${retryCount + 1}/${_config.maxRetries})',
      originalError: error,
      retryOptions: newOptions,
      retryCount: retryCount + 1,
    );
  }

  bool _shouldRetry(Object error, RequestOptions options) {
    // Custom evaluator takes precedence
    if (_config.retryEvaluator != null) {
      final retryCount = _getRetryCount(options);
      return _config.retryEvaluator!(error, retryCount);
    }

    // Check HTTP status codes for server errors
    if (error is NetworkException && error.statusCode != null) {
      return _config.retryableStatusCodes.contains(error.statusCode);
    }

    // Check error types
    if (error is NetworkException) {
      final errorType = NetworkErrorType.values.firstWhere(
            (type) => type.name == error.code,
        orElse: () => NetworkErrorType.unknown,
      );

      const retryableTypes = {
        NetworkErrorType.connectionTimeout,
        NetworkErrorType.receiveTimeout,
        NetworkErrorType.sendTimeout,
        NetworkErrorType.connectionError,
      };

      return retryableTypes.contains(errorType);
    }

    return false;
  }

  Duration _calculateDelay(int retryCount) {
    final delayMs = _config.initialDelay.inMilliseconds *
        pow(_config.backoffMultiplier, retryCount);
    final delay = Duration(milliseconds: delayMs.round());
    return delay > _config.maxDelay ? _config.maxDelay : delay;
  }

  int _getRetryCount(RequestOptions options) {
    return options.extra['_retry_count'] as int? ?? 0;
  }

  RequestOptions _incrementRetryCount(RequestOptions options) {
    final extra = Map<String, dynamic>.from(options.extra);
    extra['_retry_count'] = _getRetryCount(options) + 1;
    return options.copyWith(extra: extra);
  }
}

