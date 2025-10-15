import 'package:app_interfaces/app_interfaces.dart';

/// [EnvironmentConfig] 实现 [IEnvironmentConfig] 接口
///
/// 提供应用运行环境的配置信息，如API基础地址、环境类型等。
///
/// @deprecated This class is deprecated in favor of custom configuration classes
/// that extend [BaseConfig] and implement [IEnvironmentConfig]. This allows for
/// type-safe, validated configuration through dependency injection.
///
/// Migration example:
/// ```dart
/// // Old way (deprecated):
/// final config = EnvironmentConfig(
///   defaultEnvironment: EnvironmentType.development,
///   configs: {...},
/// );
///
/// // New way (recommended):
/// class MyAppConfig extends BaseConfig implements IEnvironmentConfig {
///   final String apiBaseUrl;
///   final EnvironmentType environment;
///   // ... other fields with proper types
///
///   @override
///   EnvironmentType get environmentType => environment;
///   // ... implement other IEnvironmentConfig methods
/// }
///
/// final config = MyAppConfig(...);
/// ```
@Deprecated(
  'Use custom configuration classes that extend BaseConfig instead. '
  'This class will be removed in a future version.',
)
class EnvironmentConfig implements IEnvironmentConfig {
  static const String _envTypeKey = 'app_environment_type';

  EnvironmentType _environmentType;
  final Map<String, dynamic> _configMap;

  final IKeyValueStorage? _keyValueStorage;

  /// 创建环境配置实例
  ///
  /// [defaultEnvironment] 默认环境类型
  /// [configs] 各环境的配置映射表
  EnvironmentConfig({
    required EnvironmentType defaultEnvironment,
    required Map<EnvironmentType, Map<String, dynamic>> configs,
    IKeyValueStorage? storage,
  })  : _environmentType = defaultEnvironment,
        // 创建配置映射表的深拷贝，避免直接引用外部对象导致的状态修改问题
        _configMap =
            Map<String, dynamic>.from(configs[defaultEnvironment] ?? {}),
        _allConfigs = configs,
        _keyValueStorage = storage;

  /// 初始化环境配置
  Future<void> initialize() async {
    // 尝试从持久化存储中恢复环境设置
    final savedEnvIndex =  await _keyValueStorage?.getInt(_envTypeKey);
    if (savedEnvIndex != null) {
      try {
        final envType = EnvironmentType.values[savedEnvIndex];
        _environmentType = envType;

        // 根据恢复的环境类型更新配置映射表
        final config = _allConfigs[envType];
        if (config != null) {
          _configMap.clear();
          _configMap.addAll(Map<String, dynamic>.from(config));
        }
      } catch (_) {
        // 如果保存的环境类型无效，则继续使用默认环境
      }
    } else {
      // 如果没有保存的环境类型，确保使用默认环境的配置
      final config = _allConfigs[_environmentType];
      if (config != null) {
        _configMap.clear();
        _configMap.addAll(Map<String, dynamic>.from(config));
      }
    }
  }

  @override
  EnvironmentType get environmentType => _environmentType;

  @override
  String get environmentName => environmentType.name; // 返回枚举值的原始名称，而非本地化的显示名称

  @override
  String get apiBaseUrl => getValue('apiBaseUrl', '');

  @override
  String get webSocketUrl => getValue('webSocketUrl', '');

  @override
  bool get isProduction => environmentType.isProduction;

  @override
  bool get isDevelopment => environmentType.isDevelopment;

  @override
  bool get isTest => environmentType.isTest;

  @override
  int get connectionTimeout => getValue('connectionTimeout', 30000);

  @override
  bool get enableVerboseLogging =>
      getValue('enableVerboseLogging', !isProduction);

  @override
  bool get enableCrashReporting =>
      getValue('enableCrashReporting', isProduction);

  @override
  bool get enablePerformanceMonitoring =>
      getValue('enablePerformanceMonitoring', isProduction);

  @override
  T getValue<T>(String key, T defaultValue) {
    final value = _configMap[key];
    if (value != null && value is T) {
      return value;
    }
    return defaultValue;
  }

  /// 当前环境的所有配置信息
  final Map<EnvironmentType, Map<String, dynamic>> _allConfigs;

  @override
  Future<bool> switchTo(EnvironmentType environmentType) async {
    try {
      // 保存环境类型到本地存储
      await _keyValueStorage?.setInt(_envTypeKey, environmentType.index);
      _environmentType = environmentType;

      // 更新配置数据映射表
      final newConfig = _allConfigs[environmentType];
      if (newConfig != null) {
        _configMap.clear();
        _configMap.addAll(Map<String, dynamic>.from(newConfig));
      }

      return true;
    } catch (_) {
      return false;
    }
  }
}
