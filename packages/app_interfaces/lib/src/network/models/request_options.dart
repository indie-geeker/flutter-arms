import 'dart:convert';

import '../configs/cache_config.dart';
import '../configs/retry_config.dart';
import '../enums/content_type.dart';
import '../enums/request_method.dart';
import '../enums/response_type.dart';

/// 网络请求选项
///
/// 封装网络请求的配置信息，如请求方法、URL、请求头等
class RequestOptions {
  /// 创建请求选项
  const RequestOptions({
    required this.path,
    this.method = RequestMethod.get,
    this.headers = const {},
    this.queryParameters,
    this.data,
    this.baseUrl,
    this.contentType = ContentType.json,
    this.responseType = ResponseType.json,
    this.connectTimeout,
    this.receiveTimeout,
    this.followRedirects = true,
    this.validateStatus,
    this.extra = const {},
    this.cacheConfig,
    this.retryConfig,
  });

  /// 请求路径
  final String path;

  /// 请求方法
  final RequestMethod method;

  /// 请求头
  final Map<String, String> headers;

  /// 查询参数
  final Map<String, dynamic>? queryParameters;

  /// 请求数据
  final dynamic data;

  /// 基础URL，如果设置则会与path拼接
  final String? baseUrl;

  /// 内容类型
  final ContentType contentType;

  /// 响应类型
  final ResponseType responseType;

  /// 连接超时时间（毫秒）
  final int? connectTimeout;

  /// 接收超时时间（毫秒）
  final int? receiveTimeout;

  /// 是否跟随重定向
  final bool followRedirects;

  /// 状态码验证函数
  final bool Function(int? status)? validateStatus;

  /// 额外配置信息
  final Map<String, dynamic> extra;

  /// 缓存配置
  final CacheConfig? cacheConfig;

  /// 重试配置
  final RetryConfig? retryConfig;

  /// 创建完整URL
  String get url => baseUrl != null ? '$baseUrl$path' : path;

  /// 获取内容类型的HTTP头值
  String get contentTypeValue {
    switch (contentType) {
      case ContentType.json:
        return 'application/json; charset=utf-8';
      case ContentType.formUrlEncoded:
        return 'application/x-www-form-urlencoded';
      case ContentType.multipart:
        return 'multipart/form-data';
      case ContentType.text:
        return 'text/plain; charset=utf-8';
    }
  }

  /// 复制请求选项并修改部分属性
  RequestOptions copyWith({
    String? path,
    RequestMethod? method,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    String? baseUrl,
    ContentType? contentType,
    ResponseType? responseType,
    int? connectTimeout,
    int? receiveTimeout,
    bool? followRedirects,
    bool Function(int? status)? validateStatus,
    Map<String, dynamic>? extra,
    CacheConfig? cacheConfig,
    RetryConfig? retryConfig,
  }) {
    return RequestOptions(
      path: path ?? this.path,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      queryParameters: queryParameters ?? this.queryParameters,
      data: data ?? this.data,
      baseUrl: baseUrl ?? this.baseUrl,
      contentType: contentType ?? this.contentType,
      responseType: responseType ?? this.responseType,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      followRedirects: followRedirects ?? this.followRedirects,
      validateStatus: validateStatus ?? this.validateStatus,
      extra: extra ?? this.extra,
      cacheConfig: cacheConfig ?? this.cacheConfig,
      retryConfig: retryConfig ?? this.retryConfig,
    );
  }

  @override
  String toString() {
    return 'RequestOptions(method: $method, url: $url, headers: $headers, '
        'queryParameters: $queryParameters, data: ${data is String ? data : jsonEncode(data)})';
  }
}
