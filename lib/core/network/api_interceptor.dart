import 'package:dio/dio.dart';
import 'package:flutter_arms/core/error/app_exception_mapper.dart';

/// 统一错误拦截器。
///
/// 将 [DioException] 映射为 `AppException` 并填入 `error` 字段，
/// 由上层通过 `.asApi()` 扩展解封。
class ApiInterceptor extends Interceptor {
  /// 构造函数。
  const ApiInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appEx = AppExceptionMapper.fromDio(err, err.stackTrace);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: appEx,
        stackTrace: err.stackTrace,
      ),
    );
  }
}
