import 'package:app_interfaces/app_interfaces.dart';

/// Mock application configuration for testing.
///
/// This class implements both IEnvironmentConfig and INetWorkConfig
/// to provide a complete configuration for testing purposes.
class MockAppConfig extends BaseConfig implements IEnvironmentConfig, INetWorkConfig {
  final String _channel;
  final EnvironmentType _environmentType;
  final String _apiBaseUrl;
  final String _webSocketUrl;
  final Duration _connectTimeout;
  final Duration _receiveTimeout;
  final bool _enableVerboseLogging;
  final bool _enableCrashReporting;
  final bool _enablePerformanceMonitoring;
  final Map<String, dynamic> _additionalConfig;

  MockAppConfig({
    String channel = 'test',
    EnvironmentType environmentType = EnvironmentType.development,
    String apiBaseUrl = 'https://test-api.example.com',
    String webSocketUrl = 'wss://test-api.example.com/ws',
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    bool enableVerboseLogging = true,
    bool enableCrashReporting = false,
    bool enablePerformanceMonitoring = false,
    Map<String, dynamic>? additionalConfig,
  })  : _channel = channel,
        _environmentType = environmentType,
        _apiBaseUrl = apiBaseUrl,
        _webSocketUrl = webSocketUrl,
        _connectTimeout = connectTimeout,
        _receiveTimeout = receiveTimeout,
        _enableVerboseLogging = enableVerboseLogging,
        _enableCrashReporting = enableCrashReporting,
        _enablePerformanceMonitoring = enablePerformanceMonitoring,
        _additionalConfig = additionalConfig ?? {};

  // IEnvironmentConfig implementation

  @override
  EnvironmentType get environmentType => _environmentType;

  @override
  String get environmentName => _environmentType.name;

  @override
  bool get isProduction => _environmentType == EnvironmentType.production;

  @override
  bool get isDevelopment => _environmentType == EnvironmentType.development;

  @override
  bool get isTest => _environmentType == EnvironmentType.test;

  @override
  bool get enableVerboseLogging => _enableVerboseLogging;

  @override
  bool get enableCrashReporting => _enableCrashReporting;

  @override
  bool get enablePerformanceMonitoring => _enablePerformanceMonitoring;

  @override
  int get connectionTimeout => _connectTimeout.inMilliseconds;

  @override
  T getValue<T>(String key, T defaultValue) {
    if (_additionalConfig.containsKey(key)) {
      return _additionalConfig[key] as T;
    }
    return defaultValue;
  }

  @override
  Future<bool> switchTo(EnvironmentType environmentType) async {
    // Mock implementation - always succeeds
    return true;
  }

  // IEnvironmentConfig implementation (additional properties)

  @override
  String get apiBaseUrl => _apiBaseUrl;

  // INetWorkConfig implementation

  @override
  String get baseUrl => _apiBaseUrl;

  @override
  Duration get connectTimeout => _connectTimeout;

  @override
  Duration get receiveTimeout => _receiveTimeout;

  // IEnvironmentConfig implementation (additional properties)

  @override
  String get webSocketUrl => _webSocketUrl;

  // BaseConfig implementation

  @override
  Map<String, dynamic> toMap() {
    return {
      'channel': _channel,
      'environmentType': _environmentType.name,
      'apiBaseUrl': _apiBaseUrl,
      'webSocketUrl': _webSocketUrl,
      'connectTimeout': _connectTimeout.inMilliseconds,
      'receiveTimeout': _receiveTimeout.inMilliseconds,
      'enableVerboseLogging': _enableVerboseLogging,
      'enableCrashReporting': _enableCrashReporting,
      'enablePerformanceMonitoring': _enablePerformanceMonitoring,
      ..._additionalConfig,
    };
  }

  @override
  MockAppConfig copyWith({
    String? channel,
    EnvironmentType? environmentType,
    String? apiBaseUrl,
    String? webSocketUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    bool? enableVerboseLogging,
    bool? enableCrashReporting,
    bool? enablePerformanceMonitoring,
    Map<String, dynamic>? additionalConfig,
  }) {
    return MockAppConfig(
      channel: channel ?? _channel,
      environmentType: environmentType ?? _environmentType,
      apiBaseUrl: apiBaseUrl ?? _apiBaseUrl,
      webSocketUrl: webSocketUrl ?? _webSocketUrl,
      connectTimeout: connectTimeout ?? _connectTimeout,
      receiveTimeout: receiveTimeout ?? _receiveTimeout,
      enableVerboseLogging: enableVerboseLogging ?? _enableVerboseLogging,
      enableCrashReporting: enableCrashReporting ?? _enableCrashReporting,
      enablePerformanceMonitoring: enablePerformanceMonitoring ?? _enablePerformanceMonitoring,
      additionalConfig: additionalConfig ?? _additionalConfig,
    );
  }

  // Additional getter for channel
  String get channel => _channel;

  @override
  CachePolicyConfig get cachePolicyConfig => const CachePolicyConfig(
        defaultPolicy: CachePolicy.networkFirst,
        defaultMaxAge: Duration(minutes: 5),
        enableDiskCache: false,
      );

  @override
  RetryConfig get retryConfig => const RetryConfig(
        maxRetries: 3,
        initialDelay: Duration(milliseconds: 500),
      );
}
