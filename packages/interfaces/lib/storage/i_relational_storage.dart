import 'i_storage.dart';

/// Relational database interface.
/// Implementations: SQLite, Drift.
abstract class IRelationalStorage extends IStorage {
  /// Executes a raw SQL query.
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]);

  /// Executes a raw SQL command.
  Future<int> rawExecute(String sql, [List<dynamic>? arguments]);

  /// Inserts a row.
  Future<int> insert(String table, Map<String, dynamic> values);

  /// Queries rows.
  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  });

  /// Updates rows.
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  });

  /// Deletes rows.
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs});

  /// Begins a transaction.
  Future<void> beginTransaction();

  /// Commits a transaction.
  Future<void> commit();

  /// Rolls back a transaction.
  Future<void> rollback();
}
