import 'package:app_interfaces/app_interfaces.dart';

/// No-op network client implementation
///
/// Used when the application doesn't require network functionality
/// or when INetWorkConfig is not implemented.
class NoOpNetworkClient implements INetworkClient {
  @override
  Future<ApiResponse<T>> request<T>({
    required RequestOptions options,
    Object? cancelToken,
  }) async {
    throw UnsupportedError(
      'Network functionality is not configured. '
      'Please implement INetWorkConfig in your config class '
      'or provide a custom NetworkClient.',
    );
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    RequestOptions? options,
    Object? cancelToken,
  }) async {
    throw UnsupportedError('Network functionality is not configured.');
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    RequestOptions? options,
    Object? cancelToken,
  }) async {
    throw UnsupportedError('Network functionality is not configured.');
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    RequestOptions? options,
    Object? cancelToken,
  }) async {
    throw UnsupportedError('Network functionality is not configured.');
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    RequestOptions? options,
    Object? cancelToken,
  }) async {
    throw UnsupportedError('Network functionality is not configured.');
  }

  @override
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    RequestOptions? options,
    Object? cancelToken,
  }) async {
    throw UnsupportedError('Network functionality is not configured.');
  }

  @override
  Future<ApiResponse<String>> download(
    String url,
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
    Object? cancelToken,
  }) async {
    throw UnsupportedError('Network functionality is not configured.');
  }

  @override
  void configure(EnvironmentType environmentType, {String? baseUrl}) {
    // No-op
  }

  @override
  void setBaseUrl(String baseUrl) {
    // No-op
  }

  @override
  void setDefaultHeaders(Map<String, String> headers) {
    // No-op
  }

  @override
  void setTimeout({int? connectTimeout, int? receiveTimeout}) {
    // No-op
  }

  @override
  void addInterceptor(IRequestInterceptor interceptor) {
    // No-op
  }

  @override
  void removeInterceptor(IRequestInterceptor interceptor) {
    // No-op
  }

  @override
  void clearInterceptors() {
    // No-op
  }

  @override
  Object createCancelToken() {
    return Object();
  }

  @override
  void cancelRequest(Object cancelToken, [String? reason]) {
    // No-op
  }

  @override
  void cancelAllRequests([String? reason]) {
    // No-op
  }

  @override
  void enableLogging() {
    // No-op
  }

  @override
  void disableLogging() {
    // No-op
  }

  @override
  void close() {
    // No-op
  }

  @override
  Map<String, String> get defaultHeaders => {};

  @override
  INetWorkConfig get networkConfig => throw UnsupportedError(
        'Network functionality is not configured.',
      );
}
