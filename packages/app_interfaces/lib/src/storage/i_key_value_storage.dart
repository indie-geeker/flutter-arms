
import 'dart:async';
import 'i_storage.dart';

/// 键值存储接口
/// 定义键值对类型存储的基本操作，适用于轻量级数据存储
/// 例如：SharedPreferences, LocalStorage, InMemory缓存等
abstract class IKeyValueStorage implements IStorage {
  /// 存储字符串值
  ///
  /// [key] 键名
  /// [value] 值
  /// 返回是否存储成功
  Future<bool> setString(String key, String value);

  /// 获取字符串值
  ///
  /// [key] 键名
  /// [defaultValue] 默认值，当键不存在时返回
  /// 返回存储的值或默认值
  Future<String?> getString(String key, [String? defaultValue]);

  /// 存储整数值
  ///
  /// [key] 键名
  /// [value] 值
  /// 返回是否存储成功
  Future<bool> setInt(String key, int value);

  /// 获取整数值
  ///
  /// [key] 键名
  /// [defaultValue] 默认值，当键不存在时返回
  /// 返回存储的值或默认值
  Future<int?> getInt(String key, [int? defaultValue]);

  /// 存储双精度浮点数值
  ///
  /// [key] 键名
  /// [value] 值
  /// 返回是否存储成功
  Future<bool> setDouble(String key, double value);

  /// 获取双精度浮点数值
  ///
  /// [key] 键名
  /// [defaultValue] 默认值，当键不存在时返回
  /// 返回存储的值或默认值
  Future<double?> getDouble(String key, [double? defaultValue]);

  /// 存储布尔值
  ///
  /// [key] 键名
  /// [value] 值
  /// 返回是否存储成功
  Future<bool> setBool(String key, bool value);

  /// 获取布尔值
  ///
  /// [key] 键名
  /// [defaultValue] 默认值，当键不存在时返回
  /// 返回存储的值或默认值
  Future<bool?> getBool(String key, [bool? defaultValue]);

  /// 存储字符串列表
  ///
  /// [key] 键名
  /// [value] 值
  /// 返回是否存储成功
  Future<bool> setStringList(String key, List<String> value);

  /// 获取字符串列表
  ///
  /// [key] 键名
  /// [defaultValue] 默认值，当键不存在时返回
  /// 返回存储的值或默认值
  Future<List<String>?> getStringList(String key, [List<String>? defaultValue]);

  /// 检查键是否存在
  ///
  /// [key] 键名
  /// 返回键是否存在
  Future<bool> containsKey(String key);

  /// 删除指定的键
  ///
  /// [key] 键名
  /// 返回是否删除成功
  Future<bool> remove(String key);

  /// 获取所有键
  ///
  /// 返回所有键的集合
  Future<Set<String>> getKeys();

  /// 重新加载数据
  ///
  /// 从持久化存储中重新加载数据到内存
  /// 返回是否重新加载成功
  Future<bool> reload();

  /// 监听键值变化
  ///
  /// [key] 要监听的键名
  /// 返回一个Stream，当键值变化时会发出事件
  Stream<MapEntry<String, dynamic>> watch(String key);

  /// 批量设置多个键值
  ///
  /// [values] 键值对
  /// 返回是否设置成功
  Future<bool> setAll(Map<String, dynamic> values);

  /// 获取所有键值对
  ///
  /// 返回所有键值对
  Future<Map<String, dynamic>> getAll();
}
