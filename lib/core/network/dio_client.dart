import 'package:dio/dio.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/auth/auth_token_refresher.dart';
import 'package:flutter_arms/core/constants/app_constants.dart';
import 'package:flutter_arms/core/logger/app_logger.dart';
import 'package:flutter_arms/core/logger/talker_dio_interceptor.dart';
import 'package:flutter_arms/core/network/api_interceptor.dart';
import 'package:flutter_arms/core/network/mock_api_interceptor.dart';
import 'package:flutter_arms/core/network/token_interceptor.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_client.g.dart';

BaseOptions _baseOptions(String baseUrl) => BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
  receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
  sendTimeout: const Duration(milliseconds: AppConstants.sendTimeoutMs),
  contentType: Headers.jsonContentType,
);

/// 无 Token 拦截器的 Dio，专门用于 `/auth/refresh` 等不需要鉴权的端点，
/// 避免 `TokenInterceptor` 在刷新过程中自调用造成递归。
@Riverpod(keepAlive: true)
Dio authRefreshDio(Ref ref) {
  final env = ref.read(appEnvProvider);
  final logger = ref.read(appLoggerProvider);
  final dio = Dio(_baseOptions(env.baseUrl));
  // Mock 必须位于拦截链首位：
  // - onRequest：短路 `/auth/*` 早于 Token/Api 拦截器；
  // - onError：`handler.reject(err, true)` 触发的是**后续** onError，
  //   只有首位 reject，ApiInterceptor 的 DioException→AppException 映射才会跑。
  if (env.useMockApi) {
    dio.interceptors.add(const MockApiInterceptor());
  }
  dio.interceptors
    ..add(dioLogInterceptor(logger))
    ..add(const ApiInterceptor());
  return dio;
}

/// 主 Dio 客户端：注入 Token，自动刷新，统一错误拦截。
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final env = ref.read(appEnvProvider);
  final logger = ref.read(appLoggerProvider);
  final storage = ref.read(kvStorageProvider);
  final tokenRefresher = ref.read(authTokenRefresherProvider);

  final dio = Dio(_baseOptions(env.baseUrl));

  // 同上：Mock 必须首位，参见 authRefreshDio 注释。
  if (env.useMockApi) {
    dio.interceptors.add(const MockApiInterceptor());
  }
  dio.interceptors
    ..add(dioLogInterceptor(logger))
    ..add(
      TokenInterceptor(
        accessTokenProvider: () async => storage.getAccessToken(),
        refreshTokenProvider: () async => storage.getRefreshToken(),
        refreshAction: tokenRefresher.refresh,
        retryDio: dio,
      ),
    )
    ..add(const ApiInterceptor());

  return dio;
}
