
import 'package:interfaces/interfaces.dart';

/// 网络配置
class NetworkConfig {
  /// 基础 URL
  final String baseUrl;

  /// 连接超时时间
  final Duration connectTimeout;

  /// 接收超时时间
  final Duration receiveTimeout;

  /// 发送超时时间
  final Duration sendTimeout;

  /// 默认请求头
  final Map<String, String> defaultHeaders;

  /// 是否启用日志
  final bool enableLogging;

  /// 是否启用缓存
  final bool enableCache;

  /// 默认缓存时长
  final Duration defaultCacheDuration;

  /// 重试配置
  final RetryConfig retryConfig;

  /// 代理配置
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

  /// 创建开发环境配置
  factory NetworkConfig.development({
    required String baseUrl,
  }) {
    return NetworkConfig(
      baseUrl: baseUrl,
      enableLogging: true,
      enableCache: false,
      connectTimeout: const Duration(seconds: 60),
    );
  }

  /// 创建生产环境配置
  factory NetworkConfig.production({
    required String baseUrl,
  }) {
    return NetworkConfig(
      baseUrl: baseUrl,
      enableLogging: false,
      enableCache: true,
      connectTimeout: const Duration(seconds: 30),
    );
  }
}

/// 重试配置
class RetryConfig {
  /// 最大重试次数
  final int maxRetries;

  /// 重试延迟
  final Duration retryDelay;

  /// 是否启用指数退避
  final bool exponentialBackoff;

  /// 需要重试的 HTTP 状态码
  final Set<int> retryableStatusCodes;

  const RetryConfig({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.exponentialBackoff = true,
    this.retryableStatusCodes = const {408, 429, 500, 502, 503, 504},
  });
}

/// 代理配置
class ProxyConfig {
  /// 代理地址
  final String host;

  /// 代理端口
  final int port;

  /// 用户名（可选）
  final String? username;

  /// 密码（可选）
  final String? password;

  ProxyConfig({
    required this.host,
    required this.port,
    this.username,
    this.password,
  });

  /// 生成代理 URL
  String get proxyUrl {
    if (username != null && password != null) {
      return 'http://$username:$password@$host:$port';
    }
    return 'http://$host:$port';
  }
}