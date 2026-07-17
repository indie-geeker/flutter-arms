import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

/// 模拟 API 拦截器。
///
/// 当 `AppEnv.useMockApi == true` 时插入到 Dio 拦截链 **首位**，短路 `/auth/*`
/// 与 `/feedback/*` 请求并返回预置响应。让派生项目在未接入真实后端前，
/// 也能完整跑通登录 / 退出 / 刷新和反馈中心流程。
///
/// 设计要点：
/// - 仅在 **dev flavor** 中启用（由 `AppEnv.fromFlavor` 保证）。
/// - 失败路径用 `handler.reject(dio_ex, true)` 让后续 `onError` 继续执行，
///   从而 `ApiInterceptor` + `AppExceptionMapper` + `.asApi()` 的整条生产错误
///   链路照常跑完（只是 transport 被短路）。
/// - 成功路径用 `handler.resolve(resp, true)` 让 `TalkerDioLogger` 等 onResponse
///   拦截器照常打印，便于调试。
/// - 每个拦截器实例维护独立的反馈工单内存库；新建 Dio 即从预置数据重新开始。
/// - 预置凭据：`username=admin`、`password=admin`。其它任意组合返回 401。
///
/// 接入真实后端：把 `env/dev.json` 里 `USE_MOCK_API` 明确置为 `"false"`
/// （删除该键会回落为默认值 `true`），并按 [TEMPLATE_GUIDE §1.4] 指引删除本文件及
/// `dio_client.dart` 对应几行即可。
class MockApiInterceptor extends Interceptor {
  /// 构造函数。
  ///
  /// [latency] 模拟网络往返延迟，便于 UI 展示 loading 态。
  MockApiInterceptor({
    this.latency = const Duration(milliseconds: 300),
  }) : _feedbackTickets = _initialFeedbackTickets
           .map(Map<String, dynamic>.from)
           .toList(growable: true);

  /// 模拟网络延迟。
  final Duration latency;

  final List<Map<String, dynamic>> _feedbackTickets;
  int _nextFeedbackId = 1003;

  static const _mockAccessToken = 'mock.access.token';
  static const _mockRefreshToken = 'mock.refresh.token';
  static const _feedbackCategories = <String>{'bug', 'suggestion', 'other'};

