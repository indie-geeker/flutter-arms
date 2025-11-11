
import 'package:dio/dio.dart';
import 'package:interfaces/interfaces.dart';

/// 网络请求重试拦截器
class RetryInterceptor extends Interceptor {
  final ILogger _logger;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor(
      this._logger, {
        this.maxRetries = 3,
        this.retryDelay = const Duration(seconds: 1),
      });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 检查是否应该重试
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    // 获取当前重试次数
    final retryCount = err.requestOptions.extra['retry_count'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      _logger.warning('Max retries reached for: ${err.requestOptions.uri}');
      return handler.next(err);
    }

    // 等待后重试
    await Future.delayed(retryDelay * (retryCount + 1));

    _logger.info('Retrying request (${retryCount + 1}/$maxRetries): ${err.requestOptions.uri}');

    // 更新重试次数
    err.requestOptions.extra['retry_count'] = retryCount + 1;

    try {
      // 重新发起请求
      final response = await Dio().fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// 判断是否应该重试
  bool _shouldRetry(DioException err) {
    // 只重试网络错误和超时错误
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}