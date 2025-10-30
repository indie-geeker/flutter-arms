import 'package:app_interfaces/app_interfaces.dart';
import 'package:app_network/app_network.dart';

import '../../app_core.dart';

class NetworkClientBuilder {
  static INetworkClient fromConfig(
      INetWorkConfig config, {
        ILogger? logger,
        NetworkSetup? setup,
        IHttpClient? httpClient,
      }) {
    // Create base client
    final client = NetworkClient(
      config: config,
      httpClient: httpClient,
      defaultHeaders: {},
    );

    // Apply retry config
    final retryConfig = setup?.retryConfig ?? config.retryConfig;
    if (retryConfig.maxRetries > 0) {
      client.addInterceptor(RetryInterceptor(
        config: retryConfig,
        logger: logger,
      ));
    }

    // Apply cache configuration
    final cacheConfig = setup?.cachePolicyConfig ?? config.cachePolicyConfig;
    if (cacheConfig.defaultPolicy != CachePolicy.networkOnly) {
      // Create memory cache strategy
      final memoryCache = MemoryCacheStrategy(
        defaultTtl: cacheConfig.defaultMaxAge,
        maxCacheSize: cacheConfig.memoryCacheMaxEntries,
      );

      // Add cache interceptor with memory cache strategy
      client.addInterceptor(CacheInterceptor(
        strategy: memoryCache,
        logger: logger,
      ));
    }

    // Apply other interceptors from setup
    if (setup != null) {
      for (final interceptor in setup.interceptors) {
        client.addInterceptor(interceptor);
      }
    }

    return client;
  }
}