import 'package:interfaces/storage/i_kv_storage.dart';

import '../models/user_model.dart';
import 'i_auth_local_datasource.dart';

/// Authentication local data source.
///
/// Handles local persistence of user authentication data.
/// Based on the FlutterArms Storage module.
class AuthLocalDataSource implements IAuthLocalDataSource {
  final IKeyValueStorage _storage;

  static const String _currentUserKey = 'current_user';
  const AuthLocalDataSource(this._storage);

  /// Saves the current user.
  @override
  Future<void> saveCurrentUser(UserModel user) async {
    await _storage.setJson(_currentUserKey, user.toJson());
  }

  /// Retrieves the current user.
  @override
  Future<UserModel?> getCurrentUser() async {
    final json = await _storage.getJson(_currentUserKey);
    if (json == null) {
      return null;
    }

    try {
      return UserModel.fromJson(json);
    } catch (e) {
      // Data corrupted, clear and return null.
      await clearCurrentUser();
      return null;
    }
  }

  /// Clears the current user.
  @override
  Future<void> clearCurrentUser() async {
    await _storage.remove(_currentUserKey);
  }

  /// Checks whether a user is logged in.
  @override
  Future<bool> hasCurrentUser() async {
    return await _storage.containsKey(_currentUserKey);
  }
}
