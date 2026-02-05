
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:interfaces/storage/i_secure_storage.dart';
import 'package:interfaces/cache/i_cache_manager.dart';
import 'package:interfaces/network/i_http_client.dart';
import 'service_locator.dart';

/// 日志服务 Provider
final loggerProvider = Provider<ILogger>((ref) {
  return ServiceLocator().get<ILogger>();
});

/// KV 存储服务 Provider
final kvStorageProvider = Provider<IKeyValueStorage>((ref) {
  return ServiceLocator().get<IKeyValueStorage>();
});

// /// 关系型存储服务 Provider
// final relationalStorageProvider = Provider<IRelationalStorage>((ref) {
//   return ServiceLocator().get<IRelationalStorage>();
// });
//
/// 安全存储服务 Provider
final secureStorageProvider = Provider<ISecureStorage>((ref) {
  return ServiceLocator().get<ISecureStorage>();
});

/// 缓存服务 Provider
final cacheManagerProvider = Provider<ICacheManager>((ref) {
  return ServiceLocator().get<ICacheManager>();
});

/// 网络服务 Provider
final httpClientProvider = Provider<IHttpClient>((ref) {
  return ServiceLocator().get<IHttpClient>();
});
