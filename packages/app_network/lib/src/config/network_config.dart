import 'package:app_interfaces/app_interfaces.dart';

/// 网络配置类
///
/// 管理网络请求的各种配置参数
class NetworkConfig {
  final String baseUrl;
  final Map<String, dynamic> defaultHeaders;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;
  final bool enableRetry;
  final int maxRetries;
  final Duration retryDelay;
  final bool enableCache;
  final Duration cacheTtl;
  final EnvironmentType environment;

  const NetworkConfig({
    required this.baseUrl,
    this.defaultHeaders = const {},
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.enableLogging = true,
    this.enableRetry = true,
    this.maxRetries = 3,
    this.retryDelay = const Duration(milliseconds: 500),
    this.enableCache = true,
    this.cacheTtl = const Duration(minutes: 5),
    this.environment = EnvironmentType.development,
  });

  /// 创建开发环境配置
  factory NetworkConfig.development({
    required String baseUrl,
    Map<String, dynamic>? defaultHeaders,
  }) {
    return NetworkConfig(
      baseUrl: baseUrl,
      defaultHeaders: defaultHeaders ?? {},
      environment: EnvironmentType.development,
      enableLogging: true,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    );
  }

  /// 创建测试环境配置
  factory NetworkConfig.staging({
    required String baseUrl,
    Map<String, dynamic>? defaultHeaders,
  }) {
    return NetworkConfig(
      baseUrl: baseUrl,
      defaultHeaders: defaultHeaders ?? {},
      environment: EnvironmentType.staging,
      enableLogging: true,
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
      sendTimeout: const Duration(seconds: 25),
    );
  }

  /// 创建生产环境配置
  factory NetworkConfig.production({
    required String baseUrl,
    Map<String, dynamic>? defaultHeaders,
  }) {
    return NetworkConfig(
      baseUrl: baseUrl,
      defaultHeaders: defaultHeaders ?? {},
      environment: EnvironmentType.production,
      enableLogging: false,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      maxRetries: 2,
      cacheTtl: const Duration(minutes: 10),
    );
  }

  /// 复制并修改配置
  NetworkConfig copyWith({
    String? baseUrl,
    Map<String, dynamic>? defaultHeaders,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? enableLogging,
    bool? enableRetry,
    int? maxRetries,
    Duration? retryDelay,
    bool? enableCache,
    Duration? cacheTtl,
    EnvironmentType? environment,
  }) {
    return NetworkConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      enableLogging: enableLogging ?? this.enableLogging,
      enableRetry: enableRetry ?? this.enableRetry,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      enableCache: enableCache ?? this.enableCache,
      cacheTtl: cacheTtl ?? this.cacheTtl,
      environment: environment ?? this.environment,
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'baseUrl': baseUrl,
      'defaultHeaders': defaultHeaders,
      'connectTimeout': connectTimeout.inMilliseconds,
      'receiveTimeout': receiveTimeout.inMilliseconds,
      'sendTimeout': sendTimeout.inMilliseconds,
      'enableLogging': enableLogging,
      'enableRetry': enableRetry,
      'maxRetries': maxRetries,
      'retryDelay': retryDelay.inMilliseconds,
      'enableCache': enableCache,
      'cacheTtl': cacheTtl.inMilliseconds,
      'environment': environment.name,
    };
  }

  /// 从 Map 创建配置
  factory NetworkConfig.fromMap(Map<String, dynamic> map) {
    return NetworkConfig(
      baseUrl: map['baseUrl'] as String,
      defaultHeaders: Map<String, dynamic>.from(map['defaultHeaders'] ?? {}),
      connectTimeout: Duration(milliseconds: map['connectTimeout'] as int),
      receiveTimeout: Duration(milliseconds: map['receiveTimeout'] as int),
      sendTimeout: Duration(milliseconds: map['sendTimeout'] as int),
      enableLogging: map['enableLogging'] as bool? ?? true,
      enableRetry: map['enableRetry'] as bool? ?? true,
      maxRetries: map['maxRetries'] as int? ?? 3,
      retryDelay: Duration(milliseconds: map['retryDelay'] as int? ?? 500),
      enableCache: map['enableCache'] as bool? ?? true,
      cacheTtl: Duration(milliseconds: map['cacheTtl'] as int? ?? 300000),
      environment: EnvironmentType.values.firstWhere(
        (e) => e.name == map['environment'],
        orElse: () => EnvironmentType.development,
      ),
    );
  }

  @override
  String toString() {
    return 'NetworkConfig(baseUrl: $baseUrl, environment: $environment)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkConfig &&
        other.baseUrl == baseUrl &&
        other.environment == environment;
  }

  @override
  int get hashCode => baseUrl.hashCode ^ environment.hashCode;
}
