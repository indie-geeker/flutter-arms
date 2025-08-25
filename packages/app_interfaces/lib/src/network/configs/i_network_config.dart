abstract class INetworkConfig {
  /// 基础URL
  String get baseUrl;

  /// 请求超时时间（单位：毫秒）
  int get connectTimeout;

  int get receiveTimeout;

  /// 是否启用缓存
  bool get enableCache;

  /// 缓存过期时间（单位：毫秒）
  int get cacheExpiry;

  /// 是否启用日志
  bool get enableLogging;

  /// 是否启用重试机制
  bool get enableRetry;

  /// 重试次数
  int get retryCount;

  /// 重试延迟时间（单位：毫秒）
  int get retryDelay;
}