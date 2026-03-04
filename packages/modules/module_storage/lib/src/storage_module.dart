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

/// Storage module
class StorageModule extends BaseModule {
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
  int get priority => InitPriorities.storage;

  @override
  List<Type> get dependencies => [ILogger];

  @override
  List<Type> get provides {
    final provided = <Type>[IKeyValueStorage];
    return provided;
  }

  @override
  Future<void> onRegister(IServiceLocator locator) async {
    final logger = locator.get<ILogger>();

    // Register KV storage
    final kvStorage = _keyValueStorageBuilder(logger: logger, config: config);
    locator.registerSingleton<IKeyValueStorage>(kvStorage);
    // Reserved extension point: relational/document storage can be registered here.
  }

  @override
  Future<void> onInit() async {
    final kvStorage = locator.get<IKeyValueStorage>();
    await kvStorage.init();
  }

  @override
  Future<void> onDispose() async {
    if (locator.isRegistered<IKeyValueStorage>()) {
      final kvStorage = locator.get<IKeyValueStorage>();
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

/// Storage configuration
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
