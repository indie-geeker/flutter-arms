
/// 缓存统计信息
class CacheStats {
  /// 总键数
  final int totalKeys;

  /// 内存缓存键数
  final int memoryKeys;

  /// 磁盘缓存键数
  final int diskKeys;

  /// 总大小（字节）
  final int totalSize;

  /// 命中次数
  final int hitCount;

  /// 未命中次数
  final int missCount;

  CacheStats({
    required this.totalKeys,
    required this.memoryKeys,
    required this.diskKeys,
    required this.totalSize,
    required this.hitCount,
    required this.missCount,
  });

  /// 命中率
  double get hitRate =>
      hitCount + missCount > 0
          ? hitCount / (hitCount + missCount)
          : 0.0;
}