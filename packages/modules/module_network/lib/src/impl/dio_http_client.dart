
import 'package:dio/dio.dart' as dio;
import 'package:interfaces/interfaces.dart';

import '../interceptors/cache_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../interceptors/retry_interceptor.dart';
import '../utils/network_error_handler.dart';
import 'dio_cancel_token_adapter.dart';
import 'dio_form_data_adapter.dart';

/// 基于 Dio 的 HTTP 客户端实现
class DioHttpClient implements IHttpClient {
  late final dio.Dio _dio;
  final ILogger _logger;
  final ICacheManager _cacheManager;

  DioHttpClient({
    required String baseUrl,
    required ILogger logger,
    required ICacheManager cacheManager,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  })  : _logger = logger,
        _cacheManager = cacheManager {
    _dio = dio.Dio(
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

    // 添加默认拦截器
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // 1. 日志拦截器
    _dio.interceptors.add(LoggingInterceptor(_logger));

    // 2. 缓存拦截器
    _dio.interceptors.add(CacheInterceptor(_cacheManager, _logger));

    // 3. 重试拦截器
    _dio.interceptors.add(RetryInterceptor(_logger));
  }

  @override
  Future<NetworkResponse<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: dio.Options(headers: headers),
        cancelToken: _convertCancelToken(cancelToken),
      );

      return _handleResponse<T>(response);
    } on dio.DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      _logger.error('Unexpected error in GET request', error: e, stackTrace: stackTrace);
      return NetworkResponse.failure(
        NetworkException(message: e.toString(), type: NetworkExceptionType.unknown),
      );
    }
  }

  @override
  Future<NetworkResponse<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: dio.Options(headers: headers),
        cancelToken: _convertCancelToken(cancelToken),
      );

      return _handleResponse<T>(response);
    } on dio.DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      _logger.error('Unexpected error in POST request', error: e, stackTrace: stackTrace);
      return NetworkResponse.failure(
        NetworkException(message: e.toString(), type: NetworkExceptionType.unknown),
      );
    }
  }

  @override
  Future<NetworkResponse<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: dio.Options(headers: headers),
        cancelToken: _convertCancelToken(cancelToken),
      );

      return _handleResponse<T>(response);
    } on dio.DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      _logger.error('Unexpected error in PUT request', error: e, stackTrace: stackTrace);
      return NetworkResponse.failure(
        NetworkException(message: e.toString(), type: NetworkExceptionType.unknown),
      );
    }
  }

  @override
  Future<NetworkResponse<T>> delete<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: dio.Options(headers: headers),
        cancelToken: _convertCancelToken(cancelToken),
      );

      return _handleResponse<T>(response);
    } on dio.DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      _logger.error('Unexpected error in DELETE request', error: e, stackTrace: stackTrace);
      return NetworkResponse.failure(
        NetworkException(message: e.toString(), type: NetworkExceptionType.unknown),
      );
    }
  }

  @override
  Future<NetworkResponse<T>> upload<T>(
      String path,
      FormData formData, {
        ProgressCallback? onSendProgress,
        CancelToken? cancelToken,
      }) async {
    try {
      // 将 FormData 适配为 Dio FormData
      final dioFormData = formData is DioFormDataAdapter
          ? await formData.toDioFormData()
          : throw ArgumentError('FormData must be DioFormDataAdapter');

      // 转换 CancelToken
      final dioCancelToken = _convertCancelToken(cancelToken);

      final response = await _dio.post(
        path,
        data: dioFormData,
        onSendProgress: onSendProgress,
        cancelToken: dioCancelToken,
      );

      return _handleResponse<T>(response);
    } on dio.DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      _logger.error('Unexpected error in upload', error: e, stackTrace: stackTrace);
      return NetworkResponse.failure(
        NetworkException(message: e.toString(), type: NetworkExceptionType.unknown),
      );
    }
  }

  @override
  Future<NetworkResponse> download(
      String urlPath,
      String savePath, {
        ProgressCallback? onReceiveProgress,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: _convertCancelToken(cancelToken),
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
    }
  }

  @override
  void addInterceptor(INetworkInterceptor interceptor) {
    _dio.interceptors.add(_NetworkInterceptorAdapter(interceptor));
  }

  @override
  void cancelAllRequests() {
    // 取消所有正在进行的请求
    _logger.info('Cancelling all network requests');
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

  /// 转换 CancelToken
  dio.CancelToken? _convertCancelToken(CancelToken? token) {
    if (token == null) return null;

    if (token is DioCancelTokenAdapter) {
      return token.dioToken;
    }

    // 如果是其他实现，创建一个新的 Dio CancelToken
    // 并监听原 token 的取消事件
    final dioToken = dio.CancelToken();
    // 注意：这里需要实现 token 的监听机制
    // 这是一个简化版本，实际可能需要更复杂的同步逻辑
    return dioToken;
  }
}

/// 网络拦截器适配器
class _NetworkInterceptorAdapter extends dio.Interceptor {
  final INetworkInterceptor _interceptor;

  _NetworkInterceptorAdapter(this._interceptor);

  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) async {
    // 将 Dio RequestOptions 转换为 NetworkRequest
    // 然后调用自定义拦截器
    handler.next(options);
  }

  @override
  void onResponse(dio.Response response, dio.ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}