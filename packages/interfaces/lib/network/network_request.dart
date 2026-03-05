import 'network_cache_options.dart';

/// Network request wrapper.
class NetworkRequest {
  /// Request path.
  final String path;

  /// HTTP method.
  final String method;

  /// Query parameters.
  final Map<String, dynamic>? queryParameters;

  /// Request headers.
  final Map<String, dynamic>? headers;

  /// Request body data.
  final dynamic data;

  /// Connection timeout.
  final Duration? connectTimeout;

  /// Receive timeout.
  final Duration? receiveTimeout;

  /// Extra configuration (for passing custom parameters).
  final Map<String, dynamic>? extra;

  /// Cache configuration.
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

  /// Creates a GET request.
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

  /// Creates a POST request.
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

  /// Creates a PUT request.
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

  /// Creates a DELETE request.
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

  /// Generates a cache key.
  String toCacheKey() {
    final uri = path;
    final params = queryParameters?.toString() ?? '';
    return 'http_cache:$uri:$params';
  }
}
