
import 'package:dio/dio.dart';
import 'package:interfaces/interfaces.dart';

/// 网络请求日志拦截器
class LoggingInterceptor extends Interceptor {
  final ILogger _logger;

  LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug(
      'HTTP Request',
      extras: {
        'method': options.method,
        'url': options.uri.toString(),
        'headers': options.headers,
        'data': options.data,
      },
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.debug(
      'HTTP Response',
      extras: {
        'statusCode': response.statusCode,
        'url': response.requestOptions.uri.toString(),
        'data': response.data,
      },
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.error(
      'HTTP Error',
      error: err,
      extras: {
        'type': err.type.toString(),
        'url': err.requestOptions.uri.toString(),
        'statusCode': err.response?.statusCode,
      },
    );
    handler.next(err);
  }
}