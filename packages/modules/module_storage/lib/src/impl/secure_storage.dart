import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:interfaces/storage/i_secure_storage.dart';

/// 基于 flutter_secure_storage 的安全存储实现
class FlutterSecureStorageImpl implements ISecureStorage {
  final FlutterSecureStorage _storage;

  FlutterSecureStorageImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> init() async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  @override
  Future<int> getSize() async {
    // flutter_secure_storage 不提供大小信息
    return 0;
  }

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }

  @override
  Future<Set<String>> getKeys() async {
    final all = await _storage.readAll();
    return all.keys.toSet();
  }

  @override
  Future<Map<String, String>> readAll() async {
    return _storage.readAll();
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
