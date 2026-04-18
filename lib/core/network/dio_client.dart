import 'package:dio/dio.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/constants/app_constants.dart';
import 'package:flutter_arms/core/logger/app_logger.dart';
import 'package:flutter_arms/core/network/api_interceptor.dart';
import 'package:flutter_arms/core/network/token_interceptor.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

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
  dio.interceptors
    ..add(
      TalkerDioLogger(
        talker: logger,
        settings: const TalkerDioLoggerSettings(printRequestData: true),
      ),
    )
    ..add(const ApiInterceptor());
  return dio;
}

/// 刷新专用的数据源。仅用于 `TokenInterceptor.refreshAction`。
@Riverpod(keepAlive: true)
AuthRemoteDataSource authRefreshDataSource(Ref ref) {
  return AuthRemoteDataSource(ref.read(authRefreshDioProvider));
}

/// 主 Dio 客户端：注入 Token，自动刷新，统一错误拦截。
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final env = ref.read(appEnvProvider);
  final logger = ref.read(appLoggerProvider);
  final storage = ref.read(kvStorageProvider);

  final dio = Dio(_baseOptions(env.baseUrl));

  dio.interceptors
    ..add(
      TalkerDioLogger(
        talker: logger,
        settings: const TalkerDioLoggerSettings(printRequestData: true),
      ),
    )
    ..add(
      TokenInterceptor(
        accessTokenProvider: () async => storage.getAccessToken(),
        refreshTokenProvider: () async => storage.getRefreshToken(),
        refreshAction: (refreshToken) async {
          try {
            final tokenModel = await ref
                .read(authRefreshDataSourceProvider)
                .refreshToken(<String, dynamic>{'refreshToken': refreshToken});

            if (tokenModel.accessToken.isEmpty) {
              return false;
            }
            await storage.saveAccessToken(tokenModel.accessToken);
            if (tokenModel.refreshToken.isNotEmpty) {
              await storage.saveRefreshToken(tokenModel.refreshToken);
            }
            return true;
          } on Object {
            return false;
          }
        },
        retryDio: dio,
      ),
    )
    ..add(const ApiInterceptor());

  return dio;
}
