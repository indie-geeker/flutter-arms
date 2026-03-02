import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:interfaces/interfaces.dart';

import '../config/network_config.dart';
import '../interceptors/cache_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../interceptors/retry_interceptor.dart';
import '../utils/network_error_handler.dart';
import '../utils/proxy_configurator.dart';
import '../utils/web_file_download.dart';
import 'cancel_token_manager.dart';
import 'dio_form_data_adapter.dart';
import 'network_interceptor_adapter.dart';
import 'request_timeout_interceptor.dart';

/// Dio-based HTTP client implementation.
///
/// Implements [IHttpClient] using the Dio library with support for caching,
/// logging, retry, proxy configuration, and custom interceptors.
class DioHttpClient implements IHttpClient, DioRequestConverter {
  late final dio.Dio _dio;
  final ILogger _logger;
  final ICacheManager _cacheManager;
  final bool _enableLogging;
  final RetryConfig _retryConfig;
  final Duration _defaultCacheDuration;
  final NetworkCacheOptions? _defaultCacheOptions;
  late final CancelTokenManager _cancelTokenManager;

  DioHttpClient({
    required String baseUrl,
    required ILogger logger,
    required ICacheManager cacheManager,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, String> defaultHeaders = const {},
    bool enableLogging = true,
    RetryConfig retryConfig = const RetryConfig(),
    Duration defaultCacheDuration = const Duration(minutes: 5),
    NetworkCacheOptions? defaultCacheOptions,
    ProxyConfig? proxyConfig,
    dio.Dio? dioClient,
  }) : _logger = logger,
       _cacheManager = cacheManager,
       _enableLogging = enableLogging,
       _retryConfig = retryConfig,
       _defaultCacheDuration = defaultCacheDuration,
       _defaultCacheOptions = defaultCacheOptions {
    _cancelTokenManager = CancelTokenManager(logger);

    final mergedHeaders = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...defaultHeaders,
    };

