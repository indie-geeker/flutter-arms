import '../common/enums/environment_type.dart';

/// 环境配置接口
/// 
/// 提供应用运行环境的配置信息，如API基础地址、环境类型等。
/// 允许在不同环境（开发、测试、生产等）之间切换而无需修改代码。
abstract class IEnvironmentConfig {
  /// 获取当前环境类型
  EnvironmentType get environmentType;

  /// 获取环境名称（如 "dev", "test", "prod"）
  String get environmentName;

  /// 获取API基础地址
  String get apiBaseUrl;

  /// 获取WebSocket地址（如果应用使用WebSocket）
  String get webSocketUrl;

  /// 判断当前是否为生产环境
  bool get isProduction;

  /// 判断当前是否为开发环境
  bool get isDevelopment;

  /// 判断当前是否为测试环境
  bool get isTest;

  /// 获取应用当前配置的超时时间（毫秒）
  int get connectionTimeout;

  /// 获取是否启用详细日志
  bool get enableVerboseLogging;

  /// 获取是否启用崩溃报告
  bool get enableCrashReporting;

  /// 获取是否启用性能监控
  bool get enablePerformanceMonitoring;

  /// 获取配置值
  /// 
  /// [key] 配置项键名
  /// [defaultValue] 默认值，当配置项不存在时返回
  T getValue<T>(String key, T defaultValue);

  /// 切换到指定环境
  /// 
  /// [environmentType] 目标环境类型
  /// 
  /// 返回 [bool] 表示切换是否成功
  Future<bool> switchTo(EnvironmentType environmentType);
}
