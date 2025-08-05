
/// 重试配置
class RetryConfig {
  /// 创建重试配置
  const RetryConfig({
    this.maxRetries = 3,
    this.retryInterval = const Duration(seconds: 3),
    this.retryEvaluator,
  });

  /// 最大重试次数
  final int maxRetries;

  /// 重试间隔时间
  final Duration retryInterval;

  /// 重试评估函数，返回true表示需要重试
  final bool Function(Object error, int retryCount)? retryEvaluator;
}
