import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/api_client.dart';
import 'package:flutter_arms/core/network/interceptors/mock_interceptor.dart';

import 'adapters/default_response_adapter.dart';
import 'adapters/response_adapter.dart';
import 'converter/adaptable_response_converter.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/response_interceptor.dart';

class ApiClientFactory {
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;

  static List<Interceptor> interceptors = [
    MockInterceptor(),
    LoggingInterceptor(),
    ErrorInterceptor(),
  ];

  static BaseOptions appOptions(baseUrl) => BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(milliseconds: connectTimeout),
    receiveTimeout: const Duration(milliseconds: receiveTimeout),
    sendTimeout: const Duration(milliseconds: sendTimeout),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );


  static ApiClient createDefaultApiClient(String baseUrl, {ResponseAdapter adapter = const DefaultResponseAdapter()}) {
    final dio = Dio(appOptions(baseUrl));
    final convert = AdaptableResponseConverter(adapter);

    interceptors.add(ResponseInterceptor(convert));
    dio.interceptors.addAll(interceptors);
    return ApiClient(dio);
  }

  // static ApiClient createThirdPartyApiClient(String baseUrl) {
  //   final dio = Dio(BaseOptions(baseUrl: baseUrl));
  //   final converter = AdaptableResponseConverter(ThirdPartyApiAdapter());
  //
  //   dio.interceptors.add(ResponseInterceptor(converter));
  //   return ApiClient(dio);
  // }
}