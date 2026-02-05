
import 'package:dio/dio.dart' as dio;
import 'package:interfaces/interfaces.dart';

import '../interceptors/cache_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../interceptors/retry_interceptor.dart';
import '../utils/network_error_handler.dart';
import 'dio_cancel_token_adapter.dart';
import 'dio_form_data_adapter.dart';

const _connectTimeoutExtraKey = 'connect_timeout';

/// 基于 Dio 的 HTTP 客户端实现
class DioHttpClient implements IHttpClient {
  late final dio.Dio _dio;
  final ILogger _logger;
  final ICacheManager _cacheManager;
  
  /// 活跃的 CancelToken 集合，用于批量取消请求
  final Set<dio.CancelToken> _activeTokens = {};

  DioHttpClient({
    required String baseUrl,
    required ILogger logger,
    required ICacheManager cacheManager,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    dio.Dio? dioClient,
  })  : _logger = logger,
        _cacheManager = cacheManager {
    _dio = dioClient ??
        dio.Dio(
          dio.BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: connectTimeout ?? Duration(seconds: 30),
            receiveTimeout: receiveTimeout ?? Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    if (dioClient != null) {
      _dio.options.baseUrl = baseUrl;
      _dio.options.connectTimeout =
          connectTimeout ?? _dio.options.connectTimeout ?? Duration(seconds: 30);
      _dio.options.receiveTimeout =
          receiveTimeout ?? _dio.options.receiveTimeout ?? Duration(seconds: 30);
      _dio.options.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
    }

    // 添加默认拦截器
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // 0. 超时配置拦截器
    _dio.interceptors.add(_RequestTimeoutInterceptor());

    // 1. 日志拦截器
    _dio.interceptors.add(LoggingInterceptor(_logger));

    // 2. 缓存拦截器
    _dio.interceptors.add(CacheInterceptor(_cacheManager, _logger));

    // 3. 重试拦截器 (传入原始 Dio 实例以保留配置)
    _dio.interceptors.add(RetryInterceptor(_logger, _dio));
  }

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
    final dioToken = _convertCancelToken(cancelToken);
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: dio.Options(
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
      _logger.error('Unexpected error in GET request', error: e, stackTrace: stackTrace);
      return NetworkResponse.failure(
        NetworkException(message: e.toString(), type: NetworkExceptionType.unknown),
      );
    } finally {
      _removeActiveToken(dioToken);
    }
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
    final dioToken = _convertCancelToken(cancelToken);
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: dio.Options(
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
      _logger.error('Unexpected error in POST request', error: e, stackTrace: stackTrace);
      return NetworkResponse.failure(
        NetworkException(message: e.toString(), type: NetworkExceptionType.unknown),
      );
    } finally {
      _removeActiveToken(dioToken);
    }
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
    final dioToken = _convertCancelToken(cancelToken);
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: dio.Options(
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
      _logger.error('Unexpected error in PUT request', error: e, stackTrace: stackTrace);
      return NetworkResponse.failure(
        NetworkException(message: e.toString(), type: NetworkExceptionType.unknown),
      );
    } finally {
      _removeActiveToken(dioToken);
    }
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
    final dioToken = _convertCancelToken(cancelToken);
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: dio.Options(
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
      _logger.error('Unexpected error in DELETE request', error: e, stackTrace: stackTrace);
      return NetworkResponse.failure(
        NetworkException(message: e.toString(), type: NetworkExceptionType.unknown),
      );
    } finally {
      _removeActiveToken(dioToken);
    }
  }

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
    final dioToken = _convertCancelToken(cancelToken);
    try {
      // 将 FormData 适配为 Dio FormData
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
      _logger.error('Unexpected error in upload', error: e, stackTrace: stackTrace);
      return NetworkResponse.failure(
        NetworkException(message: e.toString(), type: NetworkExceptionType.unknown),
      );
    } finally {
      _removeActiveToken(dioToken);
    }
  }

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
    final dioToken = _convertCancelToken(cancelToken);
    try {
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
      );
    } on dio.DioException catch (e) {
      return _handleError(e);
    } catch (e, stackTrace) {
      _logger.error('Unexpected error in download', error: e, stackTrace: stackTrace);
      return NetworkResponse.failure(
        NetworkException(message: e.toString(), type: NetworkExceptionType.unknown),
      );
    } finally {
      _removeActiveToken(dioToken);
    }
  }

  @override
  void addInterceptor(INetworkInterceptor interceptor) {
    _dio.interceptors.add(_NetworkInterceptorAdapter(interceptor, _logger, this));
  }

  @override
  void cancelAllRequests() {
    _logger.info('Cancelling ${_activeTokens.length} active network requests');
    for (final token in _activeTokens.toList()) {
      if (!token.isCancelled) {
        token.cancel('Cancelled by cancelAllRequests()');
      }
    }
    _activeTokens.clear();
  }

  /// 处理成功响应
  NetworkResponse<T> _handleResponse<T>(dio.Response response) {
    return NetworkResponse.success(
      response.data as T,
      statusCode: response.statusCode ?? 200,
      statusMessage: response.statusMessage,
      headers: response.headers.map,
    );
  }

  /// 处理错误响应
  NetworkResponse<T> _handleError<T>(dio.DioException error) {
    // 使用 NetworkErrorHandler 统一处理错误
    final exception = NetworkErrorHandler.handleDioException(error);

    _logger.error('Network request failed', error: error);

    return NetworkResponse.failure(
      exception,
      statusCode: exception.statusCode ?? 500,
      statusMessage: exception.message,
    );
  }

  /// 转换 CancelToken 并将其加入活跃追踪
  dio.CancelToken? _convertCancelToken(CancelToken? token) {
    dio.CancelToken dioToken;
    
    if (token == null) {
      // 无 token 时创建新 token 用于追踪
      dioToken = dio.CancelToken();
    } else if (token is DioCancelTokenAdapter) {
      dioToken = token.dioToken;
    } else {
      // 如果是其他实现，创建一个新的 Dio CancelToken
      dioToken = dio.CancelToken();
      if (token.isCancelled) {
        dioToken.cancel('Cancelled before request');
      } else {
        token.addListener((reason) {
          if (!dioToken.isCancelled) {
            dioToken.cancel(reason);
          }
        });
      }
    }
    
    // 添加到活跃 token 集合
    _activeTokens.add(dioToken);
    
    return dioToken;
  }
  
  /// 从活跃追踪中移除 token（请求完成后调用）
  void _removeActiveToken(dio.CancelToken? token) {
    if (token != null) {
      _activeTokens.remove(token);
    }
  }

  Map<String, dynamic>? _mergeExtra(
    Map<String, dynamic>? extra,
    Duration? connectTimeout,
    NetworkCacheOptions? cacheOptions,
  ) {
    if (extra == null && connectTimeout == null && cacheOptions == null) {
      return null;
    }

    final merged =
        extra != null ? Map<String, dynamic>.from(extra) : <String, dynamic>{};
    if (connectTimeout != null) {
      merged[_connectTimeoutExtraKey] = connectTimeout;
    }
    if (cacheOptions != null) {
      merged[NetworkCacheOptions.extraKey] = cacheOptions;
    }
    return merged;
  }

  NetworkRequest _toNetworkRequest(dio.RequestOptions options) {
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

  void _applyNetworkRequest(dio.RequestOptions options, NetworkRequest request) {
    options.path = request.path;
    options.method = request.method;
    options.queryParameters = request.queryParameters ?? options.queryParameters;
    options.headers = request.headers ?? options.headers;
    options.data = request.data ?? options.data;
    options.connectTimeout = request.connectTimeout ?? options.connectTimeout;
    options.receiveTimeout = request.receiveTimeout ?? options.receiveTimeout;
    options.extra = _mergeExtra(
          request.extra,
          request.connectTimeout,
          request.cacheOptions,
        ) ??
        options.extra;
  }

  NetworkResponse<T> _toNetworkResponse<T>(dio.Response response) {
    return NetworkResponse.success(
      response.data as T,
      statusCode: response.statusCode ?? 200,
      statusMessage: response.statusMessage,
      headers: response.headers.map,
    );
  }

  void _applyNetworkResponse(dio.Response response, NetworkResponse networkResponse) {
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

  NetworkCacheOptions? _extractCacheOptions(Map<String, dynamic> extra) {
    final value = extra[NetworkCacheOptions.extraKey];
    if (value is NetworkCacheOptions) {
      return value;
    }
    return null;
  }
}

/// 从 extra 中应用请求级 connectTimeout
class _RequestTimeoutInterceptor extends dio.Interceptor {
  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    final extra = options.extra;
    final connectTimeout = extra[_connectTimeoutExtraKey];
    if (connectTimeout is Duration) {
      options.connectTimeout = connectTimeout;
    }
    handler.next(options);
  }
}

