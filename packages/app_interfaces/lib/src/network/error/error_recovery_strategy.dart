import 'package:app_interfaces/src/common/result/result.dart';

/// 错误恢复策略
///
/// 提供统一的错误重试和恢复机制
class ErrorRecoveryStrategy {
  /// 最大重试次数
  final int maxRetries;

  /// 基础重试延迟
  final Duration baseRetryDelay;

  /// 是否使用指数退避
  final bool useExponentialBackoff;

  /// 退避因子
  final double backoffFactor;

  /// 最大退避延迟
  final Duration maxBackoffDelay;

  const ErrorRecoveryStrategy({
    this.maxRetries = 3,
    this.baseRetryDelay = const Duration(seconds: 1),
    this.useExponentialBackoff = true,
    this.backoffFactor = 2.0,
    this.maxBackoffDelay = const Duration(seconds: 30),
  });

  /// 执行带重试的操作
  ///
  /// [action] 要执行的操作
  /// [shouldRetry] 自定义重试条件，返回 true 表示应该重试
  Future<Result<T>> execute<T>({
    required Future<Result<T>> Function() action,
    bool Function(AppError error)? shouldRetry,
  }) async {
    int attempt = 0;
    AppError? lastError;

    while (attempt <= maxRetries) {
      try {
        final result = await action();

        // 如果成功，直接返回
        if (result is Success<T>) {
          return result;
        }

        // 获取错误
        final error = (result as Failure<T>).error;
        lastError = error;

        // 检查是否应该重试
        final canRetry = shouldRetry?.call(error) ?? error.isRetryable;

        if (!canRetry || attempt >= maxRetries) {
          return result;
        }

        // 计算延迟时间
        final delay = _calculateDelay(attempt);

        // 等待后重试
        await Future.delayed(delay);
        attempt++;
      } catch (e) {
        // 如果抛出异常，尝试包装为错误并重试
        if (attempt >= maxRetries) {
          rethrow;
        }

        final delay = _calculateDelay(attempt);
        await Future.delayed(delay);
        attempt++;
      }
    }

    // 如果所有重试都失败，返回最后的错误
    return Failure<T>(lastError!);
  }

  /// 计算重试延迟
  Duration _calculateDelay(int attempt) {
    if (!useExponentialBackoff) {
      return baseRetryDelay;
    }

    // 指数退避：delay = baseDelay * (backoffFactor ^ attempt)
    final delayInMilliseconds =
        baseRetryDelay.inMilliseconds * (backoffFactor * (attempt + 1));

    final delay = Duration(milliseconds: delayInMilliseconds.toInt());

    // 限制最大延迟
    return delay > maxBackoffDelay ? maxBackoffDelay : delay;
  }

  /// 创建快速重试策略（用于轻量级操作）
  factory ErrorRecoveryStrategy.fast() {
    return const ErrorRecoveryStrategy(
      maxRetries: 2,
      baseRetryDelay: Duration(milliseconds: 200),
      useExponentialBackoff: false,
    );
  }

  /// 创建标准重试策略（默认）
  factory ErrorRecoveryStrategy.standard() {
    return const ErrorRecoveryStrategy(
      maxRetries: 3,
      baseRetryDelay: Duration(seconds: 1),
      useExponentialBackoff: true,
      backoffFactor: 2.0,
    );
  }

  /// 创建耐心重试策略（用于重要操作）
  factory ErrorRecoveryStrategy.patient() {
    return const ErrorRecoveryStrategy(
      maxRetries: 5,
      baseRetryDelay: Duration(seconds: 2),
      useExponentialBackoff: true,
      backoffFactor: 2.0,
      maxBackoffDelay: Duration(minutes: 1),
    );
  }

  /// 创建无重试策略
  factory ErrorRecoveryStrategy.noRetry() {
    return const ErrorRecoveryStrategy(
      maxRetries: 0,
      baseRetryDelay: Duration.zero,
      useExponentialBackoff: false,
    );
  }
}

/// 错误恢复辅助类
///
/// 提供便捷的错误处理和恢复方法
class ErrorRecoveryHelper {
  /// 执行操作，并在失败时提供默认值
  static Future<T> executeWithFallback<T>({
    required Future<Result<T>> Function() action,
    required T fallbackValue,
    ErrorRecoveryStrategy? strategy,
  }) async {
    final recoveryStrategy = strategy ?? ErrorRecoveryStrategy.standard();

    final result = await recoveryStrategy.execute(action: action);

    return result.when(
      onSuccess: (data) => data,
      onFailure: (_) => fallbackValue,
    );
  }

  /// 执行操作，并在失败时使用恢复函数
  static Future<T> executeWithRecovery<T>({
    required Future<Result<T>> Function() action,
    required T Function(AppError error) recovery,
    ErrorRecoveryStrategy? strategy,
  }) async {
    final recoveryStrategy = strategy ?? ErrorRecoveryStrategy.standard();

    final result = await recoveryStrategy.execute(action: action);

    return result.when(
      onSuccess: (data) => data,
      onFailure: recovery,
    );
  }

  /// 执行多个操作，返回第一个成功的结果
  static Future<Result<T>> executeFirstSuccessful<T>({
    required List<Future<Result<T>> Function()> actions,
  }) async {
    AppError? lastError;

    for (final action in actions) {
      final result = await action();

      if (result is Success<T>) {
        return result;
      }

      lastError = (result as Failure<T>).error;
    }

    // 所有操作都失败
    return Failure<T>(lastError!);
  }

  /// 并行执行多个操作，返回所有成功的结果
  static Future<List<T>> executeAllSuccessful<T>({
    required List<Future<Result<T>> Function()> actions,
  }) async {
    final results = await Future.wait(
      actions.map((action) => action()),
    );

    final successfulResults = <T>[];

    for (final result in results) {
      if (result is Success<T>) {
        successfulResults.add(result.data);
      }
    }

    return successfulResults;
  }

  /// 执行操作链，如果前一个成功则执行下一个
  static Future<Result<T>> executeChain<T>({
    required List<Future<Result<T>> Function(T? previousData)> actions,
  }) async {
    T? currentData;

    for (final action in actions) {
      final result = await action(currentData);

      if (result is Failure<T>) {
        return result;
      }

      currentData = (result as Success<T>).data;
    }

    return Success<T>(currentData as T);
  }
}
