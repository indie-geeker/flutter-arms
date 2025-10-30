import 'package:app_interfaces/app_interfaces.dart';

import 'base_interceptor.dart';

/// 错误恢复拦截器
///
/// 集成多个错误恢复策略,在请求失败时尝试恢复
class ErrorRecoveryInterceptor extends BaseInterceptor {
  final List<IErrorRecoveryStrategy> _strategies;
  final ILogger? _logger;

  ErrorRecoveryInterceptor({
    required List<IErrorRecoveryStrategy> strategies,
    ILogger? logger,
  })  : _strategies = strategies,
        _logger = logger {
    // 按优先级排序策略
    _strategies.sort((a, b) => b.priority.compareTo(a.priority));
  }

  @override
  int get priority => 60; // 较低优先级,在其他拦截器之后执行

  @override
  Future<Object> onError(Object error, RequestOptions options) async {
    _logger?.debug(
      'Error recovery interceptor handling error: ${error.runtimeType}',
    );

    // 尝试使用每个策略恢复错误
    for (final strategy in _strategies) {
      if (!strategy.shouldRecover(error, options)) {
        continue;
      }

      _logger?.info(
        'Attempting recovery with strategy: ${strategy.name}',
      );

      try {
        // 尝试恢复
        final recoveredResponse = await strategy.recover(
          error: error,
          options: options,
          retry: () async {
            // 这里需要重新执行请求
            // 但是我们在拦截器中无法直接访问 NetworkClient
            // 所以返回 null,表示无法直接重试
            // 实际重试由 RetryInterceptor 处理
            throw UnimplementedError(
              'Direct retry in ErrorRecoveryInterceptor is not supported. '
              'Use RetryInterceptor for automatic retry.',
            );
          },
        );

        if (recoveredResponse != null) {
          strategy.onRecoverySuccess(error, recoveredResponse);
          _logger?.info(
            'Successfully recovered from error using ${strategy.name}',
          );

          // 返回恢复的响应
          return recoveredResponse;
        }
      } catch (recoveryError) {
        strategy.onRecoveryFailed(error, recoveryError);
        _logger?.error(
          'Recovery failed with ${strategy.name}: $recoveryError',
        );
        // 继续尝试下一个策略
      }
    }

    _logger?.warning(
      'All recovery strategies failed or no strategy applicable',
    );

    // 所有策略都失败,返回原始错误
    return error;
  }

  /// 添加恢复策略
  void addStrategy(IErrorRecoveryStrategy strategy) {
    _strategies.add(strategy);
    _strategies.sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// 移除恢复策略
  void removeStrategy(IErrorRecoveryStrategy strategy) {
    _strategies.remove(strategy);
  }

  /// 获取当前策略列表
  List<IErrorRecoveryStrategy> get strategies =>
      List.unmodifiable(_strategies);
}
