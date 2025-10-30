import 'http_request.dart';

/// HTTP 响应数据类
///
/// 与具体 HTTP 客户端无关的响应表示
class HttpResponse {
  /// 响应数据
  final dynamic data;

  /// HTTP 状态码
  final int statusCode;

  /// 状态消息
  final String? statusMessage;

  /// 响应头
  final Map<String, List<String>> headers;

  /// 原始请求
  final HttpRequest request;

  /// 响应额外信息
  final Map<String, dynamic>? extra;

  /// 重定向列表
  final List<Uri>? redirects;

  const HttpResponse({
    required this.data,
    required this.statusCode,
    this.statusMessage,
    this.headers = const {},
    required this.request,
    this.extra,
    this.redirects,
  });

  /// 是否成功(状态码 200-299)
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  /// 是否重定向(状态码 300-399)
  bool get isRedirect => statusCode >= 300 && statusCode < 400;

  /// 是否客户端错误(状态码 400-499)
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// 是否服务器错误(状态码 500-599)
  bool get isServerError => statusCode >= 500 && statusCode < 600;

  /// 获取响应头的值
  String? getHeader(String name) {
    final values = headers[name.toLowerCase()];
    return values?.isEmpty ?? true ? null : values!.first;
  }

  /// 获取响应头的所有值
  List<String>? getHeaders(String name) {
    return headers[name.toLowerCase()];
  }

  /// 复制并修改响应
  HttpResponse copyWith({
    dynamic data,
    int? statusCode,
    String? statusMessage,
    Map<String, List<String>>? headers,
    HttpRequest? request,
    Map<String, dynamic>? extra,
    List<Uri>? redirects,
  }) {
    return HttpResponse(
      data: data ?? this.data,
      statusCode: statusCode ?? this.statusCode,
      statusMessage: statusMessage ?? this.statusMessage,
      headers: headers ?? this.headers,
      request: request ?? this.request,
      extra: extra ?? this.extra,
      redirects: redirects ?? this.redirects,
    );
  }

  @override
  String toString() {
    return 'HttpResponse{statusCode: $statusCode, statusMessage: $statusMessage}';
  }
}
