import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/core/storage/storage_initializer.dart';

/// Hive 存储初始化器。
final class HiveStorageInitializer implements StorageInitializer {
  /// 构造函数。
  const HiveStorageInitializer();

  @override
  String get adapterName => 'hive';

  @override
  Future<KvStorage> initialize() async {
    await HiveKvStorage.ensureInitialized();
    return HiveKvStorage.instance;
  }
}