/// 网络拦截器适配器
class _NetworkInterceptorAdapter extends dio.Interceptor {
  final INetworkInterceptor _interceptor;
  final ILogger _logger;
  final DioHttpClient _client;

  _NetworkInterceptorAdapter(this._interceptor, this._logger, this._client);

  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) async {
    try {
      final request = _client._toNetworkRequest(options);
      final updated = await _interceptor.onRequest(request);
      if (updated == null) {
        return handler.reject(
          dio.DioException(
            requestOptions: options,
            type: dio.DioExceptionType.cancel,
            error: 'Request cancelled by interceptor',
          ),
        );
      }
      _client._applyNetworkRequest(options, updated);
    } catch (e, stackTrace) {
      _logger.error('Network interceptor onRequest failed', error: e, stackTrace: stackTrace);
    }
    handler.next(options);
  }

  @override
  void onResponse(dio.Response response, dio.ResponseInterceptorHandler handler) {
    () async {
      try {
        final networkResponse = _client._toNetworkResponse(response);
        final updated = await _interceptor.onResponse(networkResponse);
        _client._applyNetworkResponse(response, updated);
      } catch (e, stackTrace) {
        _logger.error('Network interceptor onResponse failed', error: e, stackTrace: stackTrace);
      }
      handler.next(response);
    }();
  }

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    () async {
      try {
        final exception = NetworkErrorHandler.handleDioException(err);
        final recovery = await _interceptor.onError(exception);
        if (recovery.isSuccess) {
          final response = dio.Response(
            requestOptions: err.requestOptions,
            data: recovery.data,
            statusCode: recovery.statusCode,
            statusMessage: recovery.statusMessage,
          );
          _client._applyNetworkResponse(response, recovery);
          return handler.resolve(response);
        }
      } catch (e, stackTrace) {
        _logger.error('Network interceptor onError failed', error: e, stackTrace: stackTrace);
      }
      handler.next(err);
    }();
  }
}
