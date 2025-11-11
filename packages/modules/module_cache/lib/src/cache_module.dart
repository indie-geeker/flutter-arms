
import 'package:interfaces/cache/i_cache_manager.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/storage/i_kv_storage.dart';

import 'impl/multi_level_cache.dart';

/// 缓存模块
class CacheModule implements IModule {
  final int maxMemoryItems;

  CacheModule({this.maxMemoryItems = 100});

  @override
  String get name => 'CacheModule';

  @override
  int get priority => InitPriorities.cache; // 在 Storage 之后初始化

  @override
  List<Type> get dependencies => [ILogger, IKeyValueStorage];

  // 保存 locator 引用以便在 init 中使用
  late IServiceLocator _locator;

  @override
  Future<void> register(IServiceLocator locator) async {
    // 注意：使用 IServiceLocator 接口，不依赖具体的 ServiceLocator 实现
    _locator = locator; // 保存引用，供 init 方法使用

    final logger = locator.get<ILogger>();
    final storage = locator.get<IKeyValueStorage>(); // 依赖 Storage

    final cacheManager = MultiLevelCacheManager(
      storage: storage,  // 注入 Storage 接口
      logger: logger,
      maxMemoryItems: maxMemoryItems,
    );

    locator.registerSingleton<ICacheManager>(cacheManager);
  }

  @override
  Future<void> init() async {
    final cacheManager = _locator.get<ICacheManager>();
    await cacheManager.init();
  }

  @override
  Future<void> dispose() async {
    final cacheManager = _locator.get<ICacheManager>();
    await cacheManager.clear();
  }
}