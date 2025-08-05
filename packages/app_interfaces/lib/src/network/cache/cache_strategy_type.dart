
/// 缓存策略类型枚举
enum CacheStrategyType {
  // /// 仅使用网络数据，不使用缓存
  // networkOnly,
  //
  // /// 优先使用缓存，如果没有缓存或缓存过期则使用网络数据
  // cacheFirst,
  //
  // /// 优先使用网络数据，如果网络请求失败则使用缓存
  // networkFirst,
  //
  // /// 仅使用缓存，不进行网络请求
  // cacheOnly,
  //
  // /// 先使用缓存，同时发起网络请求更新缓存
  // cacheAndNetwork,
  //
  // /// 根据请求配置动态决定缓存策略
  // dynamic,


  /// 内存缓存
  memory,

  /// 磁盘缓存
  disk,

  /// 无缓存
  none,
}