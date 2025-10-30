import 'i_cache_strategy.dart';

/// 缓存后端配置
///
/// 用于配置不同类型的缓存后端
abstract class CacheBackendConfig {
  /// 最大缓存条目数
  final int maxEntries;

  /// 最大缓存大小(字节)
  final int maxSize;

  /// 缓存过期时间
  final Duration defaultMaxAge;

  const CacheBackendConfig({
    required this.maxEntries,
    required this.maxSize,
    required this.defaultMaxAge,
  });
}

/// 内存缓存配置
class MemoryCacheConfig extends CacheBackendConfig {
  /// 是否启用LRU淘汰策略
  final bool enableLRU;

  const MemoryCacheConfig({
    int maxEntries = 100,
    int maxSize = 10 * 1024 * 1024, // 10MB
    Duration defaultMaxAge = const Duration(minutes: 5),
    this.enableLRU = true,
  }) : super(
          maxEntries: maxEntries,
          maxSize: maxSize,
          defaultMaxAge: defaultMaxAge,
        );

  /// 默认配置
  factory MemoryCacheConfig.defaults() => const MemoryCacheConfig();

  /// 小内存配置
  factory MemoryCacheConfig.small() => const MemoryCacheConfig(
        maxEntries: 50,
        maxSize: 5 * 1024 * 1024, // 5MB
      );

  /// 大内存配置
  factory MemoryCacheConfig.large() => const MemoryCacheConfig(
        maxEntries: 500,
        maxSize: 50 * 1024 * 1024, // 50MB
      );
}

/// 磁盘缓存配置
class DiskCacheConfig extends CacheBackendConfig {
  /// 缓存目录路径
  final String? cachePath;

  /// 是否启用加密
  final bool enableEncryption;

  /// 加密密钥
  final String? encryptionKey;

  /// 是否启用压缩
  final bool enableCompression;

  const DiskCacheConfig({
    int maxEntries = 1000,
    int maxSize = 100 * 1024 * 1024, // 100MB
    Duration defaultMaxAge = const Duration(days: 7),
    this.cachePath,
    this.enableEncryption = false,
    this.encryptionKey,
    this.enableCompression = true,
  }) : super(
          maxEntries: maxEntries,
          maxSize: maxSize,
          defaultMaxAge: defaultMaxAge,
        );

  /// 默认配置
  factory DiskCacheConfig.defaults() => const DiskCacheConfig();

  /// 安全配置(启用加密)
  factory DiskCacheConfig.secure({
    required String encryptionKey,
    String? cachePath,
  }) =>
      DiskCacheConfig(
        enableEncryption: true,
        encryptionKey: encryptionKey,
        cachePath: cachePath,
      );
}

/// 混合缓存配置
///
/// 结合内存和磁盘缓存,实现L1/L2缓存架构
class HybridCacheConfig {
  /// L1缓存(内存)配置
  final MemoryCacheConfig memoryConfig;

  /// L2缓存(磁盘)配置
  final DiskCacheConfig diskConfig;

  /// 内存缓存未命中时是否回退到磁盘
  final bool enableFallback;

  /// 磁盘缓存是否同步到内存
  final bool enablePromotion;

  const HybridCacheConfig({
    required this.memoryConfig,
    required this.diskConfig,
    this.enableFallback = true,
    this.enablePromotion = true,
  });

  /// 默认配置
  factory HybridCacheConfig.defaults() => HybridCacheConfig(
        memoryConfig: MemoryCacheConfig.defaults(),
        diskConfig: DiskCacheConfig.defaults(),
      );

  /// 高性能配置(大内存 + 磁盘备份)
  factory HybridCacheConfig.performance() => HybridCacheConfig(
        memoryConfig: MemoryCacheConfig.large(),
        diskConfig: DiskCacheConfig.defaults(),
        enablePromotion: true,
      );

  /// 持久化配置(小内存 + 大磁盘)
  factory HybridCacheConfig.persistent() => HybridCacheConfig(
        memoryConfig: MemoryCacheConfig.small(),
        diskConfig: const DiskCacheConfig(
          maxEntries: 5000,
          maxSize: 500 * 1024 * 1024, // 500MB
          defaultMaxAge: Duration(days: 30),
        ),
        enablePromotion: false,
      );
}

/// 缓存后端工厂接口
///
/// 创建不同类型的缓存策略实例
abstract class ICacheBackendFactory {
  /// 创建内存缓存策略
  ///
  /// [config] 内存缓存配置
  ///
  /// 返回内存缓存策略实例
  ICacheStrategy createMemoryCache(MemoryCacheConfig config);

  /// 创建磁盘缓存策略
  ///
  /// [config] 磁盘缓存配置
  ///
  /// 返回磁盘缓存策略实例
  Future<ICacheStrategy> createDiskCache(DiskCacheConfig config);

  /// 创建混合缓存策略
  ///
  /// [config] 混合缓存配置
  ///
  /// 返回混合缓存策略实例
  Future<ICacheStrategy> createHybridCache(HybridCacheConfig config);

  /// 获取工厂支持的缓存类型标识
  ///
  /// 如: 'memory', 'disk', 'hybrid'
  String get cacheType;

  /// 检查当前平台是否支持此缓存类型
  ///
  /// 某些缓存类型可能不支持特定平台(如 Web 不支持磁盘缓存)
  bool get isSupported;
}

/// 默认缓存后端工厂
///
/// 提供内存缓存的默认实现,磁盘缓存需要具体实现
abstract class DefaultCacheBackendFactory implements ICacheBackendFactory {
  @override
  String get cacheType => 'default';

  @override
  bool get isSupported => true;

  @override
  Future<ICacheStrategy> createHybridCache(HybridCacheConfig config) async {
    // 默认实现:创建内存缓存,如果磁盘缓存可用则组合
    final memoryCache = createMemoryCache(config.memoryConfig);

    if (isSupported) {
      try {
        final diskCache = await createDiskCache(config.diskConfig);
        // 返回组合策略(需要具体实现)
        // 这里返回内存缓存作为回退
        return memoryCache;
      } catch (e) {
        // 磁盘缓存创建失败,回退到内存缓存
        return memoryCache;
      }
    }

    return memoryCache;
  }
}
