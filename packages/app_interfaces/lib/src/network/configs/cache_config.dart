
/// 缓存配置
class CacheConfig {
  /// 创建缓存配置
  const CacheConfig({
    this.maxAge = const Duration(minutes: 10),
    this.maxStale = const Duration(days: 7),
    this.forceRefresh = false,
    this.primaryKey,
    this.subKey,
  });

  /// 缓存最大有效期
  final Duration maxAge;

  /// 缓存最大过期时间（过期后仍可使用，但会尝试刷新）
  final Duration maxStale;

  /// 是否强制刷新（忽略缓存）
  final bool forceRefresh;

  /// 缓存主键
  final String? primaryKey;

  /// 缓存子键
  final String? subKey;
}
