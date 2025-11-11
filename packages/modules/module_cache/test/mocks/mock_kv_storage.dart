import 'package:interfaces/storage/i_kv_storage.dart';

/// Mock implementation of IKeyValueStorage for testing
class MockKeyValueStorage implements IKeyValueStorage {
  final Map<String, dynamic> _storage = {};
  bool _initialized = false;
  bool _shouldThrowError = false;

  void enableErrorMode() => _shouldThrowError = true;
  void disableErrorMode() => _shouldThrowError = false;

  void _checkError() {
    if (_shouldThrowError) {
      throw Exception('Mock storage error');
    }
  }

  @override
  Future<void> init() async {
    _initialized = true;
  }

  @override
  Future<void> setString(String key, String value) async {
    _checkError();
    _storage[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    _checkError();
    return _storage[key] as String?;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _checkError();
    _storage[key] = value;
  }

  @override
  Future<int?> getInt(String key) async {
    _checkError();
    return _storage[key] as int?;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _checkError();
    _storage[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async {
    _checkError();
    return _storage[key] as bool?;
  }

  @override
  Future<void> setDouble(String key, double value) async {
    _checkError();
    _storage[key] = value;
  }

  @override
  Future<double?> getDouble(String key) async {
    _checkError();
    return _storage[key] as double?;
  }

  @override
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    _checkError();
    _storage[key] = value;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    _checkError();
    return _storage[key] as Map<String, dynamic>?;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _checkError();
    _storage[key] = value;
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    _checkError();
    return _storage[key] as List<String>?;
  }

  @override
  Future<void> remove(String key) async {
    _checkError();
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _checkError();
    _storage.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    _checkError();
    return _storage.containsKey(key);
  }

  @override
  Future<Set<String>> getKeys() async {
    _checkError();
    return _storage.keys.toSet();
  }

  @override
  Future<int> getSize() async {
    _checkError();
    // Simple size estimation: count all stored items
    return _storage.length * 100; // Arbitrary size estimation
  }

  @override
  Future<void> close() async {
    _checkError();
    // Nothing to close in mock
  }

  /// Test helper to get internal storage
  Map<String, dynamic> get internalStorage => _storage;
}
