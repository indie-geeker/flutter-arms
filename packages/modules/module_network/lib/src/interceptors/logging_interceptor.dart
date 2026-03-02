import 'package:dio/dio.dart';
import 'package:interfaces/interfaces.dart';

/// 网络请求日志拦截器
class LoggingInterceptor extends Interceptor {
  final ILogger _logger;
  static const String _redacted = '***';
  static const Set<String> _sensitiveHeaderKeys = {
    'authorization',
    'proxy-authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'api-key',
  };
  static const Set<String> _sensitiveKeyHints = {
    'password',
    'token',
    'secret',
    'credential',
    'authorization',
    'api_key',
    'apikey',
    'cookie',
  };

  LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug(
      'HTTP Request',
      extras: {
        'method': options.method,
        'url': options.uri.toString(),
        'headers': _sanitizeHeaders(options.headers),
        'data': _sanitizeData(options.data),
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
        'data': _sanitizeData(response.data),
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

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final result = <String, dynamic>{};
    headers.forEach((key, value) {
      if (_sensitiveHeaderKeys.contains(key.toLowerCase())) {
        result[key] = _redacted;
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      final sanitized = <String, dynamic>{};
      data.forEach((key, value) {
        final keyString = key.toString();
        if (_isSensitiveKey(keyString)) {
          sanitized[keyString] = _redacted;
        } else {
          sanitized[keyString] = _sanitizeData(value);
        }
      });
      return sanitized;
    }
    if (data is List) {
      return data.map(_sanitizeData).toList();
    }
    return data;
  }

  bool _isSensitiveKey(String key) {
    final lowerKey = key.toLowerCase();
    return _sensitiveKeyHints.any(lowerKey.contains);
  }
}
