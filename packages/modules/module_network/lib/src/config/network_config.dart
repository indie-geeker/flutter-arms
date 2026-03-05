/// Network configuration.
class NetworkConfig {
  /// Base URL.
  final String baseUrl;

  /// Connection timeout.
  final Duration connectTimeout;

  /// Receive timeout.
  final Duration receiveTimeout;

  /// Send timeout.
  final Duration sendTimeout;

  /// Default request headers.
  final Map<String, String> defaultHeaders;

  /// Whether logging is enabled.
  final bool enableLogging;

  /// Whether caching is enabled.
  final bool enableCache;

  /// Default cache duration.
  final Duration defaultCacheDuration;

  /// Retry configuration.
  final RetryConfig retryConfig;

  /// Proxy configuration.
  final ProxyConfig? proxyConfig;

  NetworkConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    this.enableLogging = true,
    this.enableCache = false,
    this.defaultCacheDuration = const Duration(minutes: 5),
    this.retryConfig = const RetryConfig(),
    this.proxyConfig,
  });

  /// Creates a development configuration.
  factory NetworkConfig.development({required String baseUrl}) {
    return NetworkConfig(
      baseUrl: baseUrl,
      enableLogging: true,
      enableCache: false,
      connectTimeout: const Duration(seconds: 60),
    );
  }

  /// Creates a production configuration.
  factory NetworkConfig.production({required String baseUrl}) {
    return NetworkConfig(
      baseUrl: baseUrl,
      enableLogging: false,
      enableCache: true,
      connectTimeout: const Duration(seconds: 30),
    );
  }
}

/// Retry configuration.
class RetryConfig {
  /// Maximum number of retries.
  final int maxRetries;

  /// Retry delay.
  final Duration retryDelay;

  /// Whether to use exponential backoff.
  final bool exponentialBackoff;

  /// HTTP status codes to retry on.
  final Set<int> retryableStatusCodes;

  const RetryConfig({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.exponentialBackoff = true,
    this.retryableStatusCodes = const {408, 429, 500, 502, 503, 504},
  });
}

/// Proxy configuration.
class ProxyConfig {
  /// Proxy address.
  final String host;

  /// Proxy port.
  final int port;

  /// Username (optional).
  final String? username;

  /// Password (optional).
  final String? password;

  ProxyConfig({
    required this.host,
    required this.port,
    this.username,
    this.password,
  });

  /// Generates the proxy URL.
  String get proxyUrl {
    if (username != null && password != null) {
      return 'http://$username:$password@$host:$port';
    }
    return 'http://$host:$port';
  }
}
