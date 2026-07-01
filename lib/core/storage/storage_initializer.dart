import 'package:flutter_arms/core/storage/kv_storage.dart';

/// 存储初始化端口。
abstract interface class StorageInitializer {
  /// 初始化器名称，用于日志或诊断。
  String get adapterName;

  /// 初始化并返回可注入的键值存储。
  Future<KvStorage> initialize();
}
