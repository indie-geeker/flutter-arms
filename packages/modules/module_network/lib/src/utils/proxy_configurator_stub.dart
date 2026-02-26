import 'package:dio/dio.dart' as dio;
import 'package:interfaces/interfaces.dart';

import '../config/network_config.dart';
import 'proxy_utils.dart';

void configureProxy(
  dio.Dio dioClient,
  ProxyConfig? proxyConfig,
  ILogger logger,
) {
  if (proxyConfig == null) return;

  logger.warning(
    'Proxy config is not supported on this platform',
    extras: buildProxyExtras(proxyConfig),
  );
}
