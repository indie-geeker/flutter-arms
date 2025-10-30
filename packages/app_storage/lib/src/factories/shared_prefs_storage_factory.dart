import 'package:app_interfaces/app_interfaces.dart';
import '../kv_storage/shared_prefs_storage.dart';
import '../model/storage_config.dart';

/// SharedPreferences 存储工厂
///
/// 创建基于 SharedPreferences 的存储实例
class SharedPrefsStorageFactory implements IStorageFactory {
  final ILogger? logger;

  const SharedPrefsStorageFactory({this.logger});

  @override
  Future<IKeyValueStorage> createStorage(
      StorageFactoryConfig config) async {
    // 转换为 StorageConfig
    final storageConfig = _convertConfig(config);

    // 创建存储实例
    final storage = SharedPrefsStorage(storageConfig, logger: logger);

    // 初始化存储
    await storage.init();

    return storage;
  }

  @override
  String get storageType => 'shared_prefs';

  @override
  bool get isSupported {
    // SharedPreferences 在所有平台都支持
    return true;
  }

  @override
  int get priority => 10; // SharedPreferences 优先级较低

  /// 转换配置格式
  StorageConfig _convertConfig(StorageFactoryConfig factoryConfig) {
    return StorageConfig(
      name: factoryConfig.appName,
      enableEncryption: factoryConfig.enableEncryption,
      encryptionKey: factoryConfig.encryptionKey,
    );
  }
}

/// 默认存储工厂注册辅助类
///
/// 提供便捷的工厂注册方法
class StorageFactoryRegistrar {
  /// 注册所有默认存储工厂
  static void registerDefaults({ILogger? logger}) {
    final registry = StorageFactoryRegistry.instance;

    // 注册 SharedPreferences 工厂
    registry.register(SharedPrefsStorageFactory(logger: logger));
  }

  /// 注册 SharedPreferences 工厂
  static void registerSharedPrefs({ILogger? logger}) {
    StorageFactoryRegistry.instance.register(
      SharedPrefsStorageFactory(logger: logger),
    );
  }
}
