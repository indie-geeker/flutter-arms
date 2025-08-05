
/// 缓存状态枚举
enum CacheStatus {
  /// 没有缓存
  noCache,

  /// 缓存有效
  valid,

  /// 缓存过期但可用
  stale,

  /// 缓存过期且不可用
  expired,
}
