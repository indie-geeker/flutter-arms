import 'package:flutter/material.dart';
import 'env_config.dart';
import 'app_config.dart';
import 'services_config.dart';

/// 配置管理器 - 单例模式
/// 专注于管理非 UI 相关的配置（环境配置、API 密钥等）
class ConfigManager {
  static final ConfigManager _instance = ConfigManager._internal();
  
  factory ConfigManager() => _instance;
  
  ConfigManager._internal();
  
  late EnvConfig envConfig;
  late AppConfig appConfig;
  late ServicesConfig servicesConfig;
  
  /// 初始化配置
  Future<void> initialize(Environment environment) async {
    // 加载环境配置
    envConfig = EnvConfig.getConfig(environment);
    
    // 加载应用配置
    appConfig = AppConfig(
      appName: envConfig.appName,
      appVersion: '1.0.0',
      buildNumber: '1',
    );
    
    // 加载服务配置
    servicesConfig = ServicesConfig(
      musicApiKey: '这里应该是从安全存储或环境变量获取的密钥',
    );
    
    // 可以在这里添加更多配置初始化逻辑
    // 例如从本地存储或远程服务器加载配置
  }
}
