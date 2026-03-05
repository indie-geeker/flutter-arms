import '../cache/cache_policy.dart';

/// Network cache configuration.
///
/// Passed via the `cacheOptions` parameter of IHttpClient.
class NetworkCacheOptions {
  /// Key used to store cache config in Dio extras.
  static const String extraKey = 'network_cache_options';

  /// Whether caching is enabled.
  final bool enabled;

  /// Cache duration (null uses the default duration).
  final Duration? duration;

  /// Cache policy.
  final CachePolicy policy;

  /// Custom cache key (optional).
  final String? cacheKey;

  /// Whether to use a hashed cache key.
  final bool useHashKey;

  const NetworkCacheOptions({
    this.enabled = false,
    this.duration,
    this.policy = CachePolicy.normal,
    this.cacheKey,
    this.useHashKey = false,
  });
}