    _dio =
        dioClient ??
        dio.Dio(
          dio.BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: connectTimeout ?? Duration(seconds: 30),
            receiveTimeout: receiveTimeout ?? Duration(seconds: 30),
            sendTimeout: sendTimeout ?? Duration(seconds: 30),
            headers: mergedHeaders,
          ),
        );

    if (dioClient != null) {
      _dio.options.baseUrl = baseUrl;
      _dio.options.connectTimeout =
          connectTimeout ??
          _dio.options.connectTimeout ??
          Duration(seconds: 30);
      _dio.options.receiveTimeout =
          receiveTimeout ??
          _dio.options.receiveTimeout ??
          Duration(seconds: 30);
      _dio.options.sendTimeout =
          sendTimeout ?? _dio.options.sendTimeout ?? Duration(seconds: 30);
      _dio.options.headers.addAll(mergedHeaders);
    }

    configureProxy(_dio, proxyConfig, _logger);
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(RequestTimeoutInterceptor());

    if (_enableLogging) {
      _dio.interceptors.add(LoggingInterceptor(_logger));
    }

    _dio.interceptors.add(
      CacheInterceptor(
        _cacheManager,
        _logger,
        defaultDuration: _defaultCacheDuration,
      ),
    );

    _dio.interceptors.add(
      RetryInterceptor(
        _logger,
        _dio,
        maxRetries: _retryConfig.maxRetries,
        retryDelay: _retryConfig.retryDelay,
        exponentialBackoff: _retryConfig.exponentialBackoff,
        retryableStatusCodes: _retryConfig.retryableStatusCodes,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IHttpClient — standard requests
  // ---------------------------------------------------------------------------

  @override
  Future<NetworkResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    NetworkCacheOptions? cacheOptions,
    CancelToken? cancelToken,
  }) async {
    return _request<T>(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      headers: headers,
      extra: extra,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      cacheOptions: cacheOptions,
      cancelToken: cancelToken,
    );
  }

  @override
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
  }) async {
    return _request<T>(
      method: 'POST',
      path: path,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      extra: extra,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      cacheOptions: cacheOptions,
      cancelToken: cancelToken,
    );
  }

  @override
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
  }) async {
    return _request<T>(
      method: 'PUT',
      path: path,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      extra: extra,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      cacheOptions: cacheOptions,
      cancelToken: cancelToken,
    );
  }

  @override
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
  }) async {
    return _request<T>(
      method: 'DELETE',
      path: path,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      extra: extra,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      cacheOptions: cacheOptions,
      cancelToken: cancelToken,
    );
  }

  // ---------------------------------------------------------------------------
  // IHttpClient — upload
  // ---------------------------------------------------------------------------

  @override
  Future<NetworkResponse<T>> upload<T>(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
    Map<String, dynamic>? extra,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    NetworkCacheOptions? cacheOptions,
    CancelToken? cancelToken,
  }) async {
    final dioToken = _cancelTokenManager.trackToken(cancelToken);
    try {
      final dioFormData = formData is DioFormDataAdapter
          ? await formData.toDioFormData()
          : throw ArgumentError('FormData must be DioFormDataAdapter');

      final response = await _dio.post(
        path,
        data: dioFormData,
        onSendProgress: onSendProgress,
        options: dio.Options(
          extra: _mergeExtra(extra, connectTimeout, cacheOptions),
          receiveTimeout: receiveTimeout,
        ),
        cancelToken: dioToken,
      );

      return _handleResponse<T>(response);
    } on dio.DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error in upload',
        error: e,
        stackTrace: stackTrace,
      );
      return NetworkResponse.failure(
        NetworkException(
          message: e.toString(),
          type: NetworkExceptionType.unknown,
        ),
      );
    } finally {
      _cancelTokenManager.untrack(dioToken);
    }
  }

  // ---------------------------------------------------------------------------
  // IHttpClient — download
  // ---------------------------------------------------------------------------

  @override
  Future<NetworkResponse> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? extra,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    NetworkCacheOptions? cacheOptions,
    CancelToken? cancelToken,
  }) async {
    final dioToken = _cancelTokenManager.trackToken(cancelToken);
    try {
      if (kIsWeb) {
        return await _downloadWeb(
          urlPath,
          savePath,
          onReceiveProgress: onReceiveProgress,
          extra: extra,
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          cacheOptions: cacheOptions,
          dioToken: dioToken,
        );
      }

      final response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: dio.Options(
          extra: _mergeExtra(extra, connectTimeout, cacheOptions),
          receiveTimeout: receiveTimeout,
        ),
        cancelToken: dioToken,
      );

      return NetworkResponse.success(
        null,
        statusCode: response.statusCode ?? 200,
        statusMessage: response.statusMessage,
        headers: response.headers.map,
      );
    } on dio.DioException catch (e) {
      return _handleError(e);
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error in download',
        error: e,
        stackTrace: stackTrace,
      );
      return NetworkResponse.failure(
        NetworkException(
          message: e.toString(),
          type: NetworkExceptionType.unknown,
        ),
      );
    } finally {
      _cancelTokenManager.untrack(dioToken);
    }
  }

  Future<NetworkResponse> _downloadWeb(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? extra,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    NetworkCacheOptions? cacheOptions,
    required dio.CancelToken dioToken,
  }) async {
    final response = await _dio.get<List<int>>(
      urlPath,
      onReceiveProgress: onReceiveProgress,
      options: dio.Options(
        extra: _mergeExtra(extra, connectTimeout, cacheOptions),
        receiveTimeout: receiveTimeout,
        responseType: dio.ResponseType.bytes,
      ),
      cancelToken: dioToken,
    );

    final data = response.data;
    if (data == null || data.isEmpty) {
      return NetworkResponse.failure(
        NetworkException(
          message: 'Download response is empty.',
          type: NetworkExceptionType.parseError,
          statusCode: response.statusCode,
        ),
      );
    }

    await triggerWebDownload(
      bytes: data,
      fileName: _resolveWebDownloadFileName(savePath, response),
      mimeType: _extractContentType(response),
    );

    return NetworkResponse.success(
      null,
      statusCode: response.statusCode ?? 200,
      statusMessage: response.statusMessage,
      headers: response.headers.map,
    );
  }

  // ---------------------------------------------------------------------------
  // IHttpClient — interceptors & cancel
  // ---------------------------------------------------------------------------

  @override
  void addInterceptor(INetworkInterceptor interceptor) {
    _dio.interceptors.add(
      NetworkInterceptorAdapter(interceptor, _logger, this),
    );
  }

  @override
  void cancelAllRequests() {
    _cancelTokenManager.cancelAll();
  }

  // ---------------------------------------------------------------------------
  // DioRequestConverter implementation
  // ---------------------------------------------------------------------------

  @override
  NetworkRequest toNetworkRequest(dio.RequestOptions options) {
    return NetworkRequest(
      path: options.path,
      method: options.method,
      queryParameters: options.queryParameters,
      headers: options.headers,
      data: options.data,
      connectTimeout: options.connectTimeout,
      receiveTimeout: options.receiveTimeout,
      extra: options.extra,
      cacheOptions: _extractCacheOptions(options.extra),
    );
  }

  @override
  void applyNetworkRequest(dio.RequestOptions options, NetworkRequest request) {
    options.path = request.path;
    options.method = request.method;
    options.queryParameters =
        request.queryParameters ?? options.queryParameters;
    options.headers = request.headers ?? options.headers;
    options.data = request.data ?? options.data;
    options.connectTimeout = request.connectTimeout ?? options.connectTimeout;
    options.receiveTimeout = request.receiveTimeout ?? options.receiveTimeout;
    options.extra =
        _mergeExtra(
          request.extra,
          request.connectTimeout,
          request.cacheOptions,
        ) ??
        options.extra;
  }

  @override
  NetworkResponse<T> toNetworkResponse<T>(dio.Response response) {
    return _handleResponse<T>(response);
  }

  @override
  void applyNetworkResponse(
    dio.Response response,
    NetworkResponse networkResponse,
  ) {
    response.data = networkResponse.data;
    response.statusCode = networkResponse.statusCode;
    response.statusMessage = networkResponse.statusMessage;
    if (networkResponse.headers != null) {
      final headerMap = <String, List<String>>{};
      networkResponse.headers!.forEach((key, value) {
        if (value is List<String>) {
          headerMap[key] = value;
        } else if (value is String) {
          headerMap[key] = [value];
        } else if (value != null) {
          headerMap[key] = [value.toString()];
        }
      });
      response.headers = dio.Headers.fromMap(headerMap);
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  NetworkResponse<T> _handleResponse<T>(dio.Response response) {
    return NetworkResponse.success(
      response.data as T,
      statusCode: response.statusCode ?? 200,
      statusMessage: response.statusMessage,
      headers: response.headers.map,
    );
  }

  NetworkResponse<T> _handleError<T>(dio.DioException error) {
    final exception = NetworkErrorHandler.handleDioException(error);
    _logger.error('Network request failed', error: error);
    return NetworkResponse.failure(
      exception,
      statusCode: exception.statusCode ?? 500,
      statusMessage: exception.message,
    );
  }

  Map<String, dynamic>? _mergeExtra(
    Map<String, dynamic>? extra,
    Duration? connectTimeout,
    NetworkCacheOptions? cacheOptions,
  ) {
    final resolvedCacheOptions = cacheOptions ?? _defaultCacheOptions;
    if (extra == null &&
        connectTimeout == null &&
        resolvedCacheOptions == null) {
      return null;
    }

    final merged = extra != null
        ? Map<String, dynamic>.from(extra)
        : <String, dynamic>{};
    if (connectTimeout != null) {
      merged[connectTimeoutExtraKey] = connectTimeout;
    }
    if (resolvedCacheOptions != null) {
      merged[NetworkCacheOptions.extraKey] = resolvedCacheOptions;
    }
    return merged;
  }

  NetworkCacheOptions? _extractCacheOptions(Map<String, dynamic> extra) {
    final value = extra[NetworkCacheOptions.extraKey];
    if (value is NetworkCacheOptions) {
      return value;
    }
    return null;
  }

  Future<NetworkResponse<T>> _request<T>({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    NetworkCacheOptions? cacheOptions,
    CancelToken? cancelToken,
  }) async {
    final dioToken = _cancelTokenManager.trackToken(cancelToken);
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: dio.Options(
          method: method,
          headers: headers,
          extra: _mergeExtra(extra, connectTimeout, cacheOptions),
          receiveTimeout: receiveTimeout,
        ),
        cancelToken: dioToken,
      );
      return _handleResponse<T>(response);
    } on dio.DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error in $method request',
        error: e,
        stackTrace: stackTrace,
      );
      return NetworkResponse.failure(
        NetworkException(
          message: e.toString(),
          type: NetworkExceptionType.unknown,
        ),
      );
    } finally {
      _cancelTokenManager.untrack(dioToken);
    }
  }

  // ---------------------------------------------------------------------------
  // Download filename helpers
  // ---------------------------------------------------------------------------

  String _resolveWebDownloadFileName(
    String savePath,
    dio.Response<List<int>> response,
  ) {
    final fromPath = _extractFileNameFromPath(savePath);
    if (fromPath != null) return fromPath;

    final contentDisposition = response.headers.value('content-disposition');
    final fromHeader = _extractFileNameFromContentDisposition(
      contentDisposition,
    );
    if (fromHeader != null) return fromHeader;

    return 'download-${DateTime.now().millisecondsSinceEpoch}.bin';
  }

  String? _extractFileNameFromPath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return null;

    final normalized = trimmed.replaceAll('\\', '/');
    final lastSegment = normalized.split('/').last.trim();
    if (lastSegment.isEmpty || lastSegment == '.') {
      return null;
    }
    return lastSegment;
  }

  String? _extractFileNameFromContentDisposition(String? headerValue) {
    if (headerValue == null || headerValue.trim().isEmpty) return null;

    final utf8Match = RegExp(
      r"filename\*\s*=\s*UTF-8''([^;]+)",
      caseSensitive: false,
    ).firstMatch(headerValue);
    if (utf8Match != null) {
      return Uri.decodeComponent(utf8Match.group(1)!.trim());
    }

    final quotedMatch = RegExp(
      r'filename\s*=\s*"([^"]+)"',
      caseSensitive: false,
    ).firstMatch(headerValue);
    if (quotedMatch != null) {
      return quotedMatch.group(1)!.trim();
    }

    final plainMatch = RegExp(
      r'filename\s*=\s*([^;]+)',
      caseSensitive: false,
    ).firstMatch(headerValue);
    if (plainMatch != null) {
      final value = plainMatch.group(1)!.trim();
      if (value.isNotEmpty) {
        return value.replaceAll('"', '');
      }
    }
    return null;
  }

  String? _extractContentType(dio.Response<List<int>> response) {
    final value = response.headers.value('content-type');
    if (value == null || value.trim().isEmpty) return null;
    return value.split(';').first.trim();
  }
}
