import '../enums/request_method.dart';
import '../enums/response_type.dart';

/// HTTP 请求数据类
///
/// 与具体 HTTP 客户端无关的请求表示
class HttpRequest {
  /// 请求 URL
  final String url;

  /// 请求方法
  final RequestMethod method;

  /// 请求头
  final Map<String, dynamic> headers;

  /// 查询参数
  final Map<String, dynamic>? queryParameters;

  /// 请求体数据
  final dynamic data;

  /// 响应类型
  final ResponseType responseType;

  /// 连接超时
  final Duration connectTimeout;

  /// 接收超时
  final Duration receiveTimeout;

  /// 发送超时
  final Duration sendTimeout;

  /// 取消令牌标识
  final Object? cancelTag;

  /// 额外信息,可用于传递上下文
  final Map<String, dynamic>? extra;

  const HttpRequest({
    required this.url,
    required this.method,
    this.headers = const {},
    this.queryParameters,
    this.data,
    this.responseType = ResponseType.json,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.cancelTag,
    this.extra,
  });

  /// 复制并修改请求
  HttpRequest copyWith({
    String? url,
    RequestMethod? method,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    ResponseType? responseType,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Object? cancelTag,
    Map<String, dynamic>? extra,
  }) {
    return HttpRequest(
      url: url ?? this.url,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      queryParameters: queryParameters ?? this.queryParameters,
      data: data ?? this.data,
      responseType: responseType ?? this.responseType,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      cancelTag: cancelTag ?? this.cancelTag,
      extra: extra ?? this.extra,
    );
  }

  @override
  String toString() {
    return 'HttpRequest{method: $method, url: $url, headers: $headers}';
  }
}
