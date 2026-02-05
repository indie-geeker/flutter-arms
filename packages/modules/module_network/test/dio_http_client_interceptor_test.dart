import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:test/test.dart';
import 'package:interfaces/interfaces.dart';
import 'package:interfaces/logger/log_output.dart';
import 'package:module_network/src/impl/dio_http_client.dart';

class _FakeLogger implements ILogger {
  @override
  void addOutput(LogOutput output) {}

  @override
  void debug(String message, {error, StackTrace? stackTrace, Map<String, dynamic>? extras}) {}

  @override
  void error(String message, {error, StackTrace? stackTrace, Map<String, dynamic>? extras}) {}

  @override
  void fatal(String message, {error, StackTrace? stackTrace, Map<String, dynamic>? extras}) {}

  @override
  void info(String message, {Map<String, dynamic>? extras}) {}

  @override
  void init({LogLevel level = LogLevel.debug, List<LogOutput>? outputs}) {}

  @override
  void log(LogLevel level, String message, {error, StackTrace? stackTrace, Map<String, dynamic>? extras}) {}

  @override
  void setLevel(LogLevel level) {}

  @override
  void warning(String message, {error, StackTrace? stackTrace, Map<String, dynamic>? extras}) {}
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

typedef _AdapterHandler = dio.ResponseBody Function(dio.RequestOptions options);

class _FakeAdapter implements dio.HttpClientAdapter {
  _FakeAdapter(this._handler);

  dio.RequestOptions? lastOptions;
  final _AdapterHandler _handler;

  @override
  Future<dio.ResponseBody> fetch(
    dio.RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

class _HeaderInterceptor implements INetworkInterceptor {
  @override
  Future<NetworkRequest?> onRequest(NetworkRequest request) async {
    final headers = Map<String, dynamic>.from(request.headers ?? {});
    headers['X-Test'] = '1';
    return NetworkRequest(
      path: request.path,
      method: request.method,
      queryParameters: request.queryParameters,
      headers: headers,
      data: request.data,
      connectTimeout: request.connectTimeout,
      receiveTimeout: request.receiveTimeout,
      extra: request.extra,
      cacheOptions: request.cacheOptions,
    );
  }

  @override
  Future<NetworkResponse<T>> onResponse<T>(NetworkResponse<T> response) async {
    return response;
  }

  @override
  Future<NetworkResponse<T>> onError<T>(NetworkException error) async {
    return NetworkResponse.failure(error);
  }
}

class _ResponseInterceptor implements INetworkInterceptor {
  @override
  Future<NetworkRequest?> onRequest(NetworkRequest request) async => request;

  @override
  Future<NetworkResponse<T>> onResponse<T>(NetworkResponse<T> response) async {
    if (response.data is Map) {
      final data = Map<String, dynamic>.from(response.data as Map)
        ..['intercepted'] = true;
      return NetworkResponse.success(
        data as T,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        headers: response.headers,
      );
    }
    return response;
  }

  @override
  Future<NetworkResponse<T>> onError<T>(NetworkException error) async {
    return NetworkResponse.failure(error);
  }
}

class _RecoveryInterceptor implements INetworkInterceptor {
  @override
  Future<NetworkRequest?> onRequest(NetworkRequest request) async => request;

  @override
  Future<NetworkResponse<T>> onResponse<T>(NetworkResponse<T> response) async => response;

  @override
  Future<NetworkResponse<T>> onError<T>(NetworkException error) async {
    return NetworkResponse.success(
      'recovered' as T,
      statusCode: 200,
      statusMessage: 'Recovered',
    );
  }
}

void main() {
  group('DioHttpClient interceptors', () {
    test('applies onRequest modifications', () async {
      final adapter = _FakeAdapter(
        (_) => dio.ResponseBody.fromString(
          '{"ok":true}',
          200,
          headers: {'content-type': ['application/json']},
        ),
      );
      final dioClient = dio.Dio()
        ..httpClientAdapter = adapter
        ..options.responseType = dio.ResponseType.json;
      final client = DioHttpClient(
        baseUrl: 'https://example.com',
        logger: _FakeLogger(),
        cacheManager: _FakeCacheManager(),
        dioClient: dioClient,
      );

      client.addInterceptor(_HeaderInterceptor());

      final response = await client.get<Map<String, dynamic>>('/test', headers: {'A': 'B'});

      expect(response.isSuccess, true);
      expect(adapter.lastOptions?.headers['X-Test'], '1');
    });

    test('applies onResponse modifications', () async {
      final adapter = _FakeAdapter(
        (_) => dio.ResponseBody.fromString(
          '{"ok":true}',
          200,
          headers: {'content-type': ['application/json']},
        ),
      );
      final dioClient = dio.Dio()
        ..httpClientAdapter = adapter
        ..options.responseType = dio.ResponseType.json;
      final client = DioHttpClient(
        baseUrl: 'https://example.com',
        logger: _FakeLogger(),
        cacheManager: _FakeCacheManager(),
        dioClient: dioClient,
      );

      client.addInterceptor(_ResponseInterceptor());

      final response = await client.get<Map<String, dynamic>>('/test');

      expect(response.isSuccess, true);
      expect(response.data?['intercepted'], true);
    });

    test('allows onError recovery', () async {
      final adapter = _FakeAdapter(
        (options) => throw dio.DioException(
          requestOptions: options,
          type: dio.DioExceptionType.connectionError,
          error: 'network',
        ),
      );
      final dioClient = dio.Dio()
        ..httpClientAdapter = adapter
        ..options.responseType = dio.ResponseType.json;
      final client = DioHttpClient(
        baseUrl: 'https://example.com',
        logger: _FakeLogger(),
        cacheManager: _FakeCacheManager(),
        dioClient: dioClient,
      );

      client.addInterceptor(_RecoveryInterceptor());

      final response = await client.get<String>('/test');

      expect(response.isSuccess, true);
      expect(response.data, 'recovered');
    });
  });
}
