import 'package:app_interfaces/app_interfaces.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';

class NetworkClient implements INetworkClient {
  late final dio.Dio _dio;
  final List<IRequestInterceptor> _interceptors = [];
  final Set<dio.CancelToken> _activeCancelTokens = <dio.CancelToken>{};

  dio.LogInterceptor? _logInterceptor;

  // 请求去重相关
  final Map<String, Future<ApiResponse>> _pendingRequests = {};
  final Map<String, DateTime> _requestTimestamps = {};

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
    // 生成请求键用于去重
    final requestKey = _generateRequestKey(options);

    // 检查是否有相同的请求正在进行
    if (_pendingRequests.containsKey(requestKey)) {
      debugPrint('[Network] 请求去重: ${options.method.name} ${options.path}');
      return _pendingRequests[requestKey]! as Future<ApiResponse<T>>;
    }

    // 创建请求执行器
    final requestFuture = _executeRequestWithInterceptors<T>(options, cancelToken);

    // 缓存正在进行的请求
    _pendingRequests[requestKey] = requestFuture;
    _requestTimestamps[requestKey] = DateTime.now();

    try {
      final result = await requestFuture;
      return result;
    } finally {
      // 清理已完成的请求
      _pendingRequests.remove(requestKey);
      _requestTimestamps.remove(requestKey);
    }
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

      // 定期清理过期请求
      _cleanupExpiredRequests();
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

    // 清理请求去重缓存
    _pendingRequests.clear();
    _requestTimestamps.clear();

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

  /// 获取请求去重统计信息
  Map<String, dynamic> getRequestDeduplicationStats() {
    return {
      'pending_requests_count': _pendingRequests.length,
      'cached_timestamps_count': _requestTimestamps.length,
      'oldest_request_age_minutes': _getOldestRequestAge(),
    };
  }

  /// 获取最旧请求的年龄（分钟）
  int _getOldestRequestAge() {
    if (_requestTimestamps.isEmpty) return 0;

    final now = DateTime.now();
    final oldestTimestamp = _requestTimestamps.values.reduce(
            (a, b) => a.isBefore(b) ? a : b
    );

    return now.difference(oldestTimestamp).inMinutes;
  }

  // 私有辅助方法

  /// 获取按优先级排序的拦截器列表
  List<IRequestInterceptor> _getSortedInterceptors() {
    final sortedList = List<IRequestInterceptor>.from(_interceptors);
    sortedList.sort((a, b) => a.priority.compareTo(b.priority));
    return sortedList;
  }

  /// 生成请求键用于去重
  String _generateRequestKey(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.write(options.method.name);
    buffer.write('|');
    buffer.write(options.path);

    // 添加查询参数
    if (options.queryParameters?.isNotEmpty == true) {
      final sortedParams = Map.fromEntries(
        options.queryParameters!.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      );
      buffer.write('|');
      buffer.write(Uri(queryParameters: sortedParams.map((k, v) => MapEntry(k, v.toString()))).query);
    }

    // 添加请求体（仅对于 POST/PUT/PATCH 请求）
    if (options.data != null && _isModifyingMethod(options.method)) {
      buffer.write('|');
      buffer.write(options.data.toString().hashCode);
    }

    return buffer.toString();
  }

  /// 检查是否为修改性方法
  bool _isModifyingMethod(RequestMethod method) {
    return method == RequestMethod.post ||
        method == RequestMethod.put ||
        method == RequestMethod.delete ||
        method == RequestMethod.patch;
  }

  /// 清理过期的请求缓存
  void _cleanupExpiredRequests() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _requestTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp).inMinutes > 5) { // 5分钟过期
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _pendingRequests.remove(key);
      _requestTimestamps.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      debugPrint('[Network] 清理了 ${expiredKeys.length} 个过期请求缓存');
    }
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
