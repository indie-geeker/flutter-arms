/// 缓存统计信息
class CacheStatistics {
  /// 创建缓存统计信息
  const CacheStatistics({
    required this.entryCount,
    required this.totalSize,
    required this.maxEntries,
    required this.maxSize,
    required this.hitCount,
    required this.missCount,
  });

  /// 缓存条目数量
  final int entryCount;

  /// 缓存总大小（字节）
  final int totalSize;

  /// 最大缓存条目数
  final int maxEntries;

  /// 最大缓存大小（字节）
  final int maxSize;

  /// 缓存命中次数
  final int hitCount;

  /// 缓存未命中次数
  final int missCount;

  /// 缓存命中率
  double get hitRate {
    final total = hitCount + missCount;
    return total > 0 ? hitCount / total : 0.0;
  }

  /// 缓存使用率（条目数）
  double get entryUsageRate => maxEntries > 0 ? entryCount / maxEntries : 0.0;

  /// 缓存使用率（大小）
  double get sizeUsageRate => maxSize > 0 ? totalSize / maxSize : 0.0;
}
