import 'i_network_interceptor.dart';
import 'network_cache_options.dart';
import 'network_response.dart';
import 'network_types.dart';

/// Abstract HTTP client interface.
///
/// Defines the contract for all HTTP operations. Implementations (e.g., Dio)
/// live in `packages/modules/module_network`.
abstract class IHttpClient {
  /// Sends a GET request to [path].
  Future<NetworkResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    NetworkCacheOptions? cacheOptions,
    CancelToken? cancelToken,
  });

  /// Sends a POST request to [path].
  Future<NetworkResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    NetworkCacheOptions? cacheOptions,
    CancelToken? cancelToken,
  });

  /// Sends a PUT request to [path].
  Future<NetworkResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    NetworkCacheOptions? cacheOptions,
    CancelToken? cancelToken,
  });

  /// Sends a DELETE request to [path].
  Future<NetworkResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    NetworkCacheOptions? cacheOptions,
    CancelToken? cancelToken,
  });

  /// Uploads a file using multipart form data.
  Future<NetworkResponse<T>> upload<T>(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
    Map<String, dynamic>? extra,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    NetworkCacheOptions? cacheOptions,
    CancelToken? cancelToken,
  });

  /// Downloads a file from [urlPath] and saves it to [savePath].
  Future<NetworkResponse> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? extra,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    NetworkCacheOptions? cacheOptions,
    CancelToken? cancelToken,
  });

  /// Adds a network interceptor to the request pipeline.
  void addInterceptor(INetworkInterceptor interceptor);

  /// Cancels all in-progress requests.
  void cancelAllRequests();
}
