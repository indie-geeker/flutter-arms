import 'dart:async';
import 'package:app_interfaces/app_interfaces.dart';

/// 无缓存策略
///
/// 不进行任何缓存操作，所有请求都直接从网络获取
class NoCacheStrategy implements ICacheStrategy {
  const NoCacheStrategy();

  @override
  Future<ApiResponse<T>?> getCache<T>(RequestOptions options) async {
    return null;
  }

  @override
  Future<bool> saveCache<T>(ApiResponse<T> response) async {
    return false;
  }

  @override
  bool shouldFetchFromNetwork<T>(
    RequestOptions options,
      ApiResponse<T>? cachedResponse,
  ) {
    return true;
  }

  @override
  bool isCacheSupported(RequestOptions options) {
    return false;
  }

  @override
  Future<bool> invalidateCache(RequestOptions options) async {
    return false;
  }

  @override
  Future<bool> clearAllCache() async {
    return false;
  }

  @override
  Future<CacheStatistics> getCacheStatistics() async {
    return const CacheStatistics(
      entryCount: 0,
      totalSize: 0,
      maxEntries: 0,
      maxSize: 0,
      hitCount: 0,
      missCount: 0,
    );
  }

  @override
  void setMaxEntries(int maxEntries) {
    // 无缓存策略不需要设置最大条目数
  }

  @override
  void setMaxSize(int maxSize) {
    // 无缓存策略不需要设置最大大小
  }

  @override
  String generateCacheKey(RequestOptions options) {
    return '';
  }
}
