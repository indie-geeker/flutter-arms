import 'package:flutter/foundation.dart';

/// 环境枚举
enum Environment { dev, staging, prod }

/// 环境配置类
class EnvConfig {
  final String apiBaseUrl;
  final String appName;
  final bool enableLogging;
  
  EnvConfig({
    required this.apiBaseUrl,
    required this.appName,
    required this.enableLogging,
  });
  
  /// 根据环境获取对应配置
  static EnvConfig getConfig(Environment env) {
    switch (env) {
      case Environment.dev:
        return EnvConfig(
          apiBaseUrl: 'https://dev-api.himusic.com',
          appName: 'ARMS(开发版)',
          enableLogging: true,
        );
      case Environment.staging:
        return EnvConfig(
          apiBaseUrl: 'https://staging-api.himusic.com',
          appName: 'ARMS(测试版)',
          enableLogging: true,
        );
      case Environment.prod:
        return EnvConfig(
          apiBaseUrl: 'https://api.himusic.com',
          appName: 'ARMS',
          enableLogging: kDebugMode,
        );
    }
  }
}
