import 'package:app_interfaces/app_interfaces.dart';
import 'base_interceptor.dart';

/// 日志拦截器
///
/// 负责记录网络请求和响应的详细信息，用于调试和监控
class LogInterceptor extends BaseInterceptor {
  final ILogger? _logger;
  final bool _logRequest;
  final bool _logResponse;
  final bool _logError;
  final bool _logHeaders;
  final bool _logBody;

  LogInterceptor({
    ILogger? logger,
    bool logRequest = true,
    bool logResponse = true,
    bool logError = true,
    bool logHeaders = true,
    bool logBody = true,
  })  : _logger = logger ,
        _logRequest = logRequest,
        _logResponse = logResponse,
        _logError = logError,
        _logHeaders = logHeaders,
        _logBody = logBody;

  @override
  int get priority => 100; // 较低优先级，确保在其他拦截器处理后再记录日志

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    if (_logRequest) {
      _logRequestDetails(options);
    }
    return options;
  }

  @override
  Future<ApiResponse<T>> onResponse<T>(
      ApiResponse<T> response,
    RequestOptions options,
  ) async {
    if (_logResponse) {
      _logResponseDetails(response, options);
    }
    return response;
  }

  @override
  Future<Object> onError(Object error, RequestOptions options) async {
    if (_logError) {
      _logErrorDetails(error, options);
    }
    return error;
  }

  /// 记录请求详情
  void _logRequestDetails(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.writeln('🚀 HTTP Request');
    buffer.writeln('Method: ${options.method}');
    buffer.writeln('URL: ${options.path}');
    
    if (_logHeaders && options.headers.isNotEmpty) {
      buffer.writeln('Headers:');
      options.headers.forEach((key, value) {
        // 隐藏敏感信息
        if (_isSensitiveHeader(key)) {
          buffer.writeln('  $key: ***');
        } else {
          buffer.writeln('  $key: $value');
        }
      });
    }

    if (options.queryParameters?.isNotEmpty == true) {
      buffer.writeln('Query Parameters:');
      options.queryParameters?.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }

    if (_logBody && options.data != null) {
      buffer.writeln('Body: ${_formatBody(options.data)}');
    }

    _logger?.debug(buffer.toString());
  }

  /// 记录响应详情
  void _logResponseDetails<T>(ApiResponse<T> response, RequestOptions options) {
    final buffer = StringBuffer();
    buffer.writeln('✅ HTTP Response');
    buffer.writeln('Method: ${options.method}');
    buffer.writeln('URL: ${options.path}');
    buffer.writeln('Status Code: ${response.code}');
    buffer.writeln('Status Message: ${response.code == 200 ? 'OK' : 'Error'}');

    // if (_logHeaders && response.headers.isNotEmpty) {
    //   buffer.writeln('Headers:');
    //   response.headers.forEach((key, value) {
    //     buffer.writeln('  $key: $value');
    //   });
    // }

    if (_logBody && response.data != null) {
      buffer.writeln('Body: ${_formatBody(response.data)}');
    }

    _logger?.info(buffer.toString());
  }

  /// 记录错误详情
  void _logErrorDetails(Object error, RequestOptions options) {
    final buffer = StringBuffer();
    buffer.writeln('❌ HTTP Error');
    buffer.writeln('Method: ${options.method}');
    buffer.writeln('URL: ${options.path}');
    
    if (error is NetworkException) {
      buffer.writeln('Error Code: ${error.code}');
      buffer.writeln('Status Code: ${error.statusCode ?? 'N/A'}');
      buffer.writeln('Message: ${error.message}');
      if (error.details != null) {
        buffer.writeln('Details: ${error.details}');
      }
    } else {
      buffer.writeln('Error: $error');
    }

    _logger?.error(buffer.toString());
  }

  /// 格式化请求/响应体
  String _formatBody(dynamic body) {
    if (body == null) return 'null';
    
    try {
      // 限制日志长度，避免过长的响应体
      final bodyStr = body.toString();
      if (bodyStr.length > 1000) {
        return '${bodyStr.substring(0, 1000)}... (truncated)';
      }
      return bodyStr;
    } catch (e) {
      return 'Failed to format body: $e';
    }
  }

  /// 检查是否为敏感请求头
  bool _isSensitiveHeader(String key) {
    final lowerKey = key.toLowerCase();
    return lowerKey.contains('authorization') ||
           lowerKey.contains('token') ||
           lowerKey.contains('password') ||
           lowerKey.contains('secret') ||
           lowerKey.contains('key');
  }
}
