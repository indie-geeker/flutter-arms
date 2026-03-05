import 'i_storage.dart';

/// Document storage interface (NoSQL-like).
/// Implementations: Hive, Isar.
abstract class IDocumentStorage<T> extends IStorage {
  /// Inserts a document.
  Future<String> insert(T document);

  /// Batch inserts documents.
  Future<List<String>> insertAll(List<T> documents);

  /// Finds a document by ID.
  Future<T?> findById(String id);

  /// Returns all documents.
  Future<List<T>> findAll();

  /// Queries documents matching a condition.
  Future<List<T>> findWhere(bool Function(T) test);

  /// Updates a document.
  Future<void> update(String id, T document);

  /// Deletes a document.
  Future<void> delete(String id);

  /// Deletes documents matching a condition.
  Future<void> deleteWhere(bool Function(T) test);

  /// Returns the document count.
  Future<int> count();
}