  static const _mockFaqs = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'faq-submit',
      'question': 'How do I submit feedback?',
      'answer': 'Open Help & Feedback and choose Send feedback.',
      'tags': <String>['feedback', 'submit', 'help'],
    },
    <String, dynamic>{
      'id': 'faq-history',
      'question': 'Where can I see earlier feedback?',
      'answer': 'Open your profile and select Help & Feedback.',
      'tags': <String>['history', 'status', 'ticket'],
    },
    <String, dynamic>{
      'id': 'faq-data',
      'question': 'What information is sent?',
      'answer':
          'The feedback request body contains only the selected category '
          'and your message.',
      'tags': <String>['privacy', 'data'],
    },
  ];

  static const _initialFeedbackTickets = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'feedback-1002',
      'category': 'suggestion',
      'message': 'Please add a compact list layout.',
      'status': 'reviewing',
      'createdAt': '2026-07-15T15:30:00.000Z',
      'reply': null,
    },
    <String, dynamic>{
      'id': 'feedback-1001',
      'category': 'bug',
      'message': 'The save button stopped responding once.',
      'status': 'resolved',
      'createdAt': '2026-07-14T09:00:00.000Z',
      'reply': 'Thanks for the report. This has been fixed.',
    },
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.method == 'GET' && options.path == '/feedback/faqs') {
      await _handleFaqs(options, handler);
      return;
    }

    if (options.path == '/feedback') {
      if (options.method == 'GET') {
        await _handleFeedbackList(options, handler);
        return;
      }
      if (options.method == 'POST') {
        await _handleFeedbackSubmit(options, handler);
        return;
      }
    }

    if (options.method == 'GET' && options.path.startsWith('/feedback/')) {
      await _handleFeedbackDetail(options, handler);
      return;
    }

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

  Future<void> _handleFaqs(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future<void>.delayed(latency);
    final query =
        (options.queryParameters['q'] as String? ?? '').trim().toLowerCase();
    final matches = _mockFaqs
        .where((faq) {
          if (query.isEmpty) return true;
          final tags = faq['tags']! as List<String>;
          return (faq['question']! as String).toLowerCase().contains(query) ||
              (faq['answer']! as String).toLowerCase().contains(query) ||
              tags.any((tag) => tag.toLowerCase().contains(query));
        })
        .map((faq) {
          return <String, dynamic>{
            'id': faq['id'],
            'question': faq['question'],
            'answer': faq['answer'],
          };
        })
        .toList(growable: false);

    _successList(handler, options, 200, matches);
  }

  Future<void> _handleFeedbackList(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future<void>.delayed(latency);
    _successList(handler, options, 200, _feedbackTickets);
  }

  Future<void> _handleFeedbackDetail(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future<void>.delayed(latency);
    final id = options.path.substring('/feedback/'.length);
    Map<String, dynamic>? ticket;
    for (final candidate in _feedbackTickets) {
      if (candidate['id'] == id) {
        ticket = candidate;
        break;
      }
    }

    if (ticket == null) {
      _fail(
        handler,
        options,
        404,
        <String, dynamic>{'message': 'Feedback ticket not found'},
      );
      return;
    }

    _success(handler, options, 200, ticket);
  }

  Future<void> _handleFeedbackSubmit(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future<void>.delayed(latency);
    final body = _bodyAsMap(options.data);
    if (body == null) {
      _failInvalidJsonBody(handler, options);
      return;
    }
    final category = body['category'];
    final rawMessage = body['message'];
    final message = rawMessage is String ? rawMessage.trim() : '';

    if (message.isEmpty) {
      _fail(
        handler,
        options,
        400,
        <String, dynamic>{'message': 'Feedback message is required'},
      );
      return;
    }

    if (category is! String || !_feedbackCategories.contains(category)) {
      _fail(
        handler,
        options,
        400,
        <String, dynamic>{'message': 'Invalid feedback category'},
      );
      return;
    }

    final ticket = <String, dynamic>{
      'id': 'feedback-${_nextFeedbackId++}',
      'category': category,
      'message': message,
      'status': 'submitted',
      'createdAt': '2026-07-16T12:00:00.000Z',
      'reply': null,
    };
    _feedbackTickets.insert(0, ticket);
    _success(handler, options, 201, ticket);
  }

  Future<void> _handleLogin(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future<void>.delayed(latency);
    final body = _bodyAsMap(options.data);
    if (body == null) {
      _failInvalidJsonBody(handler, options);
      return;
    }
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
    if (body == null) {
      _failInvalidJsonBody(handler, options);
      return;
    }
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

  void _successList(
    RequestInterceptorHandler handler,
    RequestOptions options,
    int statusCode,
    List<Map<String, dynamic>> data,
  ) {
    handler.resolve(
      Response<List<Map<String, dynamic>>>(
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

  void _failInvalidJsonBody(
    RequestInterceptorHandler handler,
    RequestOptions options,
  ) {
    _fail(
      handler,
      options,
      400,
      const <String, dynamic>{'message': 'Invalid JSON request body'},
    );
  }

  Map<String, dynamic>? _bodyAsMap(Object? data) {
    if (data == null) return const <String, dynamic>{};

    try {
      final encoded = jsonEncode(data);
      if (data is Map<String, dynamic>) return data;
      final decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic>) return decoded;
      // JSON encoder 用 Error 类型报告不可编码的请求体；这里只转换这一种已知边界错误。
      // ignore: avoid_catching_errors
    } on JsonUnsupportedObjectError {
      return null;
    }

    return null;
  }
}
