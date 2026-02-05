import 'package:hive/hive.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:interfaces/storage/i_secure_storage.dart';

import 'impl/hive_kv_storage.dart';
import 'impl/secure_storage.dart';

/// 存储模块
class StorageModule implements IModule {
  final StorageConfig config;

  StorageModule({StorageConfig? config})
      : config = config ?? StorageConfig();

  @override
  String get name => 'StorageModule';

  @override
  int get priority => InitPriorities.storage; // 在日志之后初始化

  @override
  List<Type> get dependencies => [ILogger];

  @override
  List<Type> get provides {
    final provided = <Type>[IKeyValueStorage];
    if (config.enableSecureStorage) {
      provided.add(ISecureStorage);
    }
    return provided;
  }

  // 保存 locator 引用以便在 init 中使用
  late IServiceLocator _locator;

  @override
  Future<void> register(IServiceLocator locator) async {
    // 注意：使用 IServiceLocator 接口，不依赖具体的 ServiceLocator 实现
    _locator = locator; // 保存引用，供 init 方法使用

    final logger = locator.get<ILogger>();

    // 注册 KV 存储
    final kvStorage = HiveKeyValueStorage(
      logger: logger,
      boxName: config.kvStorageBoxName,
    );
    locator.registerSingleton<IKeyValueStorage>(kvStorage);

    // // 注册关系型存储（可选）
    // if (config.enableRelationalStorage) {
    //   final relationalStorage = SQLiteStorage(
    //     logger: logger,
    //     databaseName: config.databaseName,
    //   );
    //   locator.registerSingleton<IRelationalStorage>(relationalStorage);
    // }
    //
    // 注册安全存储（可选）
    if (config.enableSecureStorage) {
      final secureStorage = FlutterSecureStorageImpl();
      locator.registerSingleton<ISecureStorage>(secureStorage);
    }
  }

  @override
  Future<void> init() async {
    final kvStorage = _locator.get<IKeyValueStorage>();
    await kvStorage.init();

    // if (_locator.isRegistered<IRelationalStorage>()) {
    //   final relationalStorage = _locator.get<IRelationalStorage>();
    //   await relationalStorage.init();
    // }
    //
    if (_locator.isRegistered<ISecureStorage>()) {
      final secureStorage = _locator.get<ISecureStorage>();
      await secureStorage.init();
    }
  }

  @override
  Future<void> dispose() async {
    if (_locator.isRegistered<ISecureStorage>()) {
      final secureStorage = _locator.get<ISecureStorage>();
      await secureStorage.close();
    }
    await Hive.close();
  }
}

/// 存储配置
class StorageConfig {
  final String kvStorageBoxName;
  final bool enableRelationalStorage;
  final bool enableSecureStorage;
  final String databaseName;

  StorageConfig({
    this.kvStorageBoxName = 'app_storage',
    this.enableRelationalStorage = false,
    this.enableSecureStorage = false,
    this.databaseName = 'app.db',
  });
}
