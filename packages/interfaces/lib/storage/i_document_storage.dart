
import 'i_storage.dart';

/// 文档存储接口（类似 NoSQL）
/// 实现：Hive、Isar
abstract class IDocumentStorage<T> extends IStorage {
  /// 插入文档
  Future<String> insert(T document);

  /// 批量插入
  Future<List<String>> insertAll(List<T> documents);

  /// 根据 ID 查询文档
  Future<T?> findById(String id);

  /// 查询所有文档
  Future<List<T>> findAll();

  /// 条件查询
  Future<List<T>> findWhere(bool Function(T) test);

  /// 更新文档
  Future<void> update(String id, T document);

  /// 删除文档
  Future<void> delete(String id);

  /// 批量删除
  Future<void> deleteWhere(bool Function(T) test);

  /// 计数
  Future<int> count();
}