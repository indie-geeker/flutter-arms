import 'cache_policy.dart';

/**
 * Description:
 * Author: wen
 * Date: 10/16/25
 **/
class CachePolicyConfig {
  const CachePolicyConfig({
    this.defaultPolicy = CachePolicy.networkFirst,
    this.defaultMaxAge = const Duration(minutes: 10),
    this.defaultMaxStale = const Duration(days: 7),
    this.enableDiskCache = true,
    this.diskCacheMaxEntries = 50,
    this.memoryCacheMaxEntries = 100,
  });

  /// Default cache policy for requests
  final CachePolicy defaultPolicy;

  /// Default cache validity duration
  final Duration defaultMaxAge;

  /// Duration after which stale cache can still be used as fallback
  final Duration defaultMaxStale;

  /// Whether to enable disk caching
  final bool enableDiskCache;

  /// Maximum disk cache entries
  final int diskCacheMaxEntries;

  /// Maximum memory cache entries
  final int memoryCacheMaxEntries;
}