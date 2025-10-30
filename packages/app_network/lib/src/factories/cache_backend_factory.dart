import 'package:app_interfaces/app_interfaces.dart';

import '../cache/composite_cache_strategy.dart';
import '../cache/disk_cache_strategy.dart';
import '../cache/memory_cache_strategy.dart';

/// 默认缓存后端工厂实现
///
/// 创建各种类型的缓存策略实例
class DefaultCacheBackendFactory implements ICacheBackendFactory {
  /// 存储实现(用于磁盘缓存)
  final IKeyValueStorage? _storage;

  /// 创建缓存后端工厂
  ///
  /// [storage] 存储实现,如果需要磁盘缓存则必须提供
  const DefaultCacheBackendFactory({
    IKeyValueStorage? storage,
  }) : _storage = storage;

  @override
  ICacheStrategy createMemoryCache(MemoryCacheConfig config) {
    return MemoryCacheStrategy(
      defaultTtl: config.defaultMaxAge,
      maxCacheSize: config.maxEntries,
    );
  }

  @override
  Future<ICacheStrategy> createDiskCache(DiskCacheConfig config) async {
    final storage = _storage;
    if (storage == null) {
      throw StateError(
        'Storage implementation is required for disk cache. '
        'Please provide IKeyValueStorage to DefaultCacheBackendFactory.',
      );
    }

    return DiskCacheStrategy(
      storage: storage,
      defaultTtl: config.defaultMaxAge,
      maxCacheSize: config.maxEntries,
      cacheDirectory: config.cachePath ?? 'network_cache',
    );
  }

  @override
  Future<ICacheStrategy> createHybridCache(HybridCacheConfig config) async {
    // 创建内存缓存
    final memoryCache = createMemoryCache(config.memoryConfig);

    // 尝试创建磁盘缓存
    ICacheStrategy? diskCache;
    if (_storage != null) {
      try {
        diskCache = await createDiskCache(config.diskConfig);
      } catch (e) {
        // 磁盘缓存创建失败,仅使用内存缓存
        diskCache = null;
      }
    }

    // 如果有磁盘缓存,创建组合策略
    if (diskCache != null) {
      return CompositeCacheStrategy(
        memoryCache: memoryCache,
        diskCache: diskCache,
      );
    }

    // 否则只返回内存缓存
    return memoryCache;
  }

  @override
  String get cacheType => 'default';

  @override
  bool get isSupported => true;
}
