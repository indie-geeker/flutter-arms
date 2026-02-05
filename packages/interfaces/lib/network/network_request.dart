
import 'network_cache_options.dart';

/// 网络请求封装
class NetworkRequest {
  /// 请求路径
  final String path;

  /// 请求方法
  final String method;

  /// 查询参数
  final Map<String, dynamic>? queryParameters;

  /// 请求头
  final Map<String, dynamic>? headers;

  /// 请求体数据
  final dynamic data;

  /// 连接超时时间
  final Duration? connectTimeout;

  /// 接收超时时间
  final Duration? receiveTimeout;

  /// 额外配置（用于传递自定义参数）
  final Map<String, dynamic>? extra;

  /// 缓存配置
  final NetworkCacheOptions? cacheOptions;

  NetworkRequest({
    required this.path,
    required this.method,
    this.queryParameters,
    this.headers,
    this.data,
    this.connectTimeout,
    this.receiveTimeout,
    this.extra,
    this.cacheOptions,
  });

  /// 创建 GET 请求
  factory NetworkRequest.get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? extra,
        NetworkCacheOptions? cacheOptions,
      }) {
    return NetworkRequest(
      path: path,
      method: 'GET',
      queryParameters: queryParameters,
      headers: headers,
      extra: extra,
      cacheOptions: cacheOptions,
    );
  }

  /// 创建 POST 请求
  factory NetworkRequest.post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? extra,
        NetworkCacheOptions? cacheOptions,
      }) {
    return NetworkRequest(
      path: path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      extra: extra,
      cacheOptions: cacheOptions,
    );
  }

  /// 创建 PUT 请求
  factory NetworkRequest.put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? extra,
        NetworkCacheOptions? cacheOptions,
      }) {
    return NetworkRequest(
      path: path,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      extra: extra,
      cacheOptions: cacheOptions,
    );
  }

  /// 创建 DELETE 请求
  factory NetworkRequest.delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? extra,
        NetworkCacheOptions? cacheOptions,
      }) {
    return NetworkRequest(
      path: path,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      extra: extra,
      cacheOptions: cacheOptions,
    );
  }

  /// 生成缓存键
  String toCacheKey() {
    final uri = path;
    final params = queryParameters?.toString() ?? '';
    return 'http_cache:$uri:$params';
  }
}
