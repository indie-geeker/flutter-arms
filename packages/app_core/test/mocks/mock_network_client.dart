import 'package:app_interfaces/app_interfaces.dart';

/// Mock 网络客户端实现
/// 
/// 用于测试环境，避免 app_core 模块直接依赖 app_network 模块
class MockNetworkClient implements INetworkClient {
  final Map<String, ApiResponse> _mockResponses = {};
  final List<String> _requestHistory = [];
  bool _shouldThrowError = false;
  NetworkException? _mockError;

  /// 设置模拟响应
  void setMockResponse(String key, ApiResponse response) {
    _mockResponses[key] = response;
  }

  /// 设置是否抛出错误
  void setShouldThrowError(bool shouldThrow, [NetworkException? error]) {
    _shouldThrowError = shouldThrow;
    _mockError = error;
  }

  /// 获取请求历史
  List<String> get requestHistory => List.unmodifiable(_requestHistory);

  /// 清理状态
  void reset() {
    _mockResponses.clear();
    _requestHistory.clear();
    _shouldThrowError = false;
    _mockError = null;
  }

  String _generateKey(String method, String path) {
    return '$method:$path';
  }

  @override
  Future<ApiResponse<T>> request<T>({
    required RequestOptions options,
    Object? cancelToken,
  }) async {
    final key = _generateKey(options.method.name.toUpperCase(), options.path);
    _requestHistory.add(key);

    if (_shouldThrowError) {
      throw _mockError ?? const NetworkException(
        message: 'Mock network error',
        code: 'mock_error',
      );
    }

    final mockResponse = _mockResponses[key];
    if (mockResponse != null) {
      return ApiResponse<T>(
        code: mockResponse.code,
        data: mockResponse.data as T,
        message: mockResponse.message,
        extra: mockResponse.extra,
      );
    }

    // 默认成功响应
    return ApiResponse<T>(
      code: 200,
      data: {'message': 'Mock response for $key'} as T,
      message: 'OK',
      extra: {},
    );
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    RequestOptions? options,
    Object? cancelToken,
  }) async {
    final requestOptions = RequestOptions(
      method: RequestMethod.get,
      path: path,
      queryParameters: queryParameters,
      headers: options?.headers ?? {},
    );

    return request<T>(
      options: requestOptions,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    RequestOptions? options,
    Object? cancelToken,
  }) async {
    final requestOptions = RequestOptions(
      method: RequestMethod.post,
      path: path,
      data: data,
      queryParameters: queryParameters,
      headers: options?.headers ?? {},
    );

    return request<T>(
      options: requestOptions,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    RequestOptions? options,
    Object? cancelToken,
  }) async {
    final requestOptions = RequestOptions(
      method: RequestMethod.put,
      path: path,
      data: data,
      queryParameters: queryParameters,
      headers: options?.headers ?? {},
    );

    return request<T>(
      options: requestOptions,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    RequestOptions? options,
    Object? cancelToken,
  }) async {
    final requestOptions = RequestOptions(
      method: RequestMethod.patch,
      path: path,
      data: data,
      queryParameters: queryParameters,
      headers: options?.headers ?? {},
    );

    return request<T>(
      options: requestOptions,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    RequestOptions? options,
    Object? cancelToken,
  }) async {
    final requestOptions = RequestOptions(
      method: RequestMethod.delete,
      path: path,
      data: data,
      queryParameters: queryParameters,
      headers: options?.headers ?? {},
    );

    return request<T>(
      options: requestOptions,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<ApiResponse<String>> download(
    String url,
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
    Object? cancelToken,
  }) async {
    _requestHistory.add('DOWNLOAD:$url');

    if (_shouldThrowError) {
      throw _mockError ?? const NetworkException(
        message: 'Mock download error',
        code: 'mock_download_error',
      );
    }

    return ApiResponse<String>(
      code: 200,
      data: '/mock/download/path',
      message: 'Mock download completed',
      extra: {},
    );
  }

  @override
  void setBaseUrl(String baseUrl) {
    // Mock implementation - do nothing
  }

  @override
  void setDefaultHeaders(Map<String, String> headers) {
    // Mock implementation - do nothing
  }

  @override
  void setTimeout({int? connectTimeout, int? receiveTimeout}) {
    // Mock implementation - do nothing
  }

  @override
  void addInterceptor(IRequestInterceptor interceptor) {
    // Mock implementation - do nothing
  }

  @override
  void removeInterceptor(IRequestInterceptor interceptor) {
    // Mock implementation - do nothing
  }

  @override
  void clearInterceptors() {
    // Mock implementation - do nothing
  }

  @override
  void cancelAllRequests([String? reason]) {
    // Mock implementation - do nothing
  }

  @override
  void cancelRequest(Object cancelToken, [String? reason]) {
    // Mock implementation - do nothing
  }

  @override
  void configure(EnvironmentType environmentType, {String? baseUrl}) {
    // Mock implementation - do nothing
  }

  @override
  Object createCancelToken() {
    return Object(); // Mock cancel token
  }

  @override
  void close() {
    reset();
  }

  @override
  Map<String, String> get defaultHeaders => {};

  @override
  void enableLogging() {
    // Mock implementation - do nothing
  }

  @override
  void disableLogging() {
    // Mock implementation - do nothing
  }

  @override
  INetWorkConfig get networkConfig => MockNetworkConfig();
}

class MockNetworkConfig implements INetWorkConfig{
  @override
  String get baseUrl => "localhost";

  @override
  Duration get connectTimeout => Duration(seconds: 30);

  @override
  Duration get receiveTimeout => Duration(seconds: 30);

  @override
  CachePolicyConfig get cachePolicyConfig => const CachePolicyConfig(
        defaultPolicy: CachePolicy.networkFirst,
        defaultMaxAge: Duration(minutes: 5),
        enableDiskCache: false,
      );

  @override
  RetryConfig get retryConfig => const RetryConfig(
        maxRetries: 3,
        initialDelay: Duration(milliseconds: 500),
      );
}
