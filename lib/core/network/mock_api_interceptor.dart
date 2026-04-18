import 'dart:async';

import 'package:dio/dio.dart';

/// 模拟 API 拦截器。
///
/// 当 `AppEnv.useMockApi == true` 时插入到 Dio 拦截链 **首位**，短路 `/auth/*`
/// 请求并返回预置响应。让派生项目在未接入真实后端前，也能完整跑通
/// 登录 / 退出 / 刷新流程。
///
/// 设计要点：
/// - 仅在 **dev flavor** 中启用（由 `AppEnv.fromFlavor` 保证）。
/// - 失败路径用 `handler.reject(dio_ex, true)` 让后续 `onError` 继续执行，
///   从而 `ApiInterceptor` + `AppExceptionMapper` + `.asApi()` 的整条生产错误
///   链路照常跑完（只是 transport 被短路）。
/// - 成功路径用 `handler.resolve(resp, true)` 让 `TalkerDioLogger` 等 onResponse
///   拦截器照常打印，便于调试。
/// - 预置凭据：`username=admin`、`password=admin`。其它任意组合返回 401。
///
/// 接入真实后端：把 `env/dev.json` 里 `USE_MOCK_API` 置为 `"false"`（或整键删除），
/// 并按 [TEMPLATE_GUIDE §1.4] 指引删除本文件及 `dio_client.dart` 对应几行即可。
class MockApiInterceptor extends Interceptor {
  /// 构造函数。
  ///
  /// [latency] 模拟网络往返延迟，便于 UI 展示 loading 态。
  const MockApiInterceptor({
    this.latency = const Duration(milliseconds: 300),
  });

  /// 模拟网络延迟。
  final Duration latency;

  static const _mockAccessToken = 'mock.access.token';
  static const _mockRefreshToken = 'mock.refresh.token';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    switch (options.path) {
      case '/auth/login':
        await _handleLogin(options, handler);
      case '/auth/refresh':
        await _handleRefresh(options, handler);
      case '/auth/me':
        await _handleMe(options, handler);
      case '/auth/logout':
        await _handleLogout(options, handler);
      default:
        handler.next(options);
    }
  }

  Future<void> _handleLogin(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future<void>.delayed(latency);
    final body = _bodyAsMap(options.data);
    final username = body['username'] as String?;
    final password = body['password'] as String?;

    if (username == 'admin' && password == 'admin') {
      _success(
        handler,
        options,
        200,
        <String, dynamic>{
          'accessToken': _mockAccessToken,
          'refreshToken': _mockRefreshToken,
        },
      );
      return;
    }

    _fail(
      handler,
      options,
      401,
      <String, dynamic>{'message': 'Invalid username or password'},
    );
  }

  Future<void> _handleRefresh(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future<void>.delayed(latency);
    final body = _bodyAsMap(options.data);
    final refreshToken = body['refreshToken'] as String?;

    if (refreshToken == null || refreshToken.isEmpty) {
      _fail(
        handler,
        options,
        401,
        <String, dynamic>{'message': 'Missing refresh token'},
      );
      return;
    }

    _success(
      handler,
      options,
      200,
      <String, dynamic>{
        'accessToken': _mockAccessToken,
        'refreshToken': _mockRefreshToken,
      },
    );
  }

  Future<void> _handleMe(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future<void>.delayed(latency);
    _success(
      handler,
      options,
      200,
      <String, dynamic>{
        'id': 'mock-user-1',
        'name': 'Admin',
        'email': 'admin@example.com',
      },
    );
  }

  Future<void> _handleLogout(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future<void>.delayed(latency);
    handler.resolve(
      Response<void>(requestOptions: options, statusCode: 204),
      true,
    );
  }

  void _success(
    RequestInterceptorHandler handler,
    RequestOptions options,
    int statusCode,
    Map<String, dynamic> data,
  ) {
    handler.resolve(
      Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: statusCode,
        data: data,
      ),
      true,
    );
  }

  void _fail(
    RequestInterceptorHandler handler,
    RequestOptions options,
    int statusCode,
    Map<String, dynamic> data,
  ) {
    handler.reject(
      DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: statusCode,
          data: data,
        ),
      ),
      true,
    );
  }

  Map<String, dynamic> _bodyAsMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    return const <String, dynamic>{};
  }
}
