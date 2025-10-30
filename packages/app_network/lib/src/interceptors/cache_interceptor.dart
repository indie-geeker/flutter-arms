import 'package:app_interfaces/app_interfaces.dart';

import 'base_interceptor.dart';

/// 缓存拦截器
///
/// 根据缓存策略处理请求缓存和响应缓存
class CacheInterceptor extends BaseInterceptor {
  final ICacheStrategy _strategy;
  final ILogger? _logger;

  CacheInterceptor({
    required ICacheStrategy strategy,
    ILogger? logger,
  })  : _strategy = strategy,
        _logger = logger;

  @override
  int get priority => 10; // 较高优先级,在其他拦截器之前执行

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    // 检查是否支持缓存
    if (!_strategy.isCacheSupported(options)) {
      return options;
    }

    try {
      // 尝试从缓存获取
      final cachedResponse = await _strategy.getCache(options);

      // 判断是否需要从网络获取
      if (!_strategy.shouldFetchFromNetwork(options, cachedResponse)) {
        _logger?.debug(
          'Cache hit for ${options.path}, using cached response',
        );

        // 将缓存响应存储到 options 中,供后续处理
        final extra = Map<String, dynamic>.from(options.extra);
        extra['_cached_response'] = cachedResponse;
        extra['_use_cache'] = true;
        return options.copyWith(extra: extra);
      }

      _logger?.debug(
        'Cache miss or refresh required for ${options.path}, fetching from network',
      );
    } catch (e) {
      _logger?.error(
        'Error checking cache for ${options.path}',
        error: e,
      );
    }

    return options;
  }

  @override
  Future<ApiResponse<T>> onResponse<T>(
    ApiResponse<T> response,
    RequestOptions options,
  ) async {
    try {
      // 如果使用了缓存,直接返回缓存的响应
      if (options.extra['_use_cache'] == true) {
        final cachedResponse = options.extra['_cached_response'] as ApiResponse?;
        if (cachedResponse != null) {
          return cachedResponse as ApiResponse<T>;
        }
      }

      // 保存响应到缓存
      if (_strategy.isCacheSupported(options)) {
        // 将请求选项附加到响应的 extra 中,供缓存策略使用
        final updatedResponse = response.copyWith(
          extra: {
            ...response.extra,
            '_request_options': options,
          },
        );

        final saved = await _strategy.saveCache(updatedResponse);
        if (saved) {
          _logger?.debug(
            'Response cached for ${options.path}',
          );
        }
      }
    } catch (e) {
      _logger?.error(
        'Error caching response for ${options.path}',
        error: e,
      );
    }

    return response;
  }

  @override
  Future<Object> onError(Object error, RequestOptions options) async {
    // 如果网络请求失败,尝试返回缓存的数据
    if (_strategy.isCacheSupported(options)) {
      try {
        final cachedResponse = await _strategy.getCache(options);
        if (cachedResponse != null) {
          _logger?.warning(
            'Network error for ${options.path}, using stale cache',
          );

          // 将缓存响应作为成功结果返回
          // 注意: 这需要在错误处理逻辑中特殊处理
          return cachedResponse;
        }
      } catch (e) {
        _logger?.error(
          'Error retrieving cache on error for ${options.path}',
          error: e,
        );
      }
    }

    return error;
  }

  /// 清除所有缓存
  Future<void> clearCache() async {
    try {
      await _strategy.clearAllCache();
      _logger?.info('All cache cleared');
    } catch (e) {
      _logger?.error('Error clearing cache', error: e);
    }
  }

  /// 清除特定请求的缓存
  Future<void> invalidateCache(RequestOptions options) async {
    try {
      await _strategy.invalidateCache(options);
      _logger?.debug('Cache invalidated for ${options.path}');
    } catch (e) {
      _logger?.error('Error invalidating cache for ${options.path}', error: e);
    }
  }

  /// 获取缓存统计信息
  Future<CacheStatistics> getCacheStatistics() async {
    return await _strategy.getCacheStatistics();
  }
}
