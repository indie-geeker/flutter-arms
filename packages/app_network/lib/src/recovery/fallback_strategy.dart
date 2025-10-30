import 'package:app_interfaces/app_interfaces.dart';

/// 降级数据提供者
typedef FallbackDataProvider<T> = Future<T?> Function(
  Object error,
  RequestOptions options,
);

/// 降级恢复策略
///
/// 当请求失败时,返回预设的降级数据或从缓存获取
class FallbackStrategy implements IErrorRecoveryStrategy {
  final FallbackDataProvider? fallbackDataProvider;
  final ICacheStrategy? cacheStrategy;
  final ILogger? logger;

  FallbackStrategy({
    this.fallbackDataProvider,
    this.cacheStrategy,
    this.logger,
  });

  @override
  String get name => 'Fallback';

  @override
  int get priority => 50; // 低优先级,作为最后的降级手段

  @override
  bool shouldRecover(Object error, RequestOptions options) {
    // 总是尝试降级
    return fallbackDataProvider != null || cacheStrategy != null;
  }

  @override
  Future<ApiResponse<T>?> recover<T>({
    required Object error,
    required RequestOptions options,
    required Future<ApiResponse<T>> Function() retry,
  }) async {
    // 1. 尝试从降级数据提供者获取数据
    if (fallbackDataProvider != null) {
      try {
        logger?.info('Attempting to get fallback data');
        final fallbackData = await fallbackDataProvider!(error, options);

        if (fallbackData != null) {
          logger?.info('Fallback data retrieved successfully');
          return ApiResponse<T>(
            code: 200,
            data: fallbackData as T,
            message: 'Fallback data',
            extra: {
              '_fallback': true,
              '_original_error': error.toString(),
            },
          );
        }
      } catch (e) {
        logger?.warning('Fallback data provider failed: $e');
      }
    }

    // 2. 尝试从缓存获取数据
    if (cacheStrategy != null) {
      try {
        logger?.info('Attempting to get cached data as fallback');
        final cachedResponse = await cacheStrategy!.getCache<T>(options);

        if (cachedResponse != null) {
          logger?.info('Cached data retrieved as fallback');
          return cachedResponse.copyWith(
            extra: {
              ...cachedResponse.extra,
              '_fallback': true,
              '_from_cache': true,
              '_original_error': error.toString(),
            },
          );
        }
      } catch (e) {
        logger?.warning('Cache fallback failed: $e');
      }
    }

    // 3. 无法降级
    logger?.error('No fallback data available');
    return null;
  }

  @override
  void onRecoveryFailed(Object error, Object recoveryError) {
    logger?.error(
      'Fallback recovery failed',
      error: recoveryError,
      tag: 'FallbackStrategy',
    );
  }

  @override
  void onRecoverySuccess<T>(Object error, ApiResponse<T> response) {
    logger?.info(
      'Fallback recovery succeeded with ${response.extra['_from_cache'] == true ? 'cached' : 'static'} data',
      tag: 'FallbackStrategy',
    );
  }
}

/// 静态降级策略
///
/// 返回预定义的静态数据
class StaticFallbackStrategy<T> extends FallbackStrategy {
  final T fallbackData;

  StaticFallbackStrategy({
    required this.fallbackData,
    ILogger? logger,
  }) : super(
          fallbackDataProvider: (error, options) async => fallbackData,
          logger: logger,
        );

  @override
  String get name => 'StaticFallback';
}
