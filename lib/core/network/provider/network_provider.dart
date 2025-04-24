import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/interceptors/error_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network_config.dart';
import '../interceptors/logging_interceptor.dart';
import '../api_client.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(NetworkConfig.options);
  dio.interceptors.addAll([
    LoggingInterceptor(),
    ErrorInterceptor(),
    // 可以添加其他拦截器，如认证拦截器等
  ]);
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio, baseUrl: NetworkConfig.baseUrl);
});
