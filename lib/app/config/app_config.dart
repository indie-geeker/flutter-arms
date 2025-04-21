/// 应用配置类
/// 专注于非 UI 相关的应用配置
class AppConfig {
  // 应用基本信息
  final String appName;
  final String appVersion;
  final String buildNumber;
  
  // 功能开关
  final bool enableOfflineMode;
  final bool enablePushNotifications;
  
  // 缓存策略
  final Duration cacheDuration;
  final int maxCacheSize;
  
  // 网络设置
  final Duration connectionTimeout;
  final Duration receiveTimeout;
  
  AppConfig({
    required this.appName,
    required this.appVersion,
    required this.buildNumber,
    this.enableOfflineMode = true,
    this.enablePushNotifications = true,
    this.cacheDuration = const Duration(days: 7),
    this.maxCacheSize = 100 * 1024 * 1024, // 100MB
    this.connectionTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
  });
}
