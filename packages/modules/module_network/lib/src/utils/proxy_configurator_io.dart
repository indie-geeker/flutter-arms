import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart' as dio_io;
import 'package:interfaces/interfaces.dart';

import '../config/network_config.dart';
import 'proxy_utils.dart';

void configureProxy(
  dio.Dio dioClient,
  ProxyConfig? proxyConfig,
  ILogger logger,
) {
  if (proxyConfig == null) return;

  final adapter = dioClient.httpClientAdapter;
  if (adapter is! dio_io.IOHttpClientAdapter) {
    logger.warning(
      'Proxy config skipped: current adapter does not support IO proxy setup',
      extras: {
        ...buildProxyExtras(proxyConfig),
        'adapterType': adapter.runtimeType.toString(),
      },
    );
    return;
  }

  final host = proxyConfig.host;
  final port = proxyConfig.port;
  final username = proxyConfig.username;
  final password = proxyConfig.password;
  final proxyDirective = buildProxyDirective(proxyConfig);

  final existingCreateHttpClient = adapter.createHttpClient;
  // ignore: deprecated_member_use_from_same_package, deprecated_member_use
  final existingOnHttpClientCreate = adapter.onHttpClientCreate;

  adapter.createHttpClient = () {
    final baseClient =
        existingCreateHttpClient?.call() ??
        HttpClient()..idleTimeout = const Duration(seconds: 3);

    // Keep backward compatibility for users still configuring deprecated callback.
    // ignore: deprecated_member_use_from_same_package, deprecated_member_use
    final client = existingOnHttpClientCreate?.call(baseClient) ?? baseClient;

    client.findProxy = (_) => proxyDirective;
    if (username != null && password != null) {
      client.addProxyCredentials(
        host,
        port,
        '',
        HttpClientBasicCredentials(username, password),
      );
    }
    return client;
  };

  logger.info('HTTP proxy enabled', extras: buildProxyExtras(proxyConfig));
}
