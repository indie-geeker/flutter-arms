
import '../../app_interfaces.dart';

/// 网络客户端接口
///
/// 抽象网络请求客户端的基本功能，屏蔽具体实现细节（如Dio）
abstract class INetworkClient {
  /// 执行网络请求并返回响应结果
  ///
  /// [options] 请求选项
  /// [cancelToken] 可选的取消令牌，用于取消请求
  /// 返回响应结果
  Future<ApiResponse<T>> request<T>({
    required RequestOptions options,
    Object? cancelToken,
  });

  /// 执行GET请求
  ///
  /// [path] 请求路径
  /// [queryParameters] 查询参数
  /// [options] 额外请求选项，会与默认选项合并
  /// [cancelToken] 可选的取消令牌，用于取消请求
  Future<ApiResponse<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        RequestOptions? options,
        Object? cancelToken,
      });

  /// 执行POST请求
  ///
  /// [path] 请求路径
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [options] 额外请求选项，会与默认选项合并
  /// [cancelToken] 可选的取消令牌，用于取消请求
  Future<ApiResponse<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        RequestOptions? options,
        Object? cancelToken,
      });

  /// 执行PUT请求
  ///
  /// [path] 请求路径
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [options] 额外请求选项，会与默认选项合并
  /// [cancelToken] 可选的取消令牌，用于取消请求
  Future<ApiResponse<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        RequestOptions? options,
        Object? cancelToken,
      });

  /// 执行DELETE请求
  ///
  /// [path] 请求路径
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [options] 额外请求选项，会与默认选项合并
  /// [cancelToken] 可选的取消令牌，用于取消请求
  Future<ApiResponse<T>> delete<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        RequestOptions? options,
        Object? cancelToken,
      });

  /// 执行PATCH请求
  ///
  /// [path] 请求路径
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [options] 额外请求选项，会与默认选项合并
  /// [cancelToken] 可选的取消令牌，用于取消请求
  Future<ApiResponse<T>> patch<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        RequestOptions? options,
        Object? cancelToken,
      });

  /// 下载文件
  ///
  /// [url] 文件URL
  /// [savePath] 保存路径
  /// [onReceiveProgress] 下载进度回调
  /// [cancelToken] 可选的取消令牌，用于取消下载
  Future<ApiResponse<String>> download(
      String url,
      String savePath, {
        void Function(int received, int total)? onReceiveProgress,
        Object? cancelToken,
      });

  /// 添加请求拦截器
  ///
  /// [interceptor] 请求拦截器
  void addInterceptor(IRequestInterceptor interceptor);

  /// 移除请求拦截器
  ///
  /// [interceptor] 请求拦截器
  void removeInterceptor(IRequestInterceptor interceptor);

  /// 清除所有拦截器
  void clearInterceptors();

  /// 设置基础URL
  ///
  /// [baseUrl] 新的基础URL
  void setBaseUrl(String baseUrl);

  /// 设置默认请求头
  ///
  /// [headers] 默认请求头
  void setDefaultHeaders(Map<String, String> headers);

  /// 获取当前默认请求头
  Map<String, String> get defaultHeaders;

  /// 设置默认超时时间
  ///
  /// [connectTimeout] 连接超时时间（毫秒）
  /// [receiveTimeout] 接收超时时间（毫秒）
  void setTimeout({int? connectTimeout, int? receiveTimeout});

  /// 设置环境配置
  ///
  /// [environmentType] 环境类型
  /// [baseUrl] 基础URL
  void configure(EnvironmentType environmentType, {String? baseUrl});

  /// 创建请求取消令牌
  ///
  /// 返回可用于取消请求的令牌
  Object createCancelToken();

  /// 取消请求
  ///
  /// [cancelToken] 取消令牌
  /// [reason] 取消原因
  void cancelRequest(Object cancelToken, [String? reason]);

  /// 取消所有请求
  ///
  /// [reason] 取消原因
  void cancelAllRequests([String? reason]);

  /// 启用请求日志
  void enableLogging();

  /// 禁用请求日志
  void disableLogging();

  /// 关闭客户端并释放资源
  void close();

  /// 获取网络配置
  INetWorkConfig get networkConfig;
}