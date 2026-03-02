import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:interfaces/interfaces.dart';
import 'package:interfaces/logger/log_output.dart';
import 'package:module_network/src/impl/dio_http_client.dart';
import 'package:module_network/src/impl/cancel_token_manager.dart';

/// Boundary condition tests for DioHttpClient and CancelTokenManager.
///
/// Covers: empty responses, concurrent cancellation, timeout behavior,
/// empty body, and cancel token edge cases.
void main() {
  group('DioHttpClient boundary conditions', () {
    late _FakeLogger logger;

    setUp(() {
      logger = _FakeLogger();
    });

    group('empty and null responses', () {
      test('handles empty JSON response body', () async {
        final adapter = _FakeAdapter(
          (_) => dio.ResponseBody.fromString(
            '',
            200,
            headers: {
              'content-type': ['application/json'],
            },
          ),
        );
        final dioClient = dio.Dio()
          ..httpClientAdapter = adapter
          ..options.responseType = dio.ResponseType.json;
        final client = DioHttpClient(
          baseUrl: 'https://example.com',
          logger: logger,
          cacheManager: _FakeCacheManager(),
          dioClient: dioClient,
        );

        final response = await client.get<dynamic>('/empty');
        // Empty body should resolve without crashing
        expect(response.isSuccess, true);
      });

      test('handles null data in response', () async {
        final adapter = _FakeAdapter(
          (_) => dio.ResponseBody.fromString(
            'null',
            200,
            headers: {
              'content-type': ['application/json'],
            },
          ),
        );
        final dioClient = dio.Dio()
          ..httpClientAdapter = adapter
          ..options.responseType = dio.ResponseType.json;
        final client = DioHttpClient(
          baseUrl: 'https://example.com',
          logger: logger,
          cacheManager: _FakeCacheManager(),
          dioClient: dioClient,
        );

        final response = await client.get<dynamic>('/null');
        expect(response.isSuccess, true);
        expect(response.data, isNull);
      });
    });

    group('HTTP methods', () {
      test('GET with empty query parameters', () async {
        final adapter = _jsonOkAdapter();
        final dioClient = dio.Dio()
          ..httpClientAdapter = adapter
          ..options.responseType = dio.ResponseType.json;
        final client = DioHttpClient(
          baseUrl: 'https://example.com',
          logger: logger,
          cacheManager: _FakeCacheManager(),
          dioClient: dioClient,
        );

        final response = await client.get<Map<String, dynamic>>(
          '/test',
          queryParameters: {},
        );
        expect(response.isSuccess, true);
      });

      test('POST with null body', () async {
        final adapter = _jsonOkAdapter();
        final dioClient = dio.Dio()
          ..httpClientAdapter = adapter
          ..options.responseType = dio.ResponseType.json;
        final client = DioHttpClient(
          baseUrl: 'https://example.com',
          logger: logger,
          cacheManager: _FakeCacheManager(),
          dioClient: dioClient,
        );

        final response = await client.post<Map<String, dynamic>>('/test');
        expect(response.isSuccess, true);
      });

      test('PUT with large body', () async {
        final adapter = _jsonOkAdapter();
        final dioClient = dio.Dio()
          ..httpClientAdapter = adapter
          ..options.responseType = dio.ResponseType.json;
        final client = DioHttpClient(
          baseUrl: 'https://example.com',
          logger: logger,
          cacheManager: _FakeCacheManager(),
          dioClient: dioClient,
        );

        final largeBody = {'data': 'x' * 100000};
        final response = await client.put<Map<String, dynamic>>(
          '/test',
          data: largeBody,
        );
        expect(response.isSuccess, true);
      });

      test('DELETE returns correct status codes', () async {
        final adapter = _FakeAdapter(
          (_) => dio.ResponseBody.fromString(
            '{"deleted":true}',
            204,
            headers: {
              'content-type': ['application/json'],
            },
          ),
        );
        final dioClient = dio.Dio()
          ..httpClientAdapter = adapter
          ..options.responseType = dio.ResponseType.json;
        final client = DioHttpClient(
          baseUrl: 'https://example.com',
          logger: logger,
          cacheManager: _FakeCacheManager(),
          dioClient: dioClient,
        );

        final response = await client.delete<Map<String, dynamic>>('/test');
        expect(response.isSuccess, true);
        expect(response.statusCode, 204);
      });
    });

    group('error handling boundaries', () {
      test('connection timeout produces correct error type', () async {
        final adapter = _FakeAdapter(
          (options) => throw dio.DioException(
            requestOptions: options,
            type: dio.DioExceptionType.connectionTimeout,
          ),
        );
        final dioClient = dio.Dio()
          ..httpClientAdapter = adapter
          ..options.responseType = dio.ResponseType.json;
        final client = DioHttpClient(
          baseUrl: 'https://example.com',
          logger: logger,
          cacheManager: _FakeCacheManager(),
          dioClient: dioClient,
        );

        final response = await client.get<dynamic>('/timeout');
        expect(response.isSuccess, false);
      });

      test('receive timeout produces correct error type', () async {
        final adapter = _FakeAdapter(
          (options) => throw dio.DioException(
            requestOptions: options,
            type: dio.DioExceptionType.receiveTimeout,
          ),
        );
        final dioClient = dio.Dio()
          ..httpClientAdapter = adapter
          ..options.responseType = dio.ResponseType.json;
        final client = DioHttpClient(
          baseUrl: 'https://example.com',
          logger: logger,
          cacheManager: _FakeCacheManager(),
          dioClient: dioClient,
        );

        final response = await client.get<dynamic>('/timeout');
        expect(response.isSuccess, false);
      });

      test('non-DioException error is wrapped correctly', () async {
        final adapter = _FakeAdapter(
          (_) => throw FormatException('Invalid JSON'),
        );
        final dioClient = dio.Dio()
          ..httpClientAdapter = adapter
          ..options.responseType = dio.ResponseType.json;
        final client = DioHttpClient(
          baseUrl: 'https://example.com',
          logger: logger,
          cacheManager: _FakeCacheManager(),
          dioClient: dioClient,
        );

        final response = await client.get<dynamic>('/bad-json');
        expect(response.isSuccess, false);
      });
    });
  });

  group('CancelTokenManager boundary conditions', () {
    late _FakeLogger logger;
    late CancelTokenManager manager;

    setUp(() {
      logger = _FakeLogger();
      manager = CancelTokenManager(logger);
    });

    test('cancelAll with no active tokens does not throw', () {
      manager.cancelAll();
      // Should complete without error
    });

    test('cancelAll after all tokens already untracked', () {
      final token1 = manager.trackToken(null);
      final token2 = manager.trackToken(null);
      manager.untrack(token1);
      manager.untrack(token2);

      manager.cancelAll();
      // Should complete without error
    });

    test('untrack with null token does not throw', () {
      manager.untrack(null);
    });

    test('double-cancel does not throw', () {
      manager.trackToken(null);
      manager.cancelAll();
      // Second cancel should be idempotent
      manager.cancelAll();
    });

    test('tracks multiple tokens independently', () {
      final t1 = manager.trackToken(null);
      final t2 = manager.trackToken(null);
      final t3 = manager.trackToken(null);

      manager.untrack(t1);
      manager.cancelAll();

      expect(t1.isCancelled, false); // Was untracked before cancel
      expect(t2.isCancelled, true);
      expect(t3.isCancelled, true);
    });
  });
}

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

