/**
 * Description:
 * Author: wen
 * Date: 10/16/25
 **/
enum CachePolicy {
  /// Only fetch from network, never use cache
  networkOnly,

  /// Try cache first, fallback to network if cache miss or expired
  cacheFirst,

  /// Try network first, fallback to cache if network fails
  networkFirst,

  /// Only use cache, never fetch from network
  cacheOnly,

  /// Return cache immediately, then fetch from network to update cache
  cacheAndNetwork,
}