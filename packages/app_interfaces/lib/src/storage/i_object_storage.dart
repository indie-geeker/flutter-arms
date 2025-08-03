import 'dart:async';

import 'i_storage.dart';

/// 对象存储接口
///
/// 定义对象类型存储的基本操作，适用于复杂数据结构的存储
/// 例如：NoSQL数据库、文档数据库等
abstract class IObjectStorage implements IStorage {
  /// 存储对象
  ///
  /// [key] 键名
  /// [value] 值（必须是可序列化的对象）
  /// [collection] 可选的集合名称
  /// 返回是否存储成功
  Future<bool> save<T>(String key, T value, [String? collection]);

  /// 获取对象
  ///
  /// [key] 键名
  /// [defaultValue] 默认值，当键不存在时返回
  /// [collection] 可选的集合名称
  /// 返回存储的对象或默认值
  Future<T?> get<T>(String key, [T? defaultValue, String? collection]);

  /// 删除对象
  ///
  /// [key] 键名
  /// [collection] 可选的集合名称
  /// 返回是否删除成功
  Future<bool> delete<T>(String key, [String? collection]);

  /// 获取集合中的所有对象
  ///
  /// [collection] 集合名称
  /// [fromJson] 从JSON转换为对象的函数
  /// 返回对象列表
  Future<List<T>> getAll<T>(
      String collection,
      T Function(Map<String, dynamic> json) fromJson,
      );

  /// 根据条件查询对象
  ///
  /// [collection] 集合名称
  /// [filter] 过滤条件函数
  /// [fromJson] 从JSON转换为对象的函数
  /// 返回符合条件的对象列表
  Future<List<T>> query<T>(
      String collection,
      bool Function(T item) filter,
      T Function(Map<String, dynamic> json) fromJson,
      );

  /// 获取集合中的对象数量
  ///
  /// [collection] 集合名称
  /// 返回对象数量
  Future<int> count(String collection);

  /// 检查键是否存在
  ///
  /// [key] 键名
  /// [collection] 可选的集合名称
  /// 返回键是否存在
  Future<bool> exists(String key, [String? collection]);

  /// 清空集合
  ///
  /// [collection] 集合名称
  /// 返回是否清空成功
  Future<bool> clearCollection(String collection);

  /// 获取所有集合名称
  ///
  /// 返回集合名称列表
  Future<List<String>> getCollections();

  /// 获取集合中的所有键
  ///
  /// [collection] 集合名称
  /// 返回键列表
  Future<List<String>> getKeys(String collection);

  /// 批量保存对象
  ///
  /// [items] 键值对
  /// [collection] 可选的集合名称
  /// 返回是否保存成功
  Future<bool> saveAll<T>(Map<String, T> items, [String? collection]);

  /// 批量删除对象
  ///
  /// [keys] 键列表
  /// [collection] 可选的集合名称
  /// 返回是否删除成功
  Future<bool> deleteAll(List<String> keys, [String? collection]);

  /// 监听对象变化
  ///
  /// [key] 键名
  /// [collection] 可选的集合名称
  /// [fromJson] 从JSON转换为对象的函数
  /// 返回对象变化的流
  Stream<T?> watch<T>(
      String key,
      T Function(Map<String, dynamic> json) fromJson,
      [String? collection]
      );

  /// 监听集合变化
  ///
  /// [collection] 集合名称
  /// [fromJson] 从JSON转换为对象的函数
  /// 返回集合变化的流
  Stream<List<T>> watchCollection<T>(
      String collection,
      T Function(Map<String, dynamic> json) fromJson,
      );

  /// 执行事务
  ///
  /// [action] 事务操作函数
  /// 返回事务是否执行成功
  Future<bool> transaction(Future<bool> Function(IObjectStorage storage) action);
}

