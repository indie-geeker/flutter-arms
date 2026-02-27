import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:interfaces/storage/i_secure_storage.dart';

import 'impl/hive_kv_storage.dart';
import 'impl/secure_storage.dart';

typedef KeyValueStorageBuilder =
    IKeyValueStorage Function({
      required ILogger logger,
      required StorageConfig config,
    });

typedef SecureStorageBuilder = ISecureStorage Function();

/// 存储模块
class StorageModule implements IModule {
  final StorageConfig config;
  final KeyValueStorageBuilder _keyValueStorageBuilder;
  final SecureStorageBuilder _secureStorageBuilder;

  StorageModule({
    StorageConfig? config,
    KeyValueStorageBuilder? keyValueStorageBuilder,
    SecureStorageBuilder? secureStorageBuilder,
  }) : config = config ?? StorageConfig(),
       _keyValueStorageBuilder =
           keyValueStorageBuilder ?? _defaultKeyValueStorageBuilder,
       _secureStorageBuilder =
           secureStorageBuilder ?? _defaultSecureStorageBuilder;

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
    final kvStorage = _keyValueStorageBuilder(
      logger: logger,
      config: config,
    );
    locator.registerSingleton<IKeyValueStorage>(kvStorage);
    // Reserved extension point: relational/document storage can be registered here.

    // 注册安全存储（可选）
    if (config.enableSecureStorage) {
      final secureStorage = _secureStorageBuilder();
      locator.registerSingleton<ISecureStorage>(secureStorage);
    }
  }

  @override
  Future<void> init() async {
    final kvStorage = _locator.get<IKeyValueStorage>();
    await kvStorage.init();
    if (_locator.isRegistered<ISecureStorage>()) {
      final secureStorage = _locator.get<ISecureStorage>();
      await secureStorage.init();
    }
  }

  @override
  Future<void> dispose() async {
    if (_locator.isRegistered<IKeyValueStorage>()) {
      final kvStorage = _locator.get<IKeyValueStorage>();
      await kvStorage.close();
    }
    if (_locator.isRegistered<ISecureStorage>()) {
      final secureStorage = _locator.get<ISecureStorage>();
      await secureStorage.close();
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

ISecureStorage _defaultSecureStorageBuilder() => FlutterSecureStorageImpl();

/// 存储配置
class StorageConfig {
  final String kvStorageBoxName;

  /// Hive base directory. Absolute path uses Hive.init; relative uses initFlutter subDir.
  final String? baseDir;
  final bool enableRelationalStorage;
  final bool enableSecureStorage;
  final String databaseName;

  StorageConfig({
    this.kvStorageBoxName = 'app_storage',
    this.baseDir,
    this.enableRelationalStorage = false,
    this.enableSecureStorage = false,
    this.databaseName = 'app.db',
  });
}
