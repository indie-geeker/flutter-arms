import 'package:app_interfaces/src/network/models/api_response.dart';

import '../models/request_options.dart';
import 'cache_statistics.dart';

/// 缓存策略接口
///
/// 定义网络请求的缓存策略，如何存储和获取缓存数据
abstract class ICacheStrategy {
  /// 从缓存中获取数据
  ///
  /// [options] 请求选项
  ///
  /// 返回缓存的响应结果，如果没有缓存则返回null
  Future<ApiResponse<T>?> getCache<T>(RequestOptions options);

  /// 将响应数据保存到缓存
  ///
  /// [response] 响应结果
  ///
  /// 返回是否缓存成功
  Future<bool> saveCache<T>(ApiResponse<T> response);

  /// 是否应该从网络获取数据
  ///
  /// [options] 请求选项
  /// [cachedResponse] 缓存的响应结果，如果没有缓存则为null
  ///
  /// 返回是否应该从网络获取数据
  bool shouldFetchFromNetwork<T>(
      RequestOptions options,
      ApiResponse<T>? cachedResponse,
      );

  /// 是否支持缓存该请求
  ///
  /// [options] 请求选项
  ///
  /// 返回是否支持缓存
  bool isCacheSupported(RequestOptions options);

  /// 生成缓存键
  ///
  /// [options] 请求选项
  ///
  /// 返回缓存键
  String generateCacheKey(RequestOptions options);

  /// 清除特定请求的缓存
  ///
  /// [options] 请求选项
  ///
  /// 返回是否清除成功
  Future<bool> invalidateCache(RequestOptions options);

  /// 清除所有缓存
  ///
  /// 返回是否清除成功
  Future<bool> clearAllCache();

  /// 获取缓存统计信息
  ///
  /// 返回缓存统计信息
  Future<CacheStatistics> getCacheStatistics();

  /// 设置最大缓存条目数
  ///
  /// [maxEntries] 最大缓存条目数
  void setMaxEntries(int maxEntries);

  /// 设置最大缓存大小（字节）
  ///
  /// [maxSize] 最大缓存大小（字节）
  void setMaxSize(int maxSize);
}