import 'package:dio/dio.dart' as dio;
import 'package:interfaces/interfaces.dart';

import '../utils/network_error_handler.dart';

/// Callback interface for converting between Dio and framework types.
///
/// This allows [NetworkInterceptorAdapter] to work with [DioHttpClient]
/// without creating a circular dependency or exposing private methods.
abstract class DioRequestConverter {
  /// Converts Dio request options to a framework [NetworkRequest].
  NetworkRequest toNetworkRequest(dio.RequestOptions options);

  /// Applies framework [NetworkRequest] modifications back to Dio options.
  void applyNetworkRequest(dio.RequestOptions options, NetworkRequest request);

  /// Converts a Dio response to a framework [NetworkResponse].
  NetworkResponse<T> toNetworkResponse<T>(dio.Response response);

  /// Applies framework [NetworkResponse] modifications back to a Dio response.
  void applyNetworkResponse(
    dio.Response response,
    NetworkResponse networkResponse,
  );
}

/// Adapts framework-level [INetworkInterceptor] to Dio's [dio.Interceptor].
///
/// This fixes the previous async IIFE pattern by using proper async method
/// signatures, ensuring async exceptions propagate correctly.
class NetworkInterceptorAdapter extends dio.Interceptor {
  final INetworkInterceptor _interceptor;
  final ILogger _logger;
  final DioRequestConverter _converter;

  NetworkInterceptorAdapter(this._interceptor, this._logger, this._converter);

  @override
  Future<void> onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) async {
    try {
      final request = _converter.toNetworkRequest(options);
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
      _converter.applyNetworkRequest(options, updated);
    } catch (e, stackTrace) {
      _logger.error(
        'Network interceptor onRequest failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    dio.Response response,
    dio.ResponseInterceptorHandler handler,
  ) async {
    try {
      final networkResponse = _converter.toNetworkResponse(response);
      final updated = await _interceptor.onResponse(networkResponse);
      _converter.applyNetworkResponse(response, updated);
    } catch (e, stackTrace) {
      _logger.error(
        'Network interceptor onResponse failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    dio.DioException err,
    dio.ErrorInterceptorHandler handler,
  ) async {
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
        _converter.applyNetworkResponse(response, recovery);
        return handler.resolve(response);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Network interceptor onError failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
    handler.next(err);
  }
}
