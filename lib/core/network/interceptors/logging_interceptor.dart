import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i(
      'REQUEST[${options.method}] => PATH: ${options.path}\n'
      'Headers: ${options.headers}\n'
      'Query Parameters: ${options.queryParameters}\n'
      'Data: ${options.data}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}\n'
      'Headers: ${response.headers}\n'
      'Data: ${response.data}',
    );
    super.onResponse(response, handler);
  }

  String _formatError(DioException err) {
    final buffer = StringBuffer();
    buffer.writeln('ERROR[${err.response?.statusCode ?? "Unknown"}] => PATH: ${err.requestOptions.path}');
    buffer.writeln('Type: ${err.type}');
    
    // 格式化错误消息
    if (err.message != null) {
      final messages = err.message!.split('\n');
      buffer.writeln('Message:');
      for (final msg in messages) {
        buffer.writeln('  $msg');
      }
    }

    // 添加请求信息
    buffer.writeln('Request Info:');
    buffer.writeln('  Method: ${err.requestOptions.method}');
    buffer.writeln('  Headers: ${err.requestOptions.headers}');
    buffer.writeln('  Data: ${err.requestOptions.data}');

    // 添加响应信息
    if (err.response != null) {
      buffer.writeln('Response Info:');
      buffer.writeln('  Status code: ${err.response?.statusCode}');
      buffer.writeln('  Headers: ${err.response?.headers}');
      buffer.writeln('  Data: ${err.response?.data}');
    }

    return buffer.toString();
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(_formatError(err));
    super.onError(err, handler);
  }
}
