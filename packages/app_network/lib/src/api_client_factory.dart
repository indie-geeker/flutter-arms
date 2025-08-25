import 'package:app_interfaces/app_interfaces.dart';
import 'package:app_network/src/intercetpors/retry_interceptor.dart';
import 'package:app_network/src/network_engine.dart';
import 'package:dio/dio.dart' as dio;

import 'base/i_api_client.dart';

class ApiClientFactory {
  ApiClientFactory._private();

  static T create<T extends IApiClient>({
    required INetworkConfig config,
    Map<String, String>? headers,
    List<IRequestInterceptor>? customInterceptors,
    required T Function(dio.Dio dioClient, INetworkEngine engine) builder,
  }) {
    final engine = NetworkEngine(
      config: config,
      defaultHeaders: headers,
    );

    // 日志开关
    if (config.enableLogging) {
      engine.enableLogging();
    }

    // 重试拦截器
    if (config.enableRetry) {
      engine.addInterceptor(
        RetryInterceptor(
          initialDelay: Duration(milliseconds: config.retryDelay),
          maxRetries: config.retryCount,
        )
      );
    }

    // 自定义拦截器
    if (customInterceptors != null && customInterceptors.isNotEmpty) {
      for (final interceptor in customInterceptors) {
        engine.addInterceptor(interceptor);
      }
    }

    // 交给应用层构建具体 IApiClient 实现
    final client = builder(engine.rawDio, engine);
    return client;
  }
}