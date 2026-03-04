import 'package:core/core.dart' show ServiceLocator;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:interfaces/cache/i_cache_manager.dart';
import 'package:interfaces/network/i_http_client.dart';

/// 基础设施 Provider 桥接（GetIt → Riverpod）
///
/// 将 GetIt 中注册的基础设施服务桥接到 Riverpod Provider，
/// 使 Feature 层可通过 ref.watch 获取基础设施服务。
final loggerProvider = Provider<ILogger>((ref) {
  return ServiceLocator().get<ILogger>();
});

final kvStorageProvider = Provider<IKeyValueStorage>((ref) {
  return ServiceLocator().get<IKeyValueStorage>();
});

final cacheManagerProvider = Provider<ICacheManager>((ref) {
  return ServiceLocator().get<ICacheManager>();
});

final httpClientProvider = Provider<IHttpClient>((ref) {
  return ServiceLocator().get<IHttpClient>();
});

final fullStackDemoAvailableProvider = Provider<bool>((ref) {
  final locator = ServiceLocator();
  return locator.isRegistered<IHttpClient>() &&
      locator.isRegistered<ICacheManager>();
});
