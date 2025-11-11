
/// 缓存策略
enum CachePolicy {
  /// 普通缓存 - 有过期时间，存储在内存+磁盘
  normal,

  /// 仅内存缓存 - 进程结束后清除
  memoryOnly,

  /// 持久缓存 - 永不过期，但可手动删除
  persistent,

  /// 网络优先 - 优先从网络获取，失败才用缓存
  networkFirst,

  /// 缓存优先 - 缓存有效时不请求网络
  cacheFirst,
}