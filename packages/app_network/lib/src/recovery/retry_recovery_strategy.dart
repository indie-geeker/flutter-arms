import 'package:app_interfaces/app_interfaces.dart';

/// 重试恢复策略
///
/// 根据配置的重试规则自动重试失败的请求
class RetryRecoveryStrategy implements IErrorRecoveryStrategy {
  final RetryConfig config;
  final ILogger? logger;

  RetryRecoveryStrategy({
    required this.config,
    this.logger,
  });

  @override
  String get name => 'Retry';

  @override
  int get priority => 10; // 高优先级,优先尝试重试

  @override
  bool shouldRecover(Object error, RequestOptions options) {
    // 只处理网络异常
    if (error is! NetworkException) {
      return false;
    }

    // 使用自定义评估器(如果有)
    if (config.retryEvaluator != null) {
      // retryEvaluator expects (error, retryCount), use 0 for initial check
      return config.retryEvaluator!(error, 0);
    }

    // 默认评估逻辑:只重试超时和连接错误
    return error.code == 'connection_timeout' ||
        error.code == 'receive_timeout' ||
        error.code == 'send_timeout' ||
        error.code == 'connection_error';
  }

  @override
  Future<ApiResponse<T>?> recover<T>({
    required Object error,
    required RequestOptions options,
    required Future<ApiResponse<T>> Function() retry,
  }) async {
    int attempt = 0;
    Duration currentDelay = config.initialDelay;

    while (attempt < config.maxRetries) {
      attempt++;

      // 等待延迟
      if (currentDelay > Duration.zero) {
        logger?.debug('Retry attempt $attempt after ${currentDelay.inMilliseconds}ms');
        await Future.delayed(currentDelay);
      }

      try {
        // 重试请求
        final response = await retry();
        logger?.info('Retry attempt $attempt succeeded');
        return response;
      } catch (e) {
        logger?.warning('Retry attempt $attempt failed: $e');

        // 如果达到最大重试次数,返回 null
        if (attempt >= config.maxRetries) {
          logger?.error('Max retries ($attempt) reached, giving up');
          return null;
        }

        // 计算下次延迟(指数退避)
        currentDelay = _calculateNextDelay(currentDelay);
      }
    }

    return null;
  }

  @override
  void onRecoveryFailed(Object error, Object recoveryError) {
    logger?.error(
      'Retry recovery failed',
      error: recoveryError,
      tag: 'RetryRecoveryStrategy',
    );
  }

  @override
  void onRecoverySuccess<T>(Object error, ApiResponse<T> response) {
    logger?.info(
      'Retry recovery succeeded',
      tag: 'RetryRecoveryStrategy',
    );
  }

  /// 计算下次延迟时间(指数退避)
  Duration _calculateNextDelay(Duration currentDelay) {
    final nextDelay = Duration(
      milliseconds: (currentDelay.inMilliseconds * config.backoffMultiplier).toInt(),
    );

    // 限制最大延迟
    return nextDelay > config.maxDelay ? config.maxDelay : nextDelay;
  }
}
