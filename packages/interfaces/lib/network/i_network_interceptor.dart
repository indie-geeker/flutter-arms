
import 'network_exception.dart';
import 'network_request.dart';
import 'network_response.dart';

/// 网络拦截器抽象接口
///
/// 用于在请求发送前、响应接收后、错误发生时进行拦截处理。
/// 实现此接口可以自定义请求/响应的处理逻辑（如添加认证信息、日志记录等）。
abstract class INetworkInterceptor {
  /// 请求拦截
  ///
  /// 在请求发送前调用，可以修改请求参数。
  /// 返回修改后的请求对象，或返回 null 取消请求。
  Future<NetworkRequest?> onRequest(NetworkRequest request);

  /// 响应拦截
  ///
  /// 在响应接收后、返回给调用者前调用，可以修改响应数据。
  /// 返回修改后的响应对象。
  Future<NetworkResponse<T>> onResponse<T>(NetworkResponse<T> response);

  /// 错误拦截
  ///
  /// 在请求出错时调用，可以进行错误处理或转换。
  /// 返回处理后的错误，或返回一个恢复的响应对象。
  Future<NetworkResponse<T>> onError<T>(NetworkException error);
}