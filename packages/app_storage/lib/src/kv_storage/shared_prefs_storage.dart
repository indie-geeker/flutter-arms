import 'dart:async';
import 'dart:collection';
import 'package:app_interfaces/app_interfaces.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/storage_config.dart';
import '../utils/storage_utils.dart';

class SharedPrefsStorage implements IKeyValueStorage {
  /// 存储配置
  final StorageConfig _config;

  ILogger? _logger;

  /// SharedPreferences 实例
  SharedPreferences? _prefs;

  /// 是否已初始化
  bool _initialized = false;

  /// 存储变化控制器
  final _changeController =
      StreamController<MapEntry<String, dynamic>>.broadcast();

  /// 存储内容镜像，用于变化检测
  final Map<String, dynamic> _mirror = HashMap<String, dynamic>();

  /// 创建 SharedPreferences 存储
  ///
  /// [config] 存储配置
  SharedPrefsStorage(this._config, {ILogger? logger}) {
    _logger = logger;
  }

  @override
  String get storageName => _config.name;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<bool> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // 初始化镜像
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        _mirror[key] = _prefs!.get(key);
      }
      _logger?.info('SharedPrefsStorage 初始化成功');
      _initialized = true;
      return true;
    } catch (e) {
      _logger?.error('SharedPrefsStorage 初始化失败',
          tag: 'SharedPrefsStorage', error: e);
      _initialized = false;
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    _checkInitialized();
    try {
      final result = await _prefs!.clear();
      if (result) {
        _mirror.clear();
        _logger?.info('SharedPrefsStorage 清除所有数据');
      }
      return result;
    } catch (e) {
      _logger?.error('SharedPrefsStorage 清除数据失败',
          tag: 'SharedPrefsStorage', error: e);
      return false;
    }
  }

  @override
  Future<bool> close() async {
    _checkInitialized();
    try {
      await _changeController.close();
      _initialized = false;
      _logger?.info('SharedPrefsStorage 关闭成功');
      return true;
    } catch (e) {
      _logger?.error('SharedPrefsStorage 关闭失败',
          tag: 'SharedPrefsStorage', error: e);
      return false;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    _checkInitialized();
    final fullKey = StorageUtils.generateFullKey(_config, key);
    return _prefs!.containsKey(fullKey);
  }

  @override
  Future<Map<String, dynamic>> getAll() async {
    _checkInitialized();
    final result = <String, dynamic>{};

    try {
      final keys = await getKeys();

      for (final fullKey in keys) {
        final key = _extractKeyFromFullKey(fullKey);
        if (key == null) continue;

        final type = _getValueType(fullKey);
        switch (type) {
          case _ValueType.string:
            result[key] = await getString(key);
            break;
          case _ValueType.int:
            result[key] = await getInt(key);
            break;
          case _ValueType.double:
            result[key] = await getDouble(key);
            break;
          case _ValueType.bool:
            result[key] = await getBool(key);
            break;
          case _ValueType.stringList:
            result[key] = await getStringList(key);
            break;
          default:
            // 未知类型，跳过
            break;
        }
      }

      _logger?.info('SharedPrefsStorage 获取所有数据: ${result.length}项');
      return result;
    } catch (e) {
      _logger?.error('SharedPrefsStorage 获取所有数据失败',
          tag: 'SharedPrefsStorage', error: e);
      return result;
    }
  }

  @override
  Future<bool?> getBool(String key, [bool? defaultValue]) async {
    _checkInitialized();
    final fullKey = StorageUtils.generateFullKey(_config, key);
    return _prefs!.getBool(fullKey) ?? defaultValue;
  }

  @override
  Future<double?> getDouble(String key, [double? defaultValue]) async {
    _checkInitialized();
    final fullKey = StorageUtils.generateFullKey(_config, key);
    return _prefs!.getDouble(fullKey) ?? defaultValue;
  }

  @override
  Future<int?> getInt(String key, [int? defaultValue]) async {
    _checkInitialized();
    final fullKey = StorageUtils.generateFullKey(_config, key);
    return _prefs!.getInt(fullKey) ?? defaultValue;
  }

  @override
  Future<Set<String>> getKeys() async {
    _checkInitialized();
    final prefix = StorageUtils.generateKeyPrefix(_config);
    return _prefs!
        .getKeys()
        .where((key) => key.startsWith('${prefix}_'))
        .toSet();
  }

  @override
  Future<String?> getString(String key, [String? defaultValue]) async {
    _checkInitialized();
    final fullKey = StorageUtils.generateFullKey(_config, key);
    final value = _prefs!.getString(fullKey);

    if (value == null) {
      return defaultValue;
    }

    // 如果启用加密，则解密
    return StorageUtils.decryptString(_config, value);
  }

  @override
  Future<List<String>?> getStringList(String key,
      [List<String>? defaultValue]) async {
    _checkInitialized();
    final fullKey = StorageUtils.generateFullKey(_config, key);
    final list = _prefs!.getStringList(fullKey);

    if (list == null) {
      return defaultValue;
    }

    // 如果启用加密，则解密列表中的每一项
    if (_config.enableEncryption && _config.encryptionKey != null) {
      return list
          .map((item) => StorageUtils.decryptString(_config, item) ?? '')
          .toList();
    }

    return list;
  }

  @override
  Future<bool> reload() async {
    _checkInitialized();
    try {
      await _prefs!.reload();

      // 更新镜像并触发变更事件
      final keys = _prefs!.getKeys();
      final oldKeys = Set<String>.from(_mirror.keys);

      // 检测删除的键
      for (final key in oldKeys) {
        if (!keys.contains(key)) {
          _mirror.remove(key);
          _changeController.add(MapEntry(key, null));
          _logger?.info('SharedPrefsStorage 删除键: $key');
        }
      }

      // 检测新增或修改的键
      for (final key in keys) {
        final newValue = _prefs!.get(key);
        final oldValue = _mirror[key];

        if (oldValue != newValue) {
          _mirror[key] = newValue;
          _changeController.add(MapEntry(key, newValue));
          _logger?.info('SharedPrefsStorage 设置键值: $key');
        }
      }

      _logger?.info('SharedPrefsStorage 重新加载成功');
      return true;
    } catch (e) {
      _logger?.error('SharedPrefsStorage 重新加载失败',
          tag: 'SharedPrefsStorage', error: e);
      return false;
    }
  }

  @override
  Future<bool> remove(String key) async {
    _checkInitialized();
    final fullKey = StorageUtils.generateFullKey(_config, key);
    try {
      final success = await _prefs!.remove(fullKey);
      if (success) {
        _mirror.remove(fullKey);
        _changeController.add(MapEntry(fullKey, null));
        _logger?.info('SharedPrefsStorage 删除键: $key');
      }
      return success;
    } catch (e) {
      _logger?.error('SharedPrefsStorage 删除键失败',
          tag: 'SharedPrefsStorage', error: e);
      return false;
    }
  }

  @override
  Future<bool> setAll(Map<String, dynamic> values) async {
    _checkInitialized();
    try {
      bool success = true;

      for (final entry in values.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is String) {
          success = success && await setString(key, value);
        } else if (value is int) {
          success = success && await setInt(key, value);
        } else if (value is double) {
          success = success && await setDouble(key, value);
        } else if (value is bool) {
          success = success && await setBool(key, value);
        } else if (value is List<String>) {
          success = success && await setStringList(key, value);
        } else {
          // 尝试将其他类型转为字符串
          success = success && await setString(key, value.toString());
        }
      }

      if (success) {
        _logger?.info('SharedPrefsStorage 批量设置完成: ${values.length}项');
      }

      return success;
    } catch (e) {
      _logger?.error('SharedPrefsStorage 批量设置失败',
          tag: 'SharedPrefsStorage', error: e);
      return false;
    }
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _checkInitialized();
    final fullKey = StorageUtils.generateFullKey(_config, key);
    try {
      final success = await _prefs!.setBool(fullKey, value);
      if (success) {
        _mirror[fullKey] = value;
        _changeController.add(MapEntry(fullKey, value));
        _logger?.info('SharedPrefsStorage 设置布尔值: $key = $value');
      }
      return success;
    } catch (e) {
      _logger?.error('SharedPrefsStorage 设置布尔值失败',
          tag: 'SharedPrefsStorage', error: e);
      return false;
    }
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _checkInitialized();
    final fullKey = StorageUtils.generateFullKey(_config, key);
    try {
      final success = await _prefs!.setDouble(fullKey, value);
      if (success) {
        _mirror[fullKey] = value;
        _changeController.add(MapEntry(fullKey, value));
        _logger?.info('SharedPrefsStorage 设置双精度值: $key = $value');
      }
      return success;
    } catch (e) {
      _logger?.error('SharedPrefsStorage 设置双精度值失败',
          tag: 'SharedPrefsStorage', error: e);
      return false;
    }
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _checkInitialized();
    final fullKey = StorageUtils.generateFullKey(_config, key);
    try {
      final success = await _prefs!.setInt(fullKey, value);
      if (success) {
        _mirror[fullKey] = value;
        _changeController.add(MapEntry(fullKey, value));
        _logger?.info('SharedPrefsStorage 设置整数值: $key = $value');
      }
      return success;
    } catch (e) {
      _logger?.error('SharedPrefsStorage 设置整数值失败',
          tag: 'SharedPrefsStorage', error: e);
      return false;
    }
  }

  @override
  Future<bool> setString(String key, String value) async {
    _checkInitialized();
    final fullKey = StorageUtils.generateFullKey(_config, key);
    try {
      // 如果启用加密，则加密值
      final valueToStore = StorageUtils.encryptString(_config, value) ?? value;

      final success = await _prefs!.setString(fullKey, valueToStore);
      if (success) {
        _mirror[fullKey] = valueToStore;
        _changeController.add(MapEntry(fullKey, value)); // 注意这里传递原始值
        _logger?.info('SharedPrefsStorage 设置字符串值: $key');
      }
      return success;
    } catch (e) {
      _logger?.error('SharedPrefsStorage 设置字符串值失败',
          tag: 'SharedPrefsStorage', error: e);
      return false;
    }
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _checkInitialized();
    final fullKey = StorageUtils.generateFullKey(_config, key);
    try {
      // 如果启用加密，则加密列表中的每一项
      List<String> listToStore = value;
      if (_config.enableEncryption && _config.encryptionKey != null) {
        listToStore = value
            .map((item) => StorageUtils.encryptString(_config, item) ?? item)
            .toList();
      }

      final success = await _prefs!.setStringList(fullKey, listToStore);
      if (success) {
        _mirror[fullKey] = listToStore;
        _changeController.add(MapEntry(fullKey, value)); // 注意这里传递原始值
        _logger?.info('设置字符串列表: $key, 大小: ${value.length}');
      }
      return success;
    } catch (e) {
      _logger?.error('SharedPrefsStorage 设置字符串列表失败',
          tag: 'SharedPrefsStorage', error: e);
      return false;
    }
  }

  @override
  Stream<MapEntry<String, dynamic>> watch(String key) {
    _checkInitialized();
    final fullKey = StorageUtils.generateFullKey(_config, key);
    return _changeController.stream.where((entry) => entry.key == fullKey);
  }

  /// 检查初始化状态
  void _checkInitialized() {
    if (!_initialized) {
      throw StateError('存储尚未初始化，请先调用init()方法');
    }
  }

  /// 从完整键名中提取原始键名
  String? _extractKeyFromFullKey(String fullKey) {
    final prefix = '${StorageUtils.generateKeyPrefix(_config)}_';
    if (fullKey.startsWith(prefix)) {
      return fullKey.substring(prefix.length);
    }
    return null;
  }

  /// 获取值类型
  _ValueType _getValueType(String fullKey) {
    if (!_prefs!.containsKey(fullKey)) {
      return _ValueType.unknown;
    }

    final dynamic value = _prefs!.get(fullKey);
    if (value is String) {
      return _ValueType.string;
    } else if (value is int) {
      return _ValueType.int;
    } else if (value is double) {
      return _ValueType.double;
    } else if (value is bool) {
      return _ValueType.bool;
    } else if (value is List<String>) {
      return _ValueType.stringList;
    }

    return _ValueType.unknown;
  }
}

/// 值类型枚举
enum _ValueType {
  string,
  int,
  double,
  bool,
  stringList,
  unknown,
}
