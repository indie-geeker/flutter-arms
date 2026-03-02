import 'package:dio/dio.dart' as dio;

/// Extra key used to pass per-request connect timeout via [dio.Options.extra].
const connectTimeoutExtraKey = 'connect_timeout';

/// Applies per-request connect timeout stored in [dio.RequestOptions.extra].
class RequestTimeoutInterceptor extends dio.Interceptor {
  @override
  void onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) {
    final extra = options.extra;
    final connectTimeout = extra[connectTimeoutExtraKey];
    if (connectTimeout is Duration) {
      options.connectTimeout = connectTimeout;
    }
    handler.next(options);
  }
}
