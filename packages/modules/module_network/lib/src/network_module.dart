import 'package:interfaces/cache/cache_policy.dart';
import 'package:interfaces/cache/cache_stats.dart';
import 'package:interfaces/cache/i_cache_manager.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/network/i_http_client.dart';
import 'package:interfaces/network/network_cache_options.dart';

import 'config/network_config.dart';
import 'impl/dio_http_client.dart';

/// 网络模块
class NetworkModule implements IModule {
  final String baseUrl;
  final Duration? connectTimeout;
  final Duration? receiveTimeout;
  final Duration? sendTimeout;
  final Map<String, String> defaultHeaders;
  final bool enableCache;
  final Duration defaultCacheDuration;
  final bool enableLogging;
  final RetryConfig retryConfig;
  final ProxyConfig? proxyConfig;

  NetworkModule({
    required this.baseUrl,
    this.connectTimeout,
    this.receiveTimeout,
    this.sendTimeout,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    this.enableCache = false,
    this.defaultCacheDuration = const Duration(minutes: 5),
    this.enableLogging = true,
    this.retryConfig = const RetryConfig(),
    this.proxyConfig,
  });

  factory NetworkModule.fromConfig(NetworkConfig config) {
    return NetworkModule(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      defaultHeaders: config.defaultHeaders,
      enableCache: config.enableCache,
      defaultCacheDuration: config.defaultCacheDuration,
      enableLogging: config.enableLogging,
      retryConfig: config.retryConfig,
      proxyConfig: config.proxyConfig,
    );
  }

  @override
  String get name => 'NetworkModule';

  @override
  int get priority => InitPriorities.network; // 在日志、存储、缓存之后初始化

  @override
  List<Type> get dependencies =>
      enableCache ? [ILogger, ICacheManager] : [ILogger];

  @override
  List<Type> get provides => [IHttpClient];

  // 保存 locator 引用以便在 init 中使用
  late IServiceLocator _locator;

  @override
  Future<void> register(IServiceLocator locator) async {
    _locator = locator;

    final logger = locator.get<ILogger>();
    final cacheManager = enableCache
        ? locator.get<ICacheManager>()
        : _NoopCacheManager();

    final httpClient = DioHttpClient(
      baseUrl: baseUrl,
      logger: logger,
      cacheManager: cacheManager, // 注入缓存管理器
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      defaultHeaders: defaultHeaders,
      enableLogging: enableLogging,
      retryConfig: retryConfig,
      defaultCacheDuration: defaultCacheDuration,
      defaultCacheOptions: enableCache
          ? NetworkCacheOptions(enabled: true, duration: defaultCacheDuration)
          : null,
      proxyConfig: proxyConfig,
    );

    locator.registerSingleton<IHttpClient>(httpClient);
  }

  @override
  Future<void> init() async {
    // Network initialization if needed
  }

  @override
  Future<void> dispose() async {
    final httpClient = _locator.get<IHttpClient>();
    httpClient.cancelAllRequests();
  }
}

class _NoopCacheManager implements ICacheManager {
  @override
  Future<void> clear() async {}

  @override
  Future<void> clearExpired() async {}

  @override
  Future<bool> containsKey(String key) async => false;

  @override
  Future<T?> get<T>(String key) async => null;

  @override
  Future<int> getCacheSize() async => 0;

  @override
  Future<T> getOrDefault<T>(String key, T defaultValue) async => defaultValue;

  @override
  Future<CacheStats> getStats() async => CacheStats(
    totalKeys: 0,
    memoryKeys: 0,
    diskKeys: 0,
    totalSize: 0,
    hitCount: 0,
    missCount: 0,
  );

  @override
  Future<void> init() async {}

  @override
  Future<void> put<T>(
    String key,
    T value, {
    Duration? duration,
    CachePolicy policy = CachePolicy.normal,
  }) async {}

  @override
  Future<void> remove(String key) async {}
}
