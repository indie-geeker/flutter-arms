import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/storage/i_kv_storage.dart';

import 'impl/hive_kv_storage.dart';

typedef KeyValueStorageBuilder =
    IKeyValueStorage Function({
      required ILogger logger,
      required StorageConfig config,
    });

/// 存储模块
class StorageModule implements IModule {
  final StorageConfig config;
  final KeyValueStorageBuilder _keyValueStorageBuilder;

  StorageModule({
    StorageConfig? config,
    KeyValueStorageBuilder? keyValueStorageBuilder,
  }) : config = config ?? StorageConfig(),
       _keyValueStorageBuilder =
           keyValueStorageBuilder ?? _defaultKeyValueStorageBuilder;

  @override
  String get name => 'StorageModule';

  @override
  int get priority => InitPriorities.storage; // 在日志之后初始化

  @override
  List<Type> get dependencies => [ILogger];

  @override
  List<Type> get provides => [IKeyValueStorage];

  // 保存 locator 引用以便在 init 中使用
  late IServiceLocator _locator;

  @override
  Future<void> register(IServiceLocator locator) async {
    // 注意：使用 IServiceLocator 接口，不依赖具体的 ServiceLocator 实现
    _locator = locator; // 保存引用，供 init 方法使用

    final logger = locator.get<ILogger>();

    // 注册 KV 存储
    final kvStorage = _keyValueStorageBuilder(logger: logger, config: config);
    locator.registerSingleton<IKeyValueStorage>(kvStorage);
    // Reserved extension point: relational/document storage can be registered here.
  }

  @override
  Future<void> init() async {
    final kvStorage = _locator.get<IKeyValueStorage>();
    await kvStorage.init();
  }

  @override
  Future<void> dispose() async {
    if (_locator.isRegistered<IKeyValueStorage>()) {
      final kvStorage = _locator.get<IKeyValueStorage>();
      await kvStorage.close();
    }
  }
}

IKeyValueStorage _defaultKeyValueStorageBuilder({
  required ILogger logger,
  required StorageConfig config,
}) {
  return HiveKeyValueStorage(
    logger: logger,
    boxName: config.kvStorageBoxName,
    baseDir: config.baseDir,
  );
}

/// 存储配置
class StorageConfig {
  final String kvStorageBoxName;

  /// Hive base directory. Absolute path uses Hive.init; relative uses initFlutter subDir.
  final String? baseDir;
  final bool enableRelationalStorage;
  final String databaseName;

  StorageConfig({
    this.kvStorageBoxName = 'app_storage',
    this.baseDir,
    this.enableRelationalStorage = false,
    this.databaseName = 'app.db',
  });
}
