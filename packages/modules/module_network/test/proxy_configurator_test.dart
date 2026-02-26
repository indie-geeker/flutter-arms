import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:interfaces/interfaces.dart';
import 'package:interfaces/logger/log_output.dart';
import 'package:module_network/src/config/network_config.dart';
import 'package:module_network/src/utils/proxy_configurator.dart';
import 'package:module_network/src/utils/proxy_utils.dart';
import 'package:test/test.dart';

void main() {
  group('configureProxy', () {
    test('configures existing IOHttpClientAdapter and logs proxy metadata', () {
      final client = dio.Dio();
      final logger = _CapturingLogger();
      final config = ProxyConfig(host: '127.0.0.1', port: 8888);
      final before = client.httpClientAdapter;

      configureProxy(client, config, logger);

      expect(client.httpClientAdapter, isA<IOHttpClientAdapter>());
      expect(identical(before, client.httpClientAdapter), isTrue);
      expect(logger.infoMessages, contains('HTTP proxy enabled'));
      expect(logger.lastExtras, {
        'host': '127.0.0.1',
        'port': 8888,
        'hasCredentials': false,
      });
    });

    test('preserves existing createHttpClient callback on IO adapter', () {
      final client = dio.Dio();
      final logger = _CapturingLogger();
      final config = ProxyConfig(host: '127.0.0.1', port: 8888);
      final ioAdapter = IOHttpClientAdapter();
      var createCalls = 0;

      ioAdapter.createHttpClient = () {
        createCalls += 1;
        return HttpClient();
      };
      client.httpClientAdapter = ioAdapter;

      configureProxy(client, config, logger);

      final configured = client.httpClientAdapter as IOHttpClientAdapter;
      configured.createHttpClient!.call();
      expect(createCalls, 1);
      expect(logger.warningMessages, isEmpty);
    });

    test('keeps adapter unchanged when proxy config is null', () {
      final client = dio.Dio();
      final logger = _CapturingLogger();
      final before = client.httpClientAdapter;

      configureProxy(client, null, logger);

      expect(identical(before, client.httpClientAdapter), isTrue);
      expect(logger.infoMessages, isEmpty);
      expect(logger.warningMessages, isEmpty);
    });

    test('does not replace non-IO adapter and logs warning', () {
      final client = dio.Dio();
      final logger = _CapturingLogger();
      final config = ProxyConfig(host: '127.0.0.1', port: 8888);
      final customAdapter = _NonIoAdapter();
      client.httpClientAdapter = customAdapter;

      configureProxy(client, config, logger);

      expect(identical(client.httpClientAdapter, customAdapter), isTrue);
      expect(
        logger.warningMessages,
        contains(
          'Proxy config skipped: current adapter does not support IO proxy setup',
        ),
      );
      expect(logger.lastExtras?['adapterType'], '_NonIoAdapter');
    });
  });

  group('proxy utils', () {
    test('buildProxyDirective returns PROXY host:port format', () {
      final config = ProxyConfig(host: '10.0.0.1', port: 7890);
      expect(buildProxyDirective(config), 'PROXY 10.0.0.1:7890');
    });
  });
}

class _CapturingLogger implements ILogger {
  final List<String> infoMessages = [];
  final List<String> warningMessages = [];
  Map<String, dynamic>? lastExtras;

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
  void info(String message, {Map<String, dynamic>? extras}) {
    infoMessages.add(message);
    lastExtras = extras;
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
  }) {}

  @override
  void setLevel(LogLevel level) {}

  @override
  void warning(
    String message, {
    error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    warningMessages.add(message);
    lastExtras = extras;
  }
}

class _NonIoAdapter implements dio.HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<dio.ResponseBody> fetch(
    dio.RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw UnimplementedError();
  }
}
