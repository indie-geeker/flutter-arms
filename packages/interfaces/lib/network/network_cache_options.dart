import '../cache/cache_policy.dart';

/// 网络缓存配置
///
/// 通过 IHttpClient 的 cacheOptions 参数传入
class NetworkCacheOptions {
  /// 用于在 Dio extra 中存储缓存配置的 key
  static const String extraKey = 'network_cache_options';

  /// 是否启用缓存
  final bool enabled;

  /// 缓存时长（null 表示使用默认时长）
  final Duration? duration;

  /// 缓存策略
  final CachePolicy policy;

  /// 自定义缓存键（可选）
  final String? cacheKey;

  /// 是否使用哈希缓存键
  final bool useHashKey;

  const NetworkCacheOptions({
    this.enabled = false,
    this.duration,
    this.policy = CachePolicy.normal,
    this.cacheKey,
    this.useHashKey = false,
  });
}
