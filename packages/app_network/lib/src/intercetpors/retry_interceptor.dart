import 'dart:math';
import 'package:app_interfaces/app_interfaces.dart';
import 'base_interceptor.dart';

/// 重试拦截器
///
/// 负责在网络请求失败时自动重试，支持指数退避策略
class RetryInterceptor extends BaseInterceptor {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final Set<NetworkErrorType> retryableErrors;

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 10),
    Set<NetworkErrorType>? retryableErrors,
  }) : retryableErrors = retryableErrors ?? _defaultRetryableErrors;

  /// 默认可重试的错误类型
  static const Set<NetworkErrorType> _defaultRetryableErrors = {
    NetworkErrorType.connectionTimeout,
    NetworkErrorType.receiveTimeout,
    NetworkErrorType.sendTimeout,
    NetworkErrorType.connectionError,
    NetworkErrorType.serverError,
  };

  @override
  int get priority => 50; // 中等优先级

  @override
  Future<Object> onError(Object error, RequestOptions options) async {
    // 检查是否应该重试
    if (!_shouldRetry(error, options)) {
      return error;
    }

    final retryCount = _getRetryCount(options);
    if (retryCount >= maxRetries) {
      return error;
    }

    // 计算延迟时间
    final delay = _calculateDelay(retryCount);
    await Future.delayed(delay);

    // 更新重试次数
    final newOptions = _incrementRetryCount(options);

    // 返回特殊标记，表示需要重试
    // 注意：由于接口限制，这里只能返回错误，实际的重试逻辑需要在更高层实现
    return RetryableNetworkException(
      originalError: error,
      retryOptions: newOptions,
      retryCount: retryCount + 1,
    );
  }

  /// 检查是否应该重试
  bool _shouldRetry(Object error, RequestOptions options) {
    // 检查错误类型是否可重试
    if (error is NetworkException && error.details != null) {
      // 将 error.code 字符串转换为 NetworkErrorType 进行比较
     return retryableErrors.contains(error.details);
    }

    // 其他类型的错误默认不重试
    return false;
  }

  /// 获取当前重试次数
  int _getRetryCount(RequestOptions options) {
    return options.extra['_retry_count'] as int? ?? 0;
  }

  /// 增加重试次数
  RequestOptions _incrementRetryCount(RequestOptions options) {
    final extra = Map<String, dynamic>.from(options.extra);
    extra['_retry_count'] = _getRetryCount(options) + 1;

    return options.copyWith(
      extra: extra,
    );
  }

  /// 计算延迟时间（指数退避）
  Duration _calculateDelay(int retryCount) {
    final delayMs = initialDelay.inMilliseconds *
        pow(backoffMultiplier, retryCount);
    final delay = Duration(milliseconds: delayMs.round());

    // 限制最大延迟时间
    return delay > maxDelay ? maxDelay : delay;
  }
}

/// 可重试的网络异常
///
/// 用于标记需要重试的网络异常
class RetryableNetworkException implements Exception {
  final Object originalError;
  final RequestOptions retryOptions;
  final int retryCount;

  const RetryableNetworkException({
    required this.originalError,
    required this.retryOptions,
    required this.retryCount,
  });

  @override
  String toString() {
    return 'RetryableNetworkException: $originalError (retry: $retryCount)';
  }
}
