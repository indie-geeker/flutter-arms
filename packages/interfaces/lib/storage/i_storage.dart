/// Generic storage abstract base class.
abstract class IStorage {
  /// Initializes the storage.
  Future<void> init();

  /// Closes the storage.
  Future<void> close();

  /// Clears all data.
  Future<void> clear();

  /// Returns the storage size in bytes.
  Future<int> getSize();
}
