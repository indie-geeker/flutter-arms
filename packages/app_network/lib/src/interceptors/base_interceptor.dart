import 'package:app_interfaces/app_interfaces.dart';

/// 基础拦截器抽象类
///
/// 提供拦截器的默认实现，子类可以选择性重写需要的方法
abstract class BaseInterceptor implements IRequestInterceptor {
  @override
  int get priority => 0;
  
  @override
  bool get enabled => true; // 默认启用

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    return options;
  }

  @override
  Future<ApiResponse<T>> onResponse<T>(
      ApiResponse<T> response,
      RequestOptions options,
      ) async {
    return response;
  }

  @override
  Future<Object> onError(Object error, RequestOptions options) async {
    return error;
  }
}
