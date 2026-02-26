import 'package:dio/dio.dart';
import 'package:interfaces/interfaces.dart';
import 'package:interfaces/logger/log_output.dart';
import 'package:module_network/src/config/network_config.dart';
import 'package:module_network/src/interceptors/logging_interceptor.dart';
import 'package:module_network/src/network_module.dart';
import 'package:test/test.dart';

void main() {
  group('NetworkModule', () {
    test('should derive dependencies from config when cache is disabled', () {
      final config = NetworkConfig(
        baseUrl: 'https://example.com',
        enableCache: false,
      );

      final module = NetworkModule.fromConfig(config);

      expect(module.dependencies, [ILogger]);
      expect(module.provides, [IHttpClient]);
    });

    test('should include cache dependency when cache is enabled in config', () {
      final config = NetworkConfig(
        baseUrl: 'https://example.com',
        enableCache: true,
      );

      final module = NetworkModule.fromConfig(config);

      expect(module.dependencies, [ILogger, ICacheManager]);
    });

    test('should carry advanced config values from NetworkConfig', () {
      final proxyConfig = ProxyConfig(
        host: '127.0.0.1',
        port: 8888,
        username: 'user',
        password: 'pass',
      );
      final config = NetworkConfig(
        baseUrl: 'https://example.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 30),
        defaultHeaders: const {'X-App': 'flutter-arms', 'X-Env': 'test'},
        defaultCacheDuration: const Duration(minutes: 8),
        proxyConfig: proxyConfig,
      );

      final module = NetworkModule.fromConfig(config);

      expect(module.sendTimeout, const Duration(seconds: 30));
      expect(module.defaultHeaders, {'X-App': 'flutter-arms', 'X-Env': 'test'});
      expect(module.defaultCacheDuration, const Duration(minutes: 8));
      expect(module.proxyConfig, same(proxyConfig));
    });
  });

  group('LoggingInterceptor', () {
    test('should redact sensitive request headers and payload fields', () {
      final logger = _CapturingLogger();
      final interceptor = LoggingInterceptor(logger);

      final request = RequestOptions(
        path: '/login',
        method: 'POST',
        baseUrl: 'https://api.example.com',
        headers: {
          'Authorization': 'Bearer secret-token',
          'X-Request-Id': 'req-1',
        },
        data: {
          'username': 'alice',
          'password': '123456',
          'nested': {'refresh_token': 'refresh-secret', 'note': 'safe'},
        },
      );

      interceptor.onRequest(request, _NoopRequestHandler());

      final log = logger.find('HTTP Request');
      final headers = log.extras!['headers'] as Map<String, dynamic>;
      final data = log.extras!['data'] as Map<String, dynamic>;

      expect(headers['Authorization'], '***');
      expect(headers['X-Request-Id'], 'req-1');
      expect(data['username'], 'alice');
      expect(data['password'], '***');
      expect((data['nested'] as Map<String, dynamic>)['refresh_token'], '***');
      expect((data['nested'] as Map<String, dynamic>)['note'], 'safe');
    });

    test('should redact sensitive response fields', () {
      final logger = _CapturingLogger();
      final interceptor = LoggingInterceptor(logger);

      final request = RequestOptions(
        path: '/profile',
        method: 'GET',
        baseUrl: 'https://api.example.com',
      );
      final response = Response<Map<String, dynamic>>(
        requestOptions: request,
        statusCode: 200,
        data: {
          'name': 'Alice',
          'access_token': 'access-secret',
          'meta': {'api_key': 'api-secret', 'region': 'us'},
        },
      );

      interceptor.onResponse(response, _NoopResponseHandler());

      final log = logger.find('HTTP Response');
      final data = log.extras!['data'] as Map<String, dynamic>;

      expect(data['name'], 'Alice');
      expect(data['access_token'], '***');
      expect((data['meta'] as Map<String, dynamic>)['api_key'], '***');
      expect((data['meta'] as Map<String, dynamic>)['region'], 'us');
    });
  });
}

class _LogRecord {
  _LogRecord({required this.message, this.extras});

  final String message;
  final Map<String, dynamic>? extras;
}

class _CapturingLogger implements ILogger {
  final List<_LogRecord> records = [];

  _LogRecord find(String message) {
    return records.lastWhere((record) => record.message == message);
  }

  @override
  void addOutput(LogOutput output) {}

  @override
  void debug(
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    records.add(_LogRecord(message: message, extras: extras));
  }

  @override
  void error(
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    records.add(_LogRecord(message: message, extras: extras));
  }

  @override
  void fatal(
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    records.add(_LogRecord(message: message, extras: extras));
  }

  @override
  void info(String message, {Map<String, dynamic>? extras}) {
    records.add(_LogRecord(message: message, extras: extras));
  }

  @override
  void init({LogLevel level = LogLevel.debug, List<LogOutput>? outputs}) {}

  @override
  void log(
    LogLevel level,
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    records.add(_LogRecord(message: message, extras: extras));
  }

  @override
  void setLevel(LogLevel level) {}

  @override
  void warning(
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    records.add(_LogRecord(message: message, extras: extras));
  }
}

class _NoopRequestHandler extends RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}

  @override
  void reject(
    DioException error, [
    bool callFollowingErrorInterceptor = false,
  ]) {}

  @override
  void resolve(
    Response response, [
    bool callFollowingResponseInterceptor = false,
  ]) {}
}

class _NoopResponseHandler extends ResponseInterceptorHandler {
  @override
  void next(Response response) {}

  @override
  void reject(
    DioException error, [
    bool callFollowingErrorInterceptor = false,
  ]) {}

  @override
  void resolve(Response response) {}
}
