/**
 * Description:
 * Author: wen
 * Date: 10/16/25
 **/

/// Cache decision result
class CacheDecision {
  const CacheDecision({
    required this.useCache,
    required this.fetchFromNetwork,
    required this.updateCache,
  });

  /// Whether to return cached data
  final bool useCache;

  /// Whether to fetch from network
  final bool fetchFromNetwork;

  /// Whether to update cache with network response
  final bool updateCache;

  // Predefined decisions
  static const CacheDecision cacheOnly = CacheDecision(
    useCache: true,
    fetchFromNetwork: false,
    updateCache: false,
  );

  static const CacheDecision networkOnly = CacheDecision(
    useCache: false,
    fetchFromNetwork: true,
    updateCache: true,
  );

  static const CacheDecision cacheFirst = CacheDecision(
    useCache: true,
    fetchFromNetwork: true,
    updateCache: true,
  );

  static const CacheDecision networkFirst = CacheDecision(
    useCache: false,
    fetchFromNetwork: true,
    updateCache: true,
  );

  static const CacheDecision cacheAndNetwork = CacheDecision(
    useCache: true,
    fetchFromNetwork: true,
    updateCache: true,
  );
}