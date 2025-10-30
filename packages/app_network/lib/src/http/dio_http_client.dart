import 'package:app_interfaces/app_interfaces.dart';
import 'package:dio/dio.dart' as dio;

/// Dio HTTP 客户端实现
///
/// 将 Dio 包装为 IHttpClient 接口实现
/// 使 NetworkClient 不直接依赖 Dio
class DioHttpClient implements IHttpClient {
  final dio.Dio _dio;
  final Map<Object, dio.CancelToken> _cancelTokens = {};

  DioHttpClient({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
    Map<String, dynamic>? headers,
  }) : _dio = dio.Dio(
          dio.BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: connectTimeout,
            receiveTimeout: receiveTimeout,
            sendTimeout: sendTimeout,
            headers: headers,
          ),
        );

  /// 从现有 Dio 实例创建
  DioHttpClient.fromDio(this._dio);

  @override
  Future<HttpResponse> execute(HttpRequest request) async {
    try {
      // 创建或获取 cancel token
      dio.CancelToken? dioToken;
      if (request.cancelTag != null) {
        dioToken = _cancelTokens.putIfAbsent(
          request.cancelTag!,
          () => dio.CancelToken(),
        );
      }

      // 执行请求
      final response = await _dio.request(
        request.url,
        data: request.data,
        queryParameters: request.queryParameters,
        options: dio.Options(
          method: _mapMethod(request.method),
          headers: request.headers,
          responseType: _mapResponseType(request.responseType),
          contentType: _getContentType(request),
        ),
        cancelToken: dioToken,
      );

      // 清理已完成的 cancel token
      if (request.cancelTag != null) {
        _cancelTokens.remove(request.cancelTag);
      }

      return _mapResponse(response, request);
    } on dio.DioException catch (e) {
      // 将 Dio 异常映射为通用 NetworkException
      throw _mapException(e);
    }
  }

  @override
  void cancelRequest(Object tag) {
    final token = _cancelTokens[tag];
    if (token != null) {
      token.cancel('Request cancelled by user');
      _cancelTokens.remove(tag);
    }
  }

  @override
  void cancelAll() {
    for (final token in _cancelTokens.values) {
      token.cancel('All requests cancelled');
    }
    _cancelTokens.clear();
  }

  @override
  void close() {
    cancelAll();
    _dio.close();
  }

  @override
  String get clientType => 'dio';

  /// 获取底层 Dio 实例(用于高级配置)
  dio.Dio get dioInstance => _dio;

  // 私有辅助方法

  String _mapMethod(RequestMethod method) {
    switch (method) {
      case RequestMethod.get:
        return 'GET';
      case RequestMethod.post:
        return 'POST';
      case RequestMethod.put:
        return 'PUT';
      case RequestMethod.delete:
        return 'DELETE';
      case RequestMethod.patch:
        return 'PATCH';
      case RequestMethod.head:
        return 'HEAD';
    }
  }

  dio.ResponseType _mapResponseType(ResponseType type) {
    switch (type) {
      case ResponseType.json:
        return dio.ResponseType.json;
      case ResponseType.string:
        return dio.ResponseType.plain;
      case ResponseType.bytes:
        return dio.ResponseType.bytes;
    }
  }

  String? _getContentType(HttpRequest request) {
    final headers = request.headers;
    if (headers.containsKey('content-type')) {
      return headers['content-type'].toString();
    }
    if (headers.containsKey('Content-Type')) {
      return headers['Content-Type'].toString();
    }
    return null;
  }

  HttpResponse _mapResponse(dio.Response response, HttpRequest request) {
    return HttpResponse(
      data: response.data,
      statusCode: response.statusCode ?? 200,
      statusMessage: response.statusMessage,
      headers: _normalizeHeaders(response.headers.map),
      request: request,
      extra: response.extra,
      redirects: response.redirects.map((e) => e.location).toList(),
    );
  }

  Map<String, List<String>> _normalizeHeaders(Map<String, List<String>> headers) {
    final normalized = <String, List<String>>{};
    for (final entry in headers.entries) {
      normalized[entry.key.toLowerCase()] = entry.value;
    }
    return normalized;
  }

  NetworkException _mapException(dio.DioException e) {
    switch (e.type) {
      case dio.DioExceptionType.connectionTimeout:
        return NetworkException(
          message: 'Connection timeout',
          code: 'connection_timeout',
          statusCode: null,
          details: e,
        );
      case dio.DioExceptionType.sendTimeout:
        return NetworkException(
          message: 'Send timeout',
          code: 'send_timeout',
          statusCode: null,
          details: e,
        );
      case dio.DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Receive timeout',
          code: 'receive_timeout',
          statusCode: null,
          details: e,
        );
      case dio.DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Bad certificate',
          code: 'bad_certificate',
          statusCode: null,
          details: e,
        );
      case dio.DioExceptionType.badResponse:
        return NetworkException(
          message: e.response?.statusMessage ?? 'Bad response',
          code: 'bad_response',
          statusCode: e.response?.statusCode,
          details: e,
        );
      case dio.DioExceptionType.cancel:
        return NetworkException(
          message: 'Request cancelled',
          code: 'request_cancelled',
          statusCode: null,
          details: e,
        );
      case dio.DioExceptionType.connectionError:
        return NetworkException(
          message: e.message ?? 'Connection error',
          code: 'connection_error',
          statusCode: null,
          details: e,
        );
      case dio.DioExceptionType.unknown:
        return NetworkException(
          message: e.message ?? 'Unknown error',
          code: 'unknown_error',
          statusCode: e.response?.statusCode,
          details: e,
        );
    }
  }
}

/// Dio HTTP 客户端工厂
class DioHttpClientFactory implements IHttpClientFactory {
  @override
  IHttpClient create(RequestOptions options) {
    return DioHttpClient(
      baseUrl: '', // 从 options 中提取 baseUrl
      connectTimeout: Duration(milliseconds: options.connectTimeout ?? 30000),
      receiveTimeout: Duration(milliseconds: options.receiveTimeout ?? 30000),
      headers: options.headers,
    );
  }

  @override
  String get supportedType => 'dio';
}
