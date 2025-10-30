import '../models/api_response.dart';
import '../models/request_options.dart';

/// 错误恢复策略接口
///
/// 定义网络请求失败后的恢复策略,支持重试、降级、熔断等多种模式
/// 可组合多个策略形成恢复链
abstract class IErrorRecoveryStrategy {
  /// 策略名称,用于日志和调试
  String get name;

  /// 策略优先级,数字越小优先级越高
  ///
  /// 在复合策略中,优先级高的策略先执行
  int get priority => 100;

  /// 判断是否应该尝试恢复此错误
  ///
  /// [error] 发生的错误
  /// [options] 请求选项
  ///
  /// 返回 true 表示此策略可以处理该错误
  bool shouldRecover(Object error, RequestOptions options);

  /// 尝试从错误中恢复
  ///
  /// [error] 发生的错误
  /// [options] 请求选项
  /// [retry] 重试函数,调用此函数重新发起请求
  ///
  /// 返回恢复后的响应,如果无法恢复则返回 null
  Future<ApiResponse<T>?> recover<T>({
    required Object error,
    required RequestOptions options,
    required Future<ApiResponse<T>> Function() retry,
  });

  /// 恢复失败时的回调
  ///
  /// [error] 原始错误
  /// [recoveryError] 恢复过程中发生的错误
  void onRecoveryFailed(Object error, Object recoveryError) {}

  /// 恢复成功时的回调
  ///
  /// [error] 原始错误
  /// [response] 恢复后的响应
  void onRecoverySuccess<T>(Object error, ApiResponse<T> response) {}
}

/// 复合错误恢复策略
///
/// 组合多个恢复策略,按优先级顺序依次尝试
class CompositeErrorRecoveryStrategy implements IErrorRecoveryStrategy {
  final List<IErrorRecoveryStrategy> strategies;

  CompositeErrorRecoveryStrategy(this.strategies) {
    // 按优先级排序
    strategies.sort((a, b) => a.priority.compareTo(b.priority));
  }

  @override
  String get name => 'Composite(${strategies.map((s) => s.name).join(", ")})';

  @override
  int get priority => strategies.isEmpty ? 100 : strategies.first.priority;

  @override
  bool shouldRecover(Object error, RequestOptions options) {
    return strategies.any((s) => s.shouldRecover(error, options));
  }

  @override
  Future<ApiResponse<T>?> recover<T>({
    required Object error,
    required RequestOptions options,
    required Future<ApiResponse<T>> Function() retry,
  }) async {
    for (final strategy in strategies) {
      if (!strategy.shouldRecover(error, options)) {
        continue;
      }

      try {
        final response = await strategy.recover<T>(
          error: error,
          options: options,
          retry: retry,
        );

        if (response != null) {
          strategy.onRecoverySuccess(error, response);
          return response;
        }
      } catch (e) {
        strategy.onRecoveryFailed(error, e);
        // 继续尝试下一个策略
      }
    }

    // 所有策略都失败
    return null;
  }

  @override
  void onRecoveryFailed(Object error, Object recoveryError) {
    for (final strategy in strategies) {
      strategy.onRecoveryFailed(error, recoveryError);
    }
  }

  @override
  void onRecoverySuccess<T>(Object error, ApiResponse<T> response) {
    for (final strategy in strategies) {
      strategy.onRecoverySuccess(error, response);
    }
  }

  /// 添加策略
  void addStrategy(IErrorRecoveryStrategy strategy) {
    strategies.add(strategy);
    strategies.sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// 移除策略
  void removeStrategy(IErrorRecoveryStrategy strategy) {
    strategies.remove(strategy);
  }

  /// 清空所有策略
  void clearStrategies() {
    strategies.clear();
  }
}

/// 空恢复策略
///
/// 不执行任何恢复操作,直接失败
class NoOpRecoveryStrategy implements IErrorRecoveryStrategy {
  const NoOpRecoveryStrategy();

  @override
  String get name => 'NoOp';

  @override
  int get priority => 999;

  @override
  bool shouldRecover(Object error, RequestOptions options) => false;

  @override
  Future<ApiResponse<T>?> recover<T>({
    required Object error,
    required RequestOptions options,
    required Future<ApiResponse<T>> Function() retry,
  }) async {
    return null;
  }

  @override
  void onRecoveryFailed(Object error, Object recoveryError) {
    // No-op
  }

  @override
  void onRecoverySuccess<T>(Object error, ApiResponse<T> response) {
    // No-op
  }
}
