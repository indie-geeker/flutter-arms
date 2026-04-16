import 'dart:async';

import 'package:dio/dio.dart';

/// Token 注入与自动刷新拦截器。
class TokenInterceptor extends Interceptor {
  /// 构造函数。
  TokenInterceptor({
    required Future<String?> Function() accessTokenProvider,
    required Future<String?> Function() refreshTokenProvider,
    required Future<bool> Function(String refreshToken) refreshAction,
    required Dio retryDio,
  })  : _accessTokenProvider = accessTokenProvider,
        _refreshTokenProvider = refreshTokenProvider,
        _refreshAction = refreshAction,
        _retryDio = retryDio;

  final Future<String?> Function() _accessTokenProvider;
  final Future<String?> Function() _refreshTokenProvider;
  final Future<bool> Function(String refreshToken) _refreshAction;
  final Dio _retryDio;

  bool _isRefreshing = false;
  final List<Completer<void>> _waitQueue = <Completer<void>>[];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _accessTokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    if (statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshToken = await _refreshTokenProvider();
    if (refreshToken == null || refreshToken.isEmpty) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      final completer = Completer<void>();
      _waitQueue.add(completer);
      await completer.future;
      await _retryRequest(err, handler);
      return;
    }

    _isRefreshing = true;
    final refreshSuccess = await _refreshAction(refreshToken);
    _isRefreshing = false;

    for (final completer in _waitQueue) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    _waitQueue.clear();

    if (!refreshSuccess) {
      handler.next(err);
      return;
    }

    await _retryRequest(err, handler);
  }

  Future<void> _retryRequest(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    options.extra = <String, dynamic>{...options.extra, 'retried': true};
    final token = await _accessTokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await _retryDio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (error) {
      handler.next(error);
    }
  }
}
