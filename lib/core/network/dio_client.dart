import 'package:dio/dio.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/constants/app_constants.dart';
import 'package:flutter_arms/core/logger/app_logger.dart';
import 'package:flutter_arms/core/network/api_interceptor.dart';
import 'package:flutter_arms/core/network/token_interceptor.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

part 'dio_client.g.dart';

/// Dio 客户端依赖注入。
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final logger = ref.read(appLoggerProvider);
  final storage = ref.read(kvStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnv.current.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
      sendTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
      contentType: Headers.jsonContentType,
    ),
  );

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
          final refreshDio = Dio(BaseOptions(baseUrl: AppEnv.current.baseUrl));
          try {
            final response = await refreshDio.post<Map<String, dynamic>>(
              '/auth/refresh',
              data: <String, dynamic>{'refreshToken': refreshToken},
            );

            final data = response.data;
            final access = data?['accessToken'];
            if (access is String && access.isNotEmpty) {
              await storage.saveAccessToken(access);
            } else {
              return false;
            }

            final refresh = data?['refreshToken'];
            if (refresh is String && refresh.isNotEmpty) {
              await storage.saveRefreshToken(refresh);
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