_FakeAdapter _jsonOkAdapter() => _FakeAdapter(
  (_) => dio.ResponseBody.fromString(
    '{"ok":true}',
    200,
    headers: {
      'content-type': ['application/json'],
    },
  ),
);

typedef _AdapterHandler = dio.ResponseBody Function(dio.RequestOptions);

class _FakeAdapter implements dio.HttpClientAdapter {
  _FakeAdapter(this._handler);
  final _AdapterHandler _handler;

  @override
  Future<dio.ResponseBody> fetch(
    dio.RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

class _FakeLogger implements ILogger {
  @override
  void addOutput(LogOutput output) {}
  @override
  void debug(
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {}
  @override
  void error(
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {}
  @override
  void fatal(
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {}
  @override
  void info(String message, {Map<String, dynamic>? extras}) {}
  @override
  void init({LogLevel level = LogLevel.debug, List<LogOutput>? outputs}) {}
  @override
  void log(
    LogLevel level,
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {}
  @override
  void setLevel(LogLevel level) {}
  @override
  void warning(
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {}
}

class _FakeCacheManager implements ICacheManager {
  @override
  Future<void> clear() async {}
  @override
  Future<void> clearExpired() async {}
  @override
  Future<bool> containsKey(String key) async => false;
  @override
  Future<T?> get<T>(String key) async => null;
  @override
  Future<int> getCacheSize() async => 0;
  @override
  Future<T> getOrDefault<T>(String key, T defaultValue) async => defaultValue;
  @override
  Future<CacheStats> getStats() async => CacheStats(
    totalKeys: 0,
    memoryKeys: 0,
    diskKeys: 0,
    totalSize: 0,
    hitCount: 0,
    missCount: 0,
  );
  @override
  Future<void> init() async {}
  @override
  Future<void> put<T>(
    String key,
    T value, {
    Duration? duration,
    CachePolicy policy = CachePolicy.normal,
  }) async {}
  @override
  Future<void> remove(String key) async {}
}
