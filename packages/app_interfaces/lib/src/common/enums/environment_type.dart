/// 应用环境类型枚举
///
/// 用于区分应用的不同运行环境，如开发、测试、预发布和生产环境。
/// 在 IEnvironmentConfig 接口中使用，用于配置和切换不同环境。
enum EnvironmentType {
  /// 开发环境 - 用于本地开发和调试
  development,

  /// 测试环境 - 用于自动化测试和QA测试
  test,

  /// 预发布环境 - 与生产环境相似但用于最终验证
  staging,

  /// 生产环境 - 最终用户使用的环境
  production,

  /// 演示环境 - 用于演示目的，通常包含模拟数据
  demo;

  /// 获取环境类型的友好名称
  String get displayName {
    switch (this) {
      case EnvironmentType.development:
        return '开发环境';
      case EnvironmentType.test:
        return '测试环境';
      case EnvironmentType.staging:
        return '预发布环境';
      case EnvironmentType.production:
        return '生产环境';
      case EnvironmentType.demo:
        return '演示环境';
    }
  }

  /// 判断当前环境是否为开发环境
  bool get isDevelopment => this == EnvironmentType.development;

  /// 判断当前环境是否为测试环境
  bool get isTest => this == EnvironmentType.test;

  /// 判断当前环境是否为预发布环境
  bool get isStaging => this == EnvironmentType.staging;

  /// 判断当前环境是否为生产环境
  bool get isProduction => this == EnvironmentType.production;

  /// 判断当前环境是否为演示环境
  bool get isDemo => this == EnvironmentType.demo;
}
