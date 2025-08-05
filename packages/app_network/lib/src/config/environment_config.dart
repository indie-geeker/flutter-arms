import 'package:app_interfaces/app_interfaces.dart';
import 'network_config.dart';

/// 环境配置管理器
///
/// 管理不同环境下的网络配置，支持运行时环境切换
class EnvironmentConfig {
  final Map<EnvironmentType, NetworkConfig> _configs = {};
  EnvironmentType _currentEnvironment = EnvironmentType.development;

  EnvironmentConfig({
    NetworkConfig? developmentConfig,
    NetworkConfig? stagingConfig,
    NetworkConfig? productionConfig,
  }) {
    if (developmentConfig != null) {
      _configs[EnvironmentType.development] = developmentConfig;
    }
    if (stagingConfig != null) {
      _configs[EnvironmentType.staging] = stagingConfig;
    }
    if (productionConfig != null) {
      _configs[EnvironmentType.production] = productionConfig;
    }
  }

  /// 设置环境配置
  void setConfig(EnvironmentType environment, NetworkConfig config) {
    _configs[environment] = config;
  }

  /// 获取环境配置
  NetworkConfig? getConfig(EnvironmentType environment) {
    return _configs[environment];
  }

  /// 获取当前环境配置
  NetworkConfig? get currentConfig => _configs[_currentEnvironment];

  /// 获取当前环境
  EnvironmentType get currentEnvironment => _currentEnvironment;

  /// 切换环境
  void switchEnvironment(EnvironmentType environment) {
    if (_configs.containsKey(environment)) {
      _currentEnvironment = environment;
    } else {
      throw ArgumentError('Environment $environment is not configured');
    }
  }

  /// 检查环境是否已配置
  bool isConfigured(EnvironmentType environment) {
    return _configs.containsKey(environment);
  }

  /// 获取所有已配置的环境
  List<EnvironmentType> get configuredEnvironments {
    return _configs.keys.toList();
  }

  /// 移除环境配置
  void removeConfig(EnvironmentType environment) {
    _configs.remove(environment);
    
    // 如果移除的是当前环境，切换到第一个可用环境
    if (_currentEnvironment == environment && _configs.isNotEmpty) {
      _currentEnvironment = _configs.keys.first;
    }
  }

  /// 清除所有配置
  void clearAll() {
    _configs.clear();
    _currentEnvironment = EnvironmentType.development;
  }

  /// 创建默认配置
  factory EnvironmentConfig.createDefault({
    required String developmentBaseUrl,
    required String stagingBaseUrl,
    required String productionBaseUrl,
    Map<String, dynamic>? defaultHeaders,
  }) {
    return EnvironmentConfig(
      developmentConfig: NetworkConfig.development(
        baseUrl: developmentBaseUrl,
        defaultHeaders: defaultHeaders,
      ),
      stagingConfig: NetworkConfig.staging(
        baseUrl: stagingBaseUrl,
        defaultHeaders: defaultHeaders,
      ),
      productionConfig: NetworkConfig.production(
        baseUrl: productionBaseUrl,
        defaultHeaders: defaultHeaders,
      ),
    );
  }

  @override
  String toString() {
    return 'EnvironmentConfig(current: $_currentEnvironment, configured: ${_configs.keys.toList()})';
  }
}
