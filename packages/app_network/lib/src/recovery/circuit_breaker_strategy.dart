import 'package:app_interfaces/app_interfaces.dart';

/// 熔断器状态
enum CircuitBreakerState {
  /// 关闭状态:正常工作
  closed,

  /// 打开状态:熔断中,拒绝请求
  open,

  /// 半开状态:尝试恢复
  halfOpen,
}

/// 熔断器恢复策略
///
/// 当连续失败达到阈值时,熔断器打开,拒绝所有请求
/// 经过超时时间后,进入半开状态,允许少量请求尝试恢复
class CircuitBreakerStrategy implements IErrorRecoveryStrategy {
  final int maxFailures;
  final Duration timeout;
  final Duration halfOpenTimeout;
  final ILogger? logger;

  CircuitBreakerState _state = CircuitBreakerState.closed;
  int _failureCount = 0;
  DateTime? _openTime;

  CircuitBreakerStrategy({
    this.maxFailures = 5,
    this.timeout = const Duration(seconds: 30),
    this.halfOpenTimeout = const Duration(seconds: 10),
    this.logger,
  });

  @override
  String get name => 'CircuitBreaker';

  @override
  int get priority => 20; // 中等优先级

  /// 获取当前熔断器状态
  CircuitBreakerState get state => _state;

  /// 获取当前失败计数
  int get failureCount => _failureCount;

  @override
  bool shouldRecover(Object error, RequestOptions options) {
    // 更新状态
    _updateState();

    // 只处理网络异常
    if (error is! NetworkException) {
      return false;
    }

    // 如果熔断器打开,不尝试恢复
    if (_state == CircuitBreakerState.open) {
      logger?.warning('Circuit breaker is OPEN, rejecting request');
      return false;
    }

    // 关闭或半开状态允许尝试
    return true;
  }

  @override
  Future<ApiResponse<T>?> recover<T>({
    required Object error,
    required RequestOptions options,
    required Future<ApiResponse<T>> Function() retry,
  }) async {
    // 更新状态
    _updateState();

    // 如果熔断器打开,直接拒绝
    if (_state == CircuitBreakerState.open) {
      logger?.warning('Circuit breaker OPEN, request rejected');
      _recordFailure();
      return null;
    }

    try {
      // 尝试请求
      final response = await retry();

      // 成功,重置失败计数
      _recordSuccess();
      logger?.info('Circuit breaker request succeeded, resetting state');

      return response;
    } catch (e) {
      // 失败,记录失败
      _recordFailure();
      logger?.warning('Circuit breaker request failed: $e');

      return null;
    }
  }

  @override
  void onRecoveryFailed(Object error, Object recoveryError) {
    logger?.error(
      'Circuit breaker recovery failed',
      error: recoveryError,
      tag: 'CircuitBreakerStrategy',
    );
    _recordFailure();
  }

  @override
  void onRecoverySuccess<T>(Object error, ApiResponse<T> response) {
    logger?.info(
      'Circuit breaker recovery succeeded',
      tag: 'CircuitBreakerStrategy',
    );
    _recordSuccess();
  }

  /// 更新熔断器状态
  void _updateState() {
    final now = DateTime.now();

    switch (_state) {
      case CircuitBreakerState.closed:
        // 关闭状态:如果失败次数达到阈值,打开熔断器
        if (_failureCount >= maxFailures) {
          _state = CircuitBreakerState.open;
          _openTime = now;
          logger?.warning(
            'Circuit breaker OPENED after $maxFailures failures',
          );
        }
        break;

      case CircuitBreakerState.open:
        // 打开状态:如果超时时间已过,进入半开状态
        if (_openTime != null && now.difference(_openTime!) >= timeout) {
          _state = CircuitBreakerState.halfOpen;
          _failureCount = 0;
          logger?.info('Circuit breaker entering HALF-OPEN state');
        }
        break;

      case CircuitBreakerState.halfOpen:
        // 半开状态:根据测试结果决定关闭或重新打开
        // 这个逻辑在 _recordSuccess 和 _recordFailure 中处理
        break;
    }
  }

  /// 记录成功
  void _recordSuccess() {
    _failureCount = 0;

    if (_state == CircuitBreakerState.halfOpen) {
      _state = CircuitBreakerState.closed;
      _openTime = null;
      logger?.info('Circuit breaker CLOSED after successful recovery');
    }
  }

  /// 记录失败
  void _recordFailure() {
    _failureCount++;

    if (_state == CircuitBreakerState.halfOpen) {
      // 半开状态下失败,重新打开熔断器
      _state = CircuitBreakerState.open;
      _openTime = DateTime.now();
      logger?.warning('Circuit breaker REOPENED after failure in HALF-OPEN state');
    }
  }

  /// 手动重置熔断器
  void reset() {
    _state = CircuitBreakerState.closed;
    _failureCount = 0;
    _openTime = null;
    logger?.info('Circuit breaker manually reset');
  }
}
