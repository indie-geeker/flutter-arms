import 'package:mockito/mockito.dart';
import 'package:app_interfaces/app_interfaces.dart';

/// Mock 存储实现，用于测试
class MockStorage extends Mock implements IStorage {
  bool _isInitialized = false;
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  String get storageName => 'MockStorage';
  
  @override
  Future<bool> init() async {
    _isInitialized = true;
    return true;
  }
  
  @override
  Future<bool> close() async {
    _isInitialized = false;
    return true;
  }
  
  @override
  Future<bool> clear() async {
    return true;
  }
}

/// Mock 键值存储实现，用于测试
class MockKeyValueStorage extends Mock implements IKeyValueStorage {
  bool _isInitialized = false;
  final Map<String, dynamic> _storage = {};
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  String get storageName => 'MockKeyValueStorage';
  
  @override
  Future<bool> init() async {
    _isInitialized = true;
    return true;
  }
  
  @override
  Future<bool> close() async {
    _isInitialized = false;
    return true;
  }
  
  @override
  Future<bool> clear() async {
    _storage.clear();
    return true;
  }
  
  @override
  Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }
  
  @override
  Future<String?> getString(String key, [String? defaultValue]) async {
    return _storage[key] as String? ?? defaultValue;
  }
  
  @override
  Future<bool> setInt(String key, int value) async {
    _storage[key] = value;
    return true;
  }
  
  @override
  Future<int?> getInt(String key, [int? defaultValue]) async {
    return _storage[key] as int? ?? defaultValue;
  }
  
  @override
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }
  
  @override
  Future<bool?> getBool(String key, [bool? defaultValue]) async {
    return _storage[key] as bool? ?? defaultValue;
  }
  
  @override
  Future<bool> setDouble(String key, double value) async {
    _storage[key] = value;
    return true;
  }
  
  @override
  Future<double?> getDouble(String key, [double? defaultValue]) async {
    return _storage[key] as double? ?? defaultValue;
  }
  
  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _storage[key] = value;
    return true;
  }
  
  @override
  Future<List<String>?> getStringList(String key, [List<String>? defaultValue]) async {
    return _storage[key] as List<String>? ?? defaultValue;
  }
  
  @override
  Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }
  
  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }
  
  @override
  Future<Set<String>> getKeys() async {
    return _storage.keys.toSet();
  }
  
  @override
  Future<bool> reload() async {
    return true;
  }
  
  @override
  Stream<MapEntry<String, dynamic>> watch(String key) {
    // 简单的 mock 实现，实际测试中可以根据需要扩展
    return Stream.empty();
  }
  
  @override
  Future<bool> setAll(Map<String, dynamic> values) async {
    _storage.addAll(values);
    return true;
  }
  
  @override
  Future<Map<String, dynamic>> getAll() async {
    return Map.from(_storage);
  }
}
