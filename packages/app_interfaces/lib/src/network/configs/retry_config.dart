
class RetryConfig {
  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 10),
    this.retryableStatusCodes = const {408, 429, 500, 502, 503, 504},
    this.retryEvaluator,
  });

  /// Maximum number of retry attempts
  final int maxRetries;

  /// Initial delay before first retry
  final Duration initialDelay;

  /// Multiplier for exponential backoff
  final double backoffMultiplier;

  /// Maximum delay between retries
  final Duration maxDelay;

  /// HTTP status codes that trigger retry
  final Set<int> retryableStatusCodes;

  /// Custom function to evaluate if error should be retried
  final bool Function(Object error, int retryCount)? retryEvaluator;

  /// Disabled retry configuration
  static const RetryConfig disabled = RetryConfig(maxRetries: 0);
}
