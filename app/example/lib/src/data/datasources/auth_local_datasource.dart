import 'dart:convert';

import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:interfaces/storage/i_secure_storage.dart';
import '../models/user_model.dart';

/// 认证本地数据源
///
/// 负责用户认证数据的本地持久化
/// 基于 FlutterArms 的 Storage 模块
class AuthLocalDataSource {
  final IKeyValueStorage _storage;
  final ISecureStorage? _secureStorage;

  static const String _currentUserKey = 'current_user';

  const AuthLocalDataSource(
    this._storage, {
    ISecureStorage? secureStorage,
  }) : _secureStorage = secureStorage;

  /// 保存当前用户
  Future<void> saveCurrentUser(UserModel user) async {
    if (_secureStorage != null) {
      await _secureStorage.write(
        _currentUserKey,
        jsonEncode(user.toJson()),
      );
      await _storage.remove(_currentUserKey);
      return;
    }

    await _storage.setJson(_currentUserKey, user.toJson());
  }

  /// 获取当前用户
  Future<UserModel?> getCurrentUser() async {
    if (_secureStorage != null) {
      final raw = await _secureStorage.read(_currentUserKey);
      if (raw != null) {
        try {
          final secureJson = jsonDecode(raw) as Map<String, dynamic>;
          return UserModel.fromJson(secureJson);
        } catch (_) {
          await clearCurrentUser();
          return null;
        }
      }
    }

    final json = await _storage.getJson(_currentUserKey);
    if (json == null) {
      return null;
    }

    try {
      return UserModel.fromJson(json);
    } catch (e) {
      // 数据损坏，清除并返回 null
      await clearCurrentUser();
      return null;
    }
  }

  /// 清除当前用户
  Future<void> clearCurrentUser() async {
    if (_secureStorage != null) {
      await _secureStorage.delete(_currentUserKey);
    }
    await _storage.remove(_currentUserKey);
  }

  /// 检查是否有已登录用户
  Future<bool> hasCurrentUser() async {
    if (_secureStorage != null) {
      final hasSecure = await _secureStorage.containsKey(_currentUserKey);
      if (hasSecure) {
        return true;
      }
    }
    return await _storage.containsKey(_currentUserKey);
  }
}
