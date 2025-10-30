import 'package:app_interfaces/src/storage/i_key_value_storage.dart';

/// 存储配置
///
/// 用于配置存储工厂创建存储实例
class StorageFactoryConfig {
  /// 应用名称,用于生成存储键前缀
  final String appName;

  /// 是否启用加密
  final bool enableEncryption;

  /// 加密密钥(如果启用加密)
  final String? encryptionKey;

  /// 最大缓存条目数(用于内存存储)
  final int? maxCacheEntries;

  /// 数据库路径(用于数据库存储)
  final String? databasePath;

  /// 数据库版本(用于数据库存储)
  final int? databaseVersion;

  /// 额外配置
  final Map<String, dynamic>? extra;

  const StorageFactoryConfig({
    required this.appName,
    this.enableEncryption = false,
    this.encryptionKey,
    this.maxCacheEntries,
    this.databasePath,
    this.databaseVersion,
    this.extra,
  });

  /// 默认配置
  factory StorageFactoryConfig.defaults(String appName) {
    return StorageFactoryConfig(
      appName: appName,
      enableEncryption: false,
      maxCacheEntries: 1000,
    );
  }

  /// 安全配置(启用加密)
  factory StorageFactoryConfig.secure({
    required String appName,
    required String encryptionKey,
    int? maxCacheEntries,
  }) {
    return StorageFactoryConfig(
      appName: appName,
      enableEncryption: true,
      encryptionKey: encryptionKey,
      maxCacheEntries: maxCacheEntries ?? 1000,
    );
  }

  /// 复制并修改配置
  StorageFactoryConfig copyWith({
    String? appName,
    bool? enableEncryption,
    String? encryptionKey,
    int? maxCacheEntries,
    String? databasePath,
    int? databaseVersion,
    Map<String, dynamic>? extra,
  }) {
    return StorageFactoryConfig(
      appName: appName ?? this.appName,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      maxCacheEntries: maxCacheEntries ?? this.maxCacheEntries,
      databasePath: databasePath ?? this.databasePath,
      databaseVersion: databaseVersion ?? this.databaseVersion,
      extra: extra ?? this.extra,
    );
  }
}

/// 存储工厂接口
///
/// 创建不同类型的存储实例(SharedPreferences、Hive、SQLite 等)
/// 支持多种存储后端的可插拔架构
abstract class IStorageFactory {
  /// 创建存储实例
  ///
  /// [config] 存储配置
  ///
  /// 返回键值存储实例
  Future<IKeyValueStorage> createStorage(StorageFactoryConfig config);

  /// 获取工厂支持的存储类型标识
  ///
  /// 如: 'shared_prefs', 'hive', 'sqlite', 'memory'
  String get storageType;

  /// 检查当前平台是否支持此存储类型
  ///
  /// 某些存储后端可能不支持特定平台(如 Web)
  bool get isSupported;

  /// 获取存储优先级
  ///
  /// 用于自动选择最佳存储后端
  /// 数字越大优先级越高
  int get priority => 0;
}

/// 存储工厂注册表
///
/// 单例模式,管理所有可用的存储工厂
class StorageFactoryRegistry {
  StorageFactoryRegistry._();

  static final StorageFactoryRegistry _instance = StorageFactoryRegistry._();

  factory StorageFactoryRegistry() => _instance;

  static StorageFactoryRegistry get instance => _instance;

  final Map<String, IStorageFactory> _factories = {};

  /// 注册存储工厂
  ///
  /// [factory] 存储工厂实例
  void register(IStorageFactory factory) {
    _factories[factory.storageType] = factory;
  }

  /// 注销存储工厂
  ///
  /// [storageType] 存储类型标识
  void unregister(String storageType) {
    _factories.remove(storageType);
  }

  /// 获取指定类型的存储工厂
  ///
  /// [storageType] 存储类型标识
  ///
  /// 返回存储工厂,如果不存在则返回 null
  IStorageFactory? get(String storageType) {
    return _factories[storageType];
  }

  /// 获取所有已注册的存储工厂
  List<IStorageFactory> getAll() {
    return _factories.values.toList();
  }

  /// 获取所有支持当前平台的存储工厂
  List<IStorageFactory> getSupportedFactories() {
    return _factories.values.where((factory) => factory.isSupported).toList();
  }

  /// 自动选择最佳存储工厂
  ///
  /// 根据优先级和平台支持情况自动选择
  /// 返回优先级最高且支持当前平台的工厂,如果没有则返回 null
  IStorageFactory? selectBest() {
    final supported = getSupportedFactories();
    if (supported.isEmpty) return null;

    supported.sort((a, b) => b.priority.compareTo(a.priority));
    return supported.first;
  }

  /// 检查是否已注册指定类型的工厂
  bool contains(String storageType) {
    return _factories.containsKey(storageType);
  }

  /// 清空所有已注册的工厂
  void clear() {
    _factories.clear();
  }

  /// 获取已注册工厂数量
  int get count => _factories.length;
}
