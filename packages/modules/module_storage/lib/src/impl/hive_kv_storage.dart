
import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:path_provider/path_provider.dart';

/// 基于 Hive 的 KV 存储实现
class HiveKeyValueStorage implements IKeyValueStorage {
  late Box _box;
  final String boxName;
  final ILogger _logger;

  HiveKeyValueStorage({
    required ILogger logger,
    this.boxName = 'app_storage',
  }) : _logger = logger;

  @override
  Future<void> init() async {
    try {
      var path = await getApplicationCacheDirectory();
       Hive.init(path.path);
      _box = await Hive.openBox(boxName);
      _logger.info('Hive KV module_storage initialized');
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize Hive module_storage',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    await _box.close();
  }

  @override
  Future<void> setString(String key, String value) async {
    await _box.put(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _box.get(key) as String?;
  }

  @override
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await _box.put(key, jsonEncode(value));
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _box.get(key);
    if (value == null) return null;
    return jsonDecode(value as String) as Map<String, dynamic>;
  }

  @override
  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _box.containsKey(key);
  }

  @override
  Future<Set<String>> getKeys() async {
    return _box.keys.cast<String>().toSet();
  }

  @override
  Future<int> getSize() async {
    try {
      final file = File(_box.path!);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    return _box.get(key) as bool?;
  }

  @override
  Future<double?> getDouble(String key) async {
    return _box.get(key) as double?;
  }

  @override
  Future<int?> getInt(String key) async {
    return _box.get(key) as int?;
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final value = _box.get(key);
    if (value == null) return null;
    return (value as List).cast<String>();
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _box.put(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await _box.put(key, value);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _box.put(key, value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await _box.put(key, value);
  }

}