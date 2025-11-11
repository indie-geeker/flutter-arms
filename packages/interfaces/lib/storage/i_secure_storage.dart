import 'i_storage.dart';

/// 安全存储接口（加密存储，用于敏感信息）
/// 实现：FlutterSecureStorage
abstract class ISecureStorage extends IStorage {
  /// 安全存储数据
  Future<void> write(String key, String value);

  /// 安全读取数据
  Future<String?> read(String key);

  /// 删除数据
  Future<void> delete(String key);

  /// 检查键是否存在
  Future<bool> containsKey(String key);

  /// 获取所有键
  Future<Set<String>> getKeys();

  /// 读取所有数据
  Future<Map<String, String>> readAll();

  /// 删除所有数据
  Future<void> deleteAll();
}