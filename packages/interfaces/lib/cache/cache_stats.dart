/// Cache statistics.
class CacheStats {
  /// Total number of keys.
  final int totalKeys;

  /// Number of memory-cached keys.
  final int memoryKeys;

  /// Number of disk-cached keys.
  final int diskKeys;

  /// Total size in bytes.
  final int totalSize;

  /// Number of cache hits.
  final int hitCount;

  /// Number of cache misses.
  final int missCount;

  CacheStats({
    required this.totalKeys,
    required this.memoryKeys,
    required this.diskKeys,
    required this.totalSize,
    required this.hitCount,
    required this.missCount,
  });

  /// Cache hit rate.
  double get hitRate =>
      hitCount + missCount > 0 ? hitCount / (hitCount + missCount) : 0.0;
}
