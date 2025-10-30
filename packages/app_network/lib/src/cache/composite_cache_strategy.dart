import 'package:app_interfaces/app_interfaces.dart';

import 'cache_policy_resolver.dart';

/// Composite cache strategy supporting multiple policies
class CompositeCacheStrategy implements ICacheStrategy {
  final ICacheStrategy _memoryCache;
  final ICacheStrategy? _diskCache;
  final ICachePolicyResolver _policyResolver;
  final CachePolicyConfig _config;

  CompositeCacheStrategy({
    required ICacheStrategy memoryCache,
    ICacheStrategy? diskCache,
    ICachePolicyResolver? policyResolver,
    CachePolicyConfig? config,
  })  : _memoryCache = memoryCache,
        _diskCache = diskCache,
        _policyResolver = policyResolver ?? CachePolicyResolver(),
        _config = config ?? const CachePolicyConfig();

  @override
  Future<ApiResponse<T>?> getCache<T>(RequestOptions options) async {
    // Try memory first, then disk
    var cached = await _memoryCache.getCache<T>(options);
    if (cached == null && _diskCache != null) {
      cached = await _diskCache.getCache<T>(options);
      // Promote to memory cache
      if (cached != null) {
        await _memoryCache.saveCache(cached);
      }
    }
    return cached;
  }

  @override
  Future<bool> saveCache<T>(ApiResponse<T> response) async {
    final memoryResult = await _memoryCache.saveCache(response);
    final diskResult = _diskCache != null
        ? await _diskCache.saveCache(response)
        : true;
    return memoryResult || diskResult;
  }

  @override
  bool shouldFetchFromNetwork<T>(
      RequestOptions options,
      ApiResponse<T>? cachedResponse,
      ) {
    final policy = _getCachePolicyForRequest(options);
    final isExpired = _isCacheExpired(options, cachedResponse);

    final decision = _policyResolver.resolve<T>(
      policy: policy,
      options: options,
      cachedResponse: cachedResponse,
      isCacheExpired: isExpired,
      isCacheStale: false, // Can enhance with stale detection
    );

    return decision.fetchFromNetwork;
  }

  CachePolicy _getCachePolicyForRequest(RequestOptions options) {
    // Check request-specific cache policy
    final policyName = options.extra['cache_policy'] as String?;
    if (policyName != null) {
      return CachePolicy.values.firstWhere(
            (p) => p.name == policyName,
        orElse: () => _config.defaultPolicy,
      );
    }
    return _config.defaultPolicy;
  }

  bool _isCacheExpired<T>(RequestOptions options, ApiResponse<T>? response) {
    if (response == null) return true;
    final maxAge = _getCacheMaxAge(options);
    final cacheTime = response.extra['_cache_time'] as DateTime?;
    if (cacheTime == null) return true;
    return DateTime.now().isAfter(cacheTime.add(maxAge));
  }

  Duration _getCacheMaxAge(RequestOptions options) {
    return options.extra['cache_max_age'] as Duration? ??
        _config.defaultMaxAge;
  }

  // Implement other ICacheStrategy methods...
  @override
  bool isCacheSupported(RequestOptions options) {
    return _memoryCache.isCacheSupported(options);
  }

  @override
  String generateCacheKey(RequestOptions options) {
    return _memoryCache.generateCacheKey(options);
  }

  @override
  Future<bool> invalidateCache(RequestOptions options) async {
    final memoryResult = await _memoryCache.invalidateCache(options);
    final diskResult = _diskCache != null
        ? await _diskCache.invalidateCache(options)
        : true;
    return memoryResult && diskResult;
  }

  @override
  Future<bool> clearAllCache() async {
    final memoryResult = await _memoryCache.clearAllCache();
    final diskResult = _diskCache != null
        ? await _diskCache.clearAllCache()
        : true;
    return memoryResult && diskResult;
  }

  @override
  Future<CacheStatistics> getCacheStatistics() async {
    return await _memoryCache.getCacheStatistics();
  }

  @override
  void setMaxEntries(int maxEntries) {
    _memoryCache.setMaxEntries(maxEntries);
    _diskCache?.setMaxEntries(maxEntries);
  }

  @override
  void setMaxSize(int maxSize) {
    _memoryCache.setMaxSize(maxSize);
    _diskCache?.setMaxSize(maxSize);
  }
}