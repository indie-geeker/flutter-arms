import 'package:app_core/app_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Base application configuration that extends BaseConfig and implements IEnvironmentConfig.
///
/// This class provides a type-safe way to access all configuration values
/// loaded from environment files (.env). It serves as the foundation for
/// environment-specific configurations.
///
/// Usage:
/// ```dart
/// await dotenv.load(fileName: '.env.development');
/// final config = DevelopmentConfig();
/// ```
class BaseAppConfig extends BaseConfig implements IEnvironmentConfig, INetWorkConfig {
  /// Application name
  final String appName;

  /// Application channel (e.g., 'development', 'staging', 'production')
  final String channel;

  /// Environment type
  final EnvironmentType environment;

  /// API base URL
  @override
  final String apiBaseUrl;

  /// API version
  final String apiVersion;

  /// WebSocket URL
  @override
  final String webSocketUrl;

  /// Connect timeout duration
  @override
  final Duration connectTimeout;

  /// Receive timeout duration
  @override
  final Duration receiveTimeout;

  /// Send timeout duration
  final Duration sendTimeout;

  /// Whether verbose logging is enabled
  @override
  final bool enableVerboseLogging;

  /// Whether crash reporting is enabled
  @override
  final bool enableCrashReporting;

  /// Whether performance monitoring is enabled
  @override
  final bool enablePerformanceMonitoring;

  /// Whether analytics is enabled
  final bool enableAnalytics;

  /// Maximum cache size in MB
  final int cacheMaxSizeMB;

  /// Whether encryption is enabled for storage
  final bool enableEncryption;

  /// Whether debug mode is enabled
  final bool debugMode;

  /// Whether to show performance overlay
  final bool showPerformanceOverlay;

  /// Creates a base application configuration.
  ///
  /// This constructor loads all values from the dotenv instance.
  /// Make sure to call `dotenv.load()` before creating an instance.
  BaseAppConfig({
    required this.appName,
    required this.channel,
    required this.environment,
    required this.apiBaseUrl,
    required this.apiVersion,
    required this.webSocketUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
    required this.enableVerboseLogging,
    required this.enableCrashReporting,
    required this.enablePerformanceMonitoring,
    required this.enableAnalytics,
    required this.cacheMaxSizeMB,
    required this.enableEncryption,
    required this.debugMode,
    required this.showPerformanceOverlay,
  });

  /// Creates a configuration from environment variables loaded by flutter_dotenv.
  ///
  /// Throws an exception if required environment variables are missing.
  factory BaseAppConfig.fromEnv() {
    return BaseAppConfig(
      appName: dotenv.get('APP_NAME', fallback: 'FlutterArms Example'),
      channel: dotenv.get('APP_CHANNEL', fallback: 'default'),
      environment: _parseEnvironment(
        dotenv.get('APP_ENVIRONMENT', fallback: 'development'),
      ),
      apiBaseUrl: dotenv.get('API_BASE_URL'),
      apiVersion: dotenv.get('API_VERSION', fallback: 'v1'),
      webSocketUrl: dotenv.get('WEB_SOCKET_URL'),
      connectTimeout: Duration(
        milliseconds: int.parse(dotenv.get('CONNECT_TIMEOUT', fallback: '30000')),
      ),
      receiveTimeout: Duration(
        milliseconds: int.parse(dotenv.get('RECEIVE_TIMEOUT', fallback: '30000')),
      ),
      sendTimeout: Duration(
        milliseconds: int.parse(dotenv.get('SEND_TIMEOUT', fallback: '30000')),
      ),
      enableVerboseLogging: _parseBool(
        dotenv.get('ENABLE_VERBOSE_LOGGING', fallback: 'false'),
      ),
      enableCrashReporting: _parseBool(
        dotenv.get('ENABLE_CRASH_REPORTING', fallback: 'false'),
      ),
      enablePerformanceMonitoring: _parseBool(
        dotenv.get('ENABLE_PERFORMANCE_MONITORING', fallback: 'false'),
      ),
      enableAnalytics: _parseBool(
        dotenv.get('ENABLE_ANALYTICS', fallback: 'false'),
      ),
      cacheMaxSizeMB: int.parse(
        dotenv.get('CACHE_MAX_SIZE_MB', fallback: '100'),
      ),
      enableEncryption: _parseBool(
        dotenv.get('ENABLE_ENCRYPTION', fallback: 'false'),
      ),
      debugMode: _parseBool(
        dotenv.get('DEBUG_MODE', fallback: 'false'),
      ),
      showPerformanceOverlay: _parseBool(
        dotenv.get('SHOW_PERFORMANCE_OVERLAY', fallback: 'false'),
      ),
    );
  }

