import '../config/network_config.dart';

String buildProxyDirective(ProxyConfig config) {
  return 'PROXY ${config.host}:${config.port}';
}

Map<String, dynamic> buildProxyExtras(ProxyConfig config) {
  return {
    'host': config.host,
    'port': config.port,
    'hasCredentials': config.username != null && config.password != null,
  };
}
