import 'i_storage.dart';

/// Key-value storage interface.
///
/// Provides typed get/set methods for common primitives, lists, and JSON.
/// Implementations include Hive, SharedPreferences, and MMKV.
abstract class IKeyValueStorage extends IStorage {
  /// Stores a [String] value under [key].
  Future<void> setString(String key, String value);

  /// Returns the [String] stored under [key], or `null`.
  Future<String?> getString(String key);

  /// Stores an [int] value under [key].
  Future<void> setInt(String key, int value);

  /// Returns the [int] stored under [key], or `null`.
  Future<int?> getInt(String key);

  /// Stores a [bool] value under [key].
  Future<void> setBool(String key, bool value);

  /// Returns the [bool] stored under [key], or `null`.
  Future<bool?> getBool(String key);

  /// Stores a [double] value under [key].
  Future<void> setDouble(String key, double value);

  /// Returns the [double] stored under [key], or `null`.
  Future<double?> getDouble(String key);

  /// Stores a [List<String>] under [key].
  Future<void> setStringList(String key, List<String> value);

  /// Returns the [List<String>] stored under [key], or `null`.
  Future<List<String>?> getStringList(String key);

  /// Stores a JSON [Map] under [key].
  Future<void> setJson(String key, Map<String, dynamic> value);

  /// Returns the JSON [Map] stored under [key], or `null`.
  Future<Map<String, dynamic>?> getJson(String key);

  /// Removes the entry for [key].
  Future<void> remove(String key);

  /// Returns `true` if [key] exists.
  Future<bool> containsKey(String key);

  /// Returns all currently stored keys.
  Future<Set<String>> getKeys();
}
