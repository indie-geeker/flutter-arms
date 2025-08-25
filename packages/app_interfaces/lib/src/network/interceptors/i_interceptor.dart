

import '../configs/request_options.dart';
import '../models/response_wrapper.dart';

/// 请求拦截器接口
///
/// 用于拦截和修改请求和响应，实现日志记录、认证令牌添加等功能
abstract class IRequestInterceptor {
  /// 优先级，数字越小优先级越高
  int get priority;

  /// 是否启用拦截器
  bool get enabled;

  /// 请求拦截
  ///
  /// 在请求发送前调用，可以修改请求选项
  /// [options] 原始请求选项
  /// 返回修改后的请求选项
  Future<RequestOptions> onRequest(RequestOptions options);

  /// 响应拦截
  ///
  /// 在收到响应后调用，可以修改响应内容
  /// [response] 原始响应
  /// [options] 请求选项
  /// 返回修改后的响应
  Future<ResponseWrapper<T>> onResponse<T>(
      ResponseWrapper<T> response,
      RequestOptions options,
      );

  /// 错误拦截
  ///
  /// 在请求或响应发生错误时调用，可以处理错误或抛出新的错误
  /// [error] 原始错误
  /// [options] 请求选项
  /// 返回处理后的错误，或者返回响应（表示错误已恢复）
  Future<Object> onError(Object error, RequestOptions options);
}