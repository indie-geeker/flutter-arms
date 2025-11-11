
import 'i_network_interceptor.dart';
import 'network_response.dart';
import 'network_types.dart';

/// HTTP 客户端抽象接口
abstract class IHttpClient {
  /// 发起 GET 请求
  Future<NetworkResponse<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      });

  /// 发起 POST 请求
  Future<NetworkResponse<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      });

  /// 发起 PUT 请求
  Future<NetworkResponse<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      });

  /// 发起 DELETE 请求
  Future<NetworkResponse<T>> delete<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      });

  /// 文件上传
  Future<NetworkResponse<T>> upload<T>(
      String path,
      FormData formData, {
        ProgressCallback? onSendProgress,
        CancelToken? cancelToken,
      });

  /// 文件下载
  Future<NetworkResponse> download(
      String urlPath,
      String savePath, {
        ProgressCallback? onReceiveProgress,
        CancelToken? cancelToken,
      });

  /// 添加拦截器
  void addInterceptor(INetworkInterceptor interceptor);

  /// 取消所有请求
  void cancelAllRequests();
}