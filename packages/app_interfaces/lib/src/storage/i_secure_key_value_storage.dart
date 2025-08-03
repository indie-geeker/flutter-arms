import 'i_key_value_storage.dart';

/// 安全键值存储接口
///
/// 扩展普通键值存储，提供加密存储能力，适用于存储敏感数据
abstract class ISecureKeyValueStorage extends IKeyValueStorage {
  /// 是否启用加密
  bool get isEncryptionEnabled;

  /// 启用加密
  ///
  /// 返回是否启用成功
  Future<bool> enableEncryption();

  /// 禁用加密
  ///
  /// 返回是否禁用成功
  Future<bool> disableEncryption();

  /// 更改加密密钥
  ///
  /// [newKey] 新密钥
  /// 返回是否更改成功
  Future<bool> setEncryptionKey(String newKey);
}
