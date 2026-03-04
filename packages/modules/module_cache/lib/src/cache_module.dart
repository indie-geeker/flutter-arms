import 'package:interfaces/cache/i_cache_manager.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/storage/i_kv_storage.dart';

import 'impl/multi_level_cache.dart';
import 'models/cache_entry.dart';

/// Cache module
class CacheModule extends BaseModule {
  final int maxMemoryItems;
  final CacheValueRegistry? valueRegistry;

  CacheModule({this.maxMemoryItems = 100, this.valueRegistry});

  @override
  String get name => 'CacheModule';

  @override
  int get priority => InitPriorities.cache;

  @override
  List<Type> get dependencies => [ILogger, IKeyValueStorage];

  @override
  List<Type> get provides => [ICacheManager];

  @override
  Future<void> onRegister(IServiceLocator locator) async {
    final logger = locator.get<ILogger>();
    final storage = locator.get<IKeyValueStorage>();

    final cacheManager = MultiLevelCacheManager(
      storage: storage,
      logger: logger,
      maxMemoryItems: maxMemoryItems,
      valueRegistry: valueRegistry,
    );

    locator.registerSingleton<ICacheManager>(cacheManager);
  }

  @override
  Future<void> onInit() async {
    final cacheManager = locator.get<ICacheManager>();
    await cacheManager.init();
  }

  @override
  Future<void> onDispose() async {
    final cacheManager = locator.get<ICacheManager>();
    if (cacheManager is MultiLevelCacheManager) {
      await cacheManager.disposeMemory();
      return;
    }
    await cacheManager.clear();
  }
}
