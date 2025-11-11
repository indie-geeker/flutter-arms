
import 'i_storage.dart';

/// 键值对存储接口
/// 实现：Hive、SharedPreferences、MMKV
abstract class IKeyValueStorage extends IStorage {
  /// 存储字符串
  Future<void> setString(String key, String value);

  /// 获取字符串
  Future<String?> getString(String key);

  /// 存储整数
  Future<void> setInt(String key, int value);

  /// 获取整数
  Future<int?> getInt(String key);

  /// 存储布尔值
  Future<void> setBool(String key, bool value);

  /// 获取布尔值
  Future<bool?> getBool(String key);

  /// 存储浮点数
  Future<void> setDouble(String key, double value);

  /// 获取浮点数
  Future<double?> getDouble(String key);

  /// 存储字符串列表
  Future<void> setStringList(String key, List<String> value);

  /// 获取字符串列表
  Future<List<String>?> getStringList(String key);

  /// 存储 JSON 对象
  Future<void> setJson(String key, Map<String, dynamic> value);

  /// 获取 JSON 对象
  Future<Map<String, dynamic>?> getJson(String key);

  /// 删除键
  Future<void> remove(String key);

  /// 检查键是否存在
  Future<bool> containsKey(String key);

  /// 获取所有键
  Future<Set<String>> getKeys();
}