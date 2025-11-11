
import 'i_storage.dart';

/// 关系型数据库接口
/// 实现：SQLite、Drift
abstract class IRelationalStorage extends IStorage {
  /// 执行原始 SQL 查询
  Future<List<Map<String, dynamic>>> rawQuery(
      String sql, [
        List<dynamic>? arguments,
      ]);

  /// 执行原始 SQL 命令
  Future<int> rawExecute(
      String sql, [
        List<dynamic>? arguments,
      ]);

  /// 插入数据
  Future<int> insert(
      String table,
      Map<String, dynamic> values,
      );

  /// 查询数据
  Future<List<Map<String, dynamic>>> query(
      String table, {
        List<String>? columns,
        String? where,
        List<dynamic>? whereArgs,
        String? orderBy,
        int? limit,
        int? offset,
      });

  /// 更新数据
  Future<int> update(
      String table,
      Map<String, dynamic> values, {
        String? where,
        List<dynamic>? whereArgs,
      });

  /// 删除数据
  Future<int> delete(
      String table, {
        String? where,
        List<dynamic>? whereArgs,
      });

  /// 开始事务
  Future<void> beginTransaction();

  /// 提交事务
  Future<void> commit();

  /// 回滚事务
  Future<void> rollback();
}