import 'package:app_interfaces/app_interfaces.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';

class NetworkClient implements INetworkClient {
  late final dio.Dio _dio;
  final List<IRequestInterceptor> _interceptors = [];
  final Set<dio.CancelToken> _activeCancelTokens = <dio.CancelToken>{};

  dio.LogInterceptor? _logInterceptor;

  late INetWorkConfig _config;

  NetworkClient({
    required INetWorkConfig config,
    Map<String, String>? defaultHeaders,
  }) {
    _config = config;
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: config.baseUrl ?? '',
      headers: defaultHeaders,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
    ));
  }

  @override
  void configure(EnvironmentType environmentType, {String? baseUrl}) {
    if (baseUrl != null) {
      setBaseUrl(baseUrl);
    }
  }

  @override
  Future<ApiResponse<T>> request<T>(
      {required RequestOptions options, Object? cancelToken}) async {
    return _executeRequestWithInterceptors<T>(options, cancelToken);
  }

  /// 执行带拦截器链的请求
  Future<ApiResponse<T>> _executeRequestWithInterceptors<T>(
      RequestOptions options,
      Object? cancelToken
      ) async {
    var processedOptions = options;

    try {
      // 1. 执行请求拦截器链
      for (final interceptor in _getSortedInterceptors()) {
        if (interceptor.enabled) {
          processedOptions = await interceptor.onRequest(processedOptions);
        }
      }

      // 2. 执行实际的网络请求
      final response = await _dio.request(
        processedOptions.path,
        data: processedOptions.data,
        queryParameters: processedOptions.queryParameters,
        options: dio.Options(
          method: processedOptions.method.name.toUpperCase(),
          headers: processedOptions.headers,
          responseType: _mapResponseType(processedOptions.responseType),
          contentType: _getContentTypeValue(processedOptions.contentType),
        ),
        cancelToken: cancelToken as dio.CancelToken?,
      );

      var apiResponse = ApiResponse<T>(
        code: response.statusCode,
        data: response.data as T,
        message: response.statusMessage,
        extra: {
          ...response.extra,
          '_request_options': processedOptions, // 用于缓存等功能
        },
      );

      // 3. 执行响应拦截器链
      for (final interceptor in _getSortedInterceptors()) {
        if (interceptor.enabled) {
          apiResponse = await interceptor.onResponse<T>(apiResponse, processedOptions);
        }
      }

      return apiResponse;

    } catch (error) {
      var processedError = error;

      // 4. 执行错误拦截器链
      for (final interceptor in _getSortedInterceptors()) {
        if (interceptor.enabled) {
          processedError = await interceptor.onError(processedError, processedOptions);
        }
      }

      // 5. 处理 Dio 异常
      if (processedError is dio.DioException) {
        throw _mapDioException(processedError);
      }

      throw processedError;
    }
  }

  @override
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  @override
  void setDefaultHeaders(Map<String, String> headers) {
    _dio.options.headers.clear();
    _dio.options.headers.addAll(headers);
  }

  @override
  void setTimeout({int? connectTimeout, int? receiveTimeout}) {
    if (connectTimeout != null) {
      _dio.options.connectTimeout = Duration(milliseconds: connectTimeout);
    }
    if (receiveTimeout != null) {
      _dio.options.receiveTimeout = Duration(milliseconds: receiveTimeout);
    }
  }

  @override
  Future<ApiResponse<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters,
        RequestOptions? options,
        Object? cancelToken}) {
    final requestOptions = _buildRequestOptions(
        method: RequestMethod.get,
        path: path,
        queryParameters: queryParameters,
        options: options);

    return request(
      options: requestOptions,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<T>> post<T>(String path,
      {data,
        Map<String, dynamic>? queryParameters,
        RequestOptions? options,
        Object? cancelToken}) {
    final requestOptions = _buildRequestOptions(
        method: RequestMethod.post,
        path: path,
        data: data,
        queryParameters: queryParameters,
        options: options);

    return request(
      options: requestOptions,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<T>> put<T>(String path,
      {data,
        Map<String, dynamic>? queryParameters,
        RequestOptions? options,
        Object? cancelToken}) {
    final requestOptions = _buildRequestOptions(
      method: RequestMethod.put,
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );

    return request<T>(
      options: requestOptions,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<T>> patch<T>(String path,
      {data,
        Map<String, dynamic>? queryParameters,
        RequestOptions? options,
        Object? cancelToken}) {
    final requestOptions = _buildRequestOptions(
      method: RequestMethod.patch,
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );

    return request<T>(
      options: requestOptions,
      cancelToken: cancelToken,
    );
  }



  @override
  Future<ApiResponse<T>> delete<T>(String path,
      {data,
        Map<String, dynamic>? queryParameters,
        RequestOptions? options,
        Object? cancelToken}) {
    final requestOptions = _buildRequestOptions(
      method: RequestMethod.delete,
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );

    return request<T>(
      options: requestOptions,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<String>> download(String url, String savePath,
      {void Function(int received, int total)? onReceiveProgress,
        Object? cancelToken}) async {
    try {
      final response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken as dio.CancelToken?,
      );

      return ApiResponse<String>(
        code: response.statusCode ?? 200,
        data: savePath,
        message: response.statusMessage,
        extra: response.extra,
      );
    } on dio.DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  void addInterceptor(IRequestInterceptor interceptor) {
    // 避免重复添加同一个拦截器
    if (!_interceptors.contains(interceptor)) {
      _interceptors.add(interceptor);
      _interceptors.sort((a, b) => a.priority.compareTo(b.priority));
    }
  }

  @override
  void removeInterceptor(IRequestInterceptor interceptor) {
    _interceptors.remove(interceptor);
  }

  @override
  void clearInterceptors() {
    _interceptors.clear();
  }

  @override
  void cancelAllRequests([String? reason]) {
    for (final token in _activeCancelTokens) {
      token.cancel(reason);
    }
    _activeCancelTokens.clear();
  }

  @override
  void cancelRequest(Object cancelToken, [String? reason]) {
    if (cancelToken is dio.CancelToken) {
      cancelToken.cancel(reason);
      _activeCancelTokens.remove(cancelToken);
    }
  }



  @override
  Object createCancelToken() {
    final token = dio.CancelToken();
    _activeCancelTokens.add(token);
    return token;
  }

  @override
  void close() {
    cancelAllRequests('Client closed');

    // 清理拦截器
    _interceptors.clear();

    // 关闭 Dio 实例
    _dio.close();
  }

  @override
  Map<String, String> get defaultHeaders {
    return Map<String, String>.from(_dio.options.headers);
  }

  @override
  void enableLogging() {
    if (_logInterceptor == null) {
      _logInterceptor = dio.LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          debugPrint('[Network] $obj');
        },
      );
      _dio.interceptors.add(_logInterceptor!);
    }
  }

  @override
  void disableLogging() {
    if (_logInterceptor != null) {
      _dio.interceptors.remove(_logInterceptor);
      _logInterceptor = null;
    }
  }

  // 私有辅助方法

  /// 获取按优先级排序的拦截器列表
  List<IRequestInterceptor> _getSortedInterceptors() {
    final sortedList = List<IRequestInterceptor>.from(_interceptors);
    sortedList.sort((a, b) => a.priority.compareTo(b.priority));
    return sortedList;
  }

  RequestOptions _buildRequestOptions({
    required RequestMethod method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    RequestOptions? options,
  }) {
    return RequestOptions(
      method: method,
      path: path,
      data: data,
      queryParameters: queryParameters ?? {},
      headers: options?.headers ?? {},
      responseType: options?.responseType ?? ResponseType.json,
      contentType: options?.contentType ?? ContentType.json,
      extra: options?.extra ?? {},
    );
  }

  dio.ResponseType _mapResponseType(ResponseType responseType) {
    switch (responseType) {
      case ResponseType.json:
        return dio.ResponseType.json;
      case ResponseType.string:
        return dio.ResponseType.plain;
      case ResponseType.bytes:
        return dio.ResponseType.bytes;
    }
  }

  String? _getContentTypeValue(ContentType? contentType) {
    switch (contentType) {
      case ContentType.json:
        return 'application/json; charset=utf-8';
      case ContentType.formUrlEncoded:
        return 'application/x-www-form-urlencoded; charset=utf-8';
      case ContentType.multipart:
        return 'multipart/form-data; charset=utf-8';
      default:
        return null;
    }
  }

  NetworkException _mapDioException(dio.DioException e) {
    switch (e.type) {
      case dio.DioExceptionType.connectionTimeout:
        return NetworkException(
          message: 'Connection timeout',
          code: 'connection_timeout',
          statusCode: null,
        );
      case dio.DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Receive timeout',
          code: 'receive_timeout',
          statusCode: null,
        );
      case dio.DioExceptionType.badResponse:
        return NetworkException(
          message: e.message ?? 'Server error',
          code: 'server_error',
          statusCode: e.response?.statusCode,
        );
      case dio.DioExceptionType.cancel:
        return NetworkException(
          message: 'Request cancelled',
          code: 'request_cancelled',
          statusCode: null,
        );
      default:
        return NetworkException(
          message: e.message ?? 'Unknown error',
          code: 'unknown_error',
          statusCode: e.response?.statusCode,
        );
    }
  }

  @override
  INetWorkConfig get networkConfig => _config;
}
