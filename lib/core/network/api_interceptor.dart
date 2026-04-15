import 'package:dio/dio.dart';
import 'package:flutter_arms/core/error/error_handler.dart';

/// 统一错误拦截器。
class ApiInterceptor extends Interceptor {
  /// 构造函数。
  const ApiInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = ErrorHandler.map(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: failure,
        message: failure.message,
      ),
    );
  }
}
