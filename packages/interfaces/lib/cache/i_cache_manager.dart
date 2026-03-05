import 'cache_policy.dart';
import 'cache_stats.dart';

/// Cache manager interface.
///
/// Provides multi-level caching (memory + disk) with configurable TTL
/// and eviction policies. Implementations live in `packages/modules/module_cache`.
abstract class ICacheManager {
  /// Initializes the cache subsystem.
  Future<void> init();

  /// Stores [value] under [key] with an optional [duration] (TTL).
  ///
  /// When [duration] is `null`, the module's default TTL is used.
  /// [policy] controls eviction behavior (see [CachePolicy]).
  Future<void> put<T>(
    String key,
    T value, {
    Duration? duration,
    CachePolicy policy = CachePolicy.normal,
  });

  /// Retrieves the cached value for [key], or `null` if missing/expired.
  Future<T?> get<T>(String key);

  /// Retrieves the cached value for [key], returning [defaultValue] if absent.
  Future<T> getOrDefault<T>(String key, T defaultValue);

  /// Removes the entry for [key].
  Future<void> remove(String key);

  /// Clears all cached entries.
  Future<void> clear();

  /// Returns `true` if [key] exists and has not expired.
  Future<bool> containsKey(String key);

  /// Returns the total cache size in bytes.
  Future<int> getCacheSize();

  /// Evicts all expired entries.
  Future<void> clearExpired();

  /// Returns cache hit/miss statistics.
  Future<CacheStats> getStats();
}
