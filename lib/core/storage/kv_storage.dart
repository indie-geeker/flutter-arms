import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_arms/core/constants/app_constants.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kv_storage.g.dart';

/// 键值存储接口。
abstract class KvStorage {
  /// 读取访问令牌。
  String? getAccessToken();

  /// 写入访问令牌。
  Future<void> saveAccessToken(String token);

  /// 读取刷新令牌。
  String? getRefreshToken();

  /// 写入刷新令牌。
  Future<void> saveRefreshToken(String token);

  /// 清理令牌。
  Future<void> clearTokens();

  /// 读取用户数据。
  Map<String, dynamic>? getUserMap();

  /// 写入用户数据。
  Future<void> saveUserMap(Map<String, dynamic> value);

  /// 清理用户数据。
  Future<void> clearUser();

  /// 读取主题模式。
  ThemeMode getThemeMode();

  /// 写入主题模式。
  Future<void> setThemeMode(String mode);

  /// 读取主题种子色。
  Color getThemeSeedColor();

  /// 写入主题种子色。
  Future<void> setThemeSeedColor(Color color);

  /// 是否完成引导页。
  bool isOnboardingDone();

  /// 标记引导页完成。
  Future<void> markOnboardingDone();
}

/// Hive 存储实现。
class HiveKvStorage implements KvStorage {
  HiveKvStorage._();

  static final HiveKvStorage instance = HiveKvStorage._();

  static bool _initialized = false;

  static late Box<dynamic> _commonBox;
  static late Box<dynamic> _secureBox;

  /// 初始化 Hive 与加密盒子。
  static Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    await Hive.initFlutter();
    final keyBox = await Hive.openBox<dynamic>(AppConstants.keyBoxName);

    var key = keyBox.get(AppConstants.cipherKey);
    if (key is! List<int>) {
      key = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      await keyBox.put(AppConstants.cipherKey, key);
    }

    _commonBox = await Hive.openBox<dynamic>(AppConstants.commonBoxName);
    _secureBox = await Hive.openBox<dynamic>(
      AppConstants.secureBoxName,
      encryptionCipher: HiveAesCipher(Uint8List.fromList(key)),
    );

    _initialized = true;
  }

  @override
  String? getAccessToken() => _secureBox.get(AppConstants.accessTokenKey) as String?;

  @override
  Future<void> saveAccessToken(String token) async {
    await _secureBox.put(AppConstants.accessTokenKey, token);
  }

  @override
  String? getRefreshToken() => _secureBox.get(AppConstants.refreshTokenKey) as String?;

  @override
  Future<void> saveRefreshToken(String token) async {
    await _secureBox.put(AppConstants.refreshTokenKey, token);
  }

  @override
  Future<void> clearTokens() async {
    await _secureBox.delete(AppConstants.accessTokenKey);
    await _secureBox.delete(AppConstants.refreshTokenKey);
  }

  @override
  Map<String, dynamic>? getUserMap() {
    final raw = _commonBox.get(AppConstants.userKey) as String?;
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return null;
  }

  @override
  Future<void> saveUserMap(Map<String, dynamic> value) async {
    await _commonBox.put(AppConstants.userKey, jsonEncode(value));
  }

  @override
  Future<void> clearUser() async {
    await _commonBox.delete(AppConstants.userKey);
  }

  @override
  ThemeMode getThemeMode() {
    final raw = _commonBox.get(AppConstants.themeModeKey) as String?;
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  @override
  Future<void> setThemeMode(String mode) async {
    await _commonBox.put(AppConstants.themeModeKey, mode);
  }

  @override
  Color getThemeSeedColor() {
    final value = _commonBox.get(AppConstants.themeSeedColorKey) as int?;
    if (value == null) {
      return const Color(0xFF1D4ED8);
    }

    return Color(value);
  }

  @override
  Future<void> setThemeSeedColor(Color color) async {
    await _commonBox.put(AppConstants.themeSeedColorKey, color.toARGB32());
  }

  @override
  bool isOnboardingDone() =>
      (_commonBox.get(AppConstants.onboardingDoneKey) as bool?) ?? false;

  @override
  Future<void> markOnboardingDone() async {
    await _commonBox.put(AppConstants.onboardingDoneKey, true);
  }
}

/// 存储依赖注入。
@Riverpod(keepAlive: true)
KvStorage kvStorage(Ref ref) => HiveKvStorage.instance;
