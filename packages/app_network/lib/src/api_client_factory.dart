import 'package:app_interfaces/app_interfaces.dart';
import 'package:app_network/src/api_client.dart';

import 'cache/disk_cache_strategy.dart';
import 'cache/memory_cache_strategy.dart';
import 'cache/no_cache_strategy.dart';
import 'config/network_config.dart';
import 'error/network_error_handler.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/log_interceptor.dart';
import 'interceptors/retry_interceptor.dart';


/// 网络客户端工厂
///
/// 负责创建和配置网络客户端实例
class NetworkClientFactory {
  NetworkClientFactory._();

  /// 创建网络客户端
  static ApiClient create({
    required NetworkConfig config,
    ICacheStrategy? cacheStrategy,
    INetworkErrorHandler? errorHandler,
    List<IRequestInterceptor>? customInterceptors,
  }) {
    // 创建网络客户端
    final client = ApiClient(
      baseUrl: config.baseUrl,
      defaultHeaders: config.defaultHeaders.map((k, v) => MapEntry(k, v.toString())),
      connectTimeout: config.connectTimeout.inMilliseconds,
      receiveTimeout: config.receiveTimeout.inMilliseconds,
    );

    // 添加日志拦截器
    if (config.enableLogging) {
      client.addInterceptor(LogInterceptor(
        logRequest: true,
        logResponse: true,
        logError: true,
        logHeaders: true,
        logBody: config.environment == EnvironmentType.development,
      ));
    }

    // 添加重试拦截器
    if (config.enableRetry) {
      client.addInterceptor(RetryInterceptor(
        maxRetries: config.maxRetries,
        initialDelay: config.retryDelay,
      ));
    }

    // 添加自定义拦截器
    if (customInterceptors != null) {
      for (final interceptor in customInterceptors) {
        client.addInterceptor(interceptor);
      }
    }

    return client;
  }

  /// 创建带认证的网络客户端
  static ApiClient createWithAuth({
    required NetworkConfig config,
    String? token,
    Future<String?> Function()? onTokenRefresh,
    void Function()? onTokenExpired,
    ICacheStrategy? cacheStrategy,
    INetworkErrorHandler? errorHandler,
    List<IRequestInterceptor>? customInterceptors,
  }) {
    // 创建认证拦截器
    final authInterceptor = AuthInterceptor(
      token: token,
      onTokenRefresh: onTokenRefresh,
      onTokenExpired: onTokenExpired,
    );

    // 合并拦截器
    final allInterceptors = <IRequestInterceptor>[
      authInterceptor,
      ...?customInterceptors,
    ];

    return create(
      config: config,
      cacheStrategy: cacheStrategy,
      errorHandler: errorHandler,
      customInterceptors: allInterceptors,
    );
  }

  /// 创建缓存策略
  static ICacheStrategy createCacheStrategy({
    required CacheStrategyType type,
    Duration? defaultTtl,
    int? maxCacheSize,
    IKeyValueStorage? storage,

  }) {
    switch (type) {
      case CacheStrategyType.memory:
        return MemoryCacheStrategy(
          defaultTtl: defaultTtl ?? const Duration(minutes: 5),
          maxCacheSize: maxCacheSize ?? 100,
        );
      case CacheStrategyType.disk:
        if(storage == null){
          throw CacheException(message: "disk cache strategy must provide storage");
        }
        return DiskCacheStrategy(
          defaultTtl: defaultTtl ?? const Duration(hours: 1),
          maxCacheSize: maxCacheSize ?? 50,
          storage: storage,
        );
      case CacheStrategyType.none:
        return const NoCacheStrategy();
    }
  }

  /// 创建错误处理器
  static INetworkErrorHandler createErrorHandler({
    Map<NetworkErrorType, String>? customErrorMessages,
    bool enableDetailedErrors = false,
  }) {
    return NetworkErrorHandler(
      customErrorMessages: customErrorMessages,
      enableDetailedErrors: enableDetailedErrors,
    );
  }
}

// /// 缓存策略类型
// enum CacheStrategyType {
//   /// 内存缓存
//   memory,
//
//   /// 磁盘缓存
//   disk,
//
//   /// 无缓存
//   none,
// }
