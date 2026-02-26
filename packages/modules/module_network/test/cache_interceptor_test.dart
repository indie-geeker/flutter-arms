import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:interfaces/interfaces.dart';
import 'package:interfaces/logger/log_output.dart';
import 'package:module_network/src/interceptors/cache_interceptor.dart';
import 'package:module_network/src/utils/network_utils.dart';
import 'package:test/test.dart';

void main() {
  group('CacheInterceptor policy behavior', () {
    test('cacheFirst resolves cached response on request hit', () async {
      final cache = _InMemoryCacheManager();
      final logger = _NoopLogger();
      final interceptor = CacheInterceptor(cache, logger);

      final options = RequestOptions(
        path: '/users',
        method: 'GET',
        baseUrl: 'https://api.example.com',
        queryParameters: {'page': 1},
        extra: {
          NetworkCacheOptions.extraKey: const NetworkCacheOptions(
            enabled: true,
            policy: CachePolicy.cacheFirst,
          ),
        },
      );

      final cacheKey = NetworkUtils.generateCacheKey(
        options.uri.toString(),
        options.queryParameters,
      );
      await cache.put(cacheKey, jsonEncode({'source': 'cache'}));

      final handler = _CapturingRequestHandler();
      interceptor.onRequest(options, handler);
      await Future<void>.delayed(Duration.zero);

      expect(handler.resolved, isNotNull);
      expect(handler.nextCalled, isFalse);
      expect(handler.resolved?.extra['from_cache'], isTrue);
      expect(handler.resolved?.data, {'source': 'cache'});
    });

    test('networkFirst bypasses cache hit and continues request', () async {
      final cache = _InMemoryCacheManager();
      final logger = _NoopLogger();
      final interceptor = CacheInterceptor(cache, logger);

      final options = RequestOptions(
        path: '/users',
        method: 'GET',
        baseUrl: 'https://api.example.com',
        queryParameters: {'page': 1},
        extra: {
          NetworkCacheOptions.extraKey: const NetworkCacheOptions(
            enabled: true,
            policy: CachePolicy.networkFirst,
          ),
        },
      );

      final cacheKey = NetworkUtils.generateCacheKey(
        options.uri.toString(),
        options.queryParameters,
      );
      await cache.put(cacheKey, jsonEncode({'source': 'cache'}));

      final handler = _CapturingRequestHandler();
      interceptor.onRequest(options, handler);
      await Future<void>.delayed(Duration.zero);

      expect(handler.nextCalled, isTrue);
      expect(handler.resolved, isNull);
    });

    test('networkFirst falls back to cache on request error', () async {
      final cache = _InMemoryCacheManager();
      final logger = _NoopLogger();
      final interceptor = CacheInterceptor(cache, logger);

      final options = RequestOptions(
        path: '/users',
        method: 'GET',
        baseUrl: 'https://api.example.com',
        queryParameters: {'page': 1},
        extra: {
          NetworkCacheOptions.extraKey: const NetworkCacheOptions(
            enabled: true,
            policy: CachePolicy.networkFirst,
          ),
        },
      );

      final cacheKey = NetworkUtils.generateCacheKey(
        options.uri.toString(),
        options.queryParameters,
      );
      await cache.put(cacheKey, jsonEncode({'source': 'cache-fallback'}));

      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'offline',
      );

      final handler = _CapturingErrorHandler();
      interceptor.onError(error, handler);
      await Future<void>.delayed(Duration.zero);

      expect(handler.resolved, isNotNull);
      expect(handler.nextError, isNull);
      expect(handler.resolved?.extra['from_cache'], isTrue);
      expect(handler.resolved?.data, {'source': 'cache-fallback'});
    });
  });
}

class _InMemoryCacheManager implements ICacheManager {
  final Map<String, Object?> _store = {};

  @override
  Future<void> clear() async => _store.clear();

  @override
  Future<void> clearExpired() async {}

  @override
  Future<bool> containsKey(String key) async => _store.containsKey(key);

  @override
  Future<T?> get<T>(String key) async => _store[key] as T?;

  @override
  Future<int> getCacheSize() async => _store.length;

  @override
  Future<T> getOrDefault<T>(String key, T defaultValue) async {
    return (_store[key] as T?) ?? defaultValue;
  }

  @override
  Future<CacheStats> getStats() async => CacheStats(
    totalKeys: _store.length,
    memoryKeys: _store.length,
    diskKeys: 0,
    totalSize: _store.length,
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
  }) async {
    _store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }
}

class _NoopLogger implements ILogger {
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

class _CapturingRequestHandler extends RequestInterceptorHandler {
  bool nextCalled = false;
  Response? resolved;

  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
  }

  @override
  void reject(
    DioException error, [
    bool callFollowingErrorInterceptor = false,
  ]) {}

  @override
  void resolve(
    Response response, [
    bool callFollowingResponseInterceptor = false,
  ]) {
    resolved = response;
  }
}

class _CapturingErrorHandler extends ErrorInterceptorHandler {
  Response? resolved;
  DioException? nextError;

  @override
  void next(DioException err) {
    nextError = err;
  }

  @override
  void reject(DioException err) {
    nextError = err;
  }

  @override
  void resolve(Response response) {
    resolved = response;
  }
}