  // IEnvironmentConfig implementation

  @override
  EnvironmentType get environmentType => environment;

  @override
  String get environmentName => environment.name;

  @override
  bool get isProduction => environment.isProduction;

  @override
  bool get isDevelopment => environment.isDevelopment;

  @override
  bool get isTest => environment.isTest;

  @override
  int get connectionTimeout => connectTimeout.inMilliseconds;

  @override
  T getValue<T>(String key, T defaultValue) {
    // Provide access to environment variables through the interface
    final value = dotenv.maybeGet(key);
    if (value == null) return defaultValue;

    // Try to convert the string value to the requested type
    if (T == String) return value as T;
    if (T == int) return int.tryParse(value) as T? ?? defaultValue;
    if (T == double) return double.tryParse(value) as T? ?? defaultValue;
    if (T == bool) return _parseBool(value) as T;

    return defaultValue;
  }

  @override
  Future<bool> switchTo(EnvironmentType environmentType) async {
    // Switching environments requires reloading the app with a different .env file
    // This is typically not supported at runtime in production apps
    throw UnimplementedError(
      'Environment switching is not supported with dotenv-based configuration. '
      'Please restart the app with the desired environment.',
    );
  }

  // INetWorkConfig implementation

  @override
  String get baseUrl => apiBaseUrl;

  @override
  ResponseParser? get responseParser => null;

  // BaseConfig implementation

  @override
  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'channel': channel,
      'environment': environment.name,
      'apiBaseUrl': apiBaseUrl,
      'apiVersion': apiVersion,
      'webSocketUrl': webSocketUrl,
      'connectTimeout': connectTimeout.inMilliseconds,
      'receiveTimeout': receiveTimeout.inMilliseconds,
      'sendTimeout': sendTimeout.inMilliseconds,
      'enableVerboseLogging': enableVerboseLogging,
      'enableCrashReporting': enableCrashReporting,
      'enablePerformanceMonitoring': enablePerformanceMonitoring,
      'enableAnalytics': enableAnalytics,
      'cacheMaxSizeMB': cacheMaxSizeMB,
      'enableEncryption': enableEncryption,
      'debugMode': debugMode,
      'showPerformanceOverlay': showPerformanceOverlay,
    };
  }

  @override
  String toString() {
    return 'BaseAppConfig('
        'appName: $appName, '
        'channel: $channel, '
        'environment: ${environment.name}, '
        'apiBaseUrl: $apiBaseUrl'
        ')';
  }

  @override
  BaseAppConfig copyWith({
    String? appName,
    String? channel,
    EnvironmentType? environment,
    String? apiBaseUrl,
    String? apiVersion,
    String? webSocketUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? enableVerboseLogging,
    bool? enableCrashReporting,
    bool? enablePerformanceMonitoring,
    bool? enableAnalytics,
    int? cacheMaxSizeMB,
    bool? enableEncryption,
    bool? debugMode,
    bool? showPerformanceOverlay,
  }) {
    return BaseAppConfig(
      appName: appName ?? this.appName,
      channel: channel ?? this.channel,
      environment: environment ?? this.environment,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      apiVersion: apiVersion ?? this.apiVersion,
      webSocketUrl: webSocketUrl ?? this.webSocketUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      enableVerboseLogging: enableVerboseLogging ?? this.enableVerboseLogging,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      enablePerformanceMonitoring: enablePerformanceMonitoring ?? this.enablePerformanceMonitoring,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      cacheMaxSizeMB: cacheMaxSizeMB ?? this.cacheMaxSizeMB,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      debugMode: debugMode ?? this.debugMode,
      showPerformanceOverlay: showPerformanceOverlay ?? this.showPerformanceOverlay,
    );
  }

  // Helper methods

  static EnvironmentType _parseEnvironment(String value) {
    switch (value.toLowerCase()) {
      case 'development':
      case 'dev':
        return EnvironmentType.development;
      case 'staging':
      case 'stage':
        return EnvironmentType.staging;
      case 'production':
      case 'prod':
        return EnvironmentType.production;
      case 'test':
        return EnvironmentType.test;
      default:
        return EnvironmentType.development;
    }
  }

  static bool _parseBool(String value) {
    return value.toLowerCase() == 'true' || value == '1';
  }
}
