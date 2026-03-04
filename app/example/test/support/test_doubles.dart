import 'package:interfaces/core/result.dart';
import 'package:example/src/features/authentication/domain/entities/user_entity.dart';
import 'package:example/src/features/authentication/domain/failures/auth_failure.dart';
import 'package:example/src/features/authentication/domain/repositories/i_auth_repository.dart';
import 'package:interfaces/storage/i_kv_storage.dart';

class InMemoryKeyValueStorage implements IKeyValueStorage {
  final Map<String, Object?> _store = <String, Object?>{};

  @override
  Future<void> init() async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> clear() async => _store.clear();

  @override
  Future<int> getSize() async => _store.length;

  @override
  Future<void> setString(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<String?> getString(String key) async => _store[key] as String?;

  @override
  Future<void> setInt(String key, int value) async {
    _store[key] = value;
  }

  @override
  Future<int?> getInt(String key) async => _store[key] as int?;

  @override
  Future<void> setBool(String key, bool value) async {
    _store[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async => _store[key] as bool?;

  @override
  Future<void> setDouble(String key, double value) async {
    _store[key] = value;
  }

  @override
  Future<double?> getDouble(String key) async => _store[key] as double?;

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _store[key] = List<String>.from(value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final value = _store[key];
    if (value is List<String>) {
      return List<String>.from(value);
    }
    return null;
  }

  @override
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    _store[key] = Map<String, dynamic>.from(value);
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _store[key];
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async => _store.containsKey(key);

  @override
  Future<Set<String>> getKeys() async => _store.keys.toSet();
}

class ThrowingKeyValueStorage extends InMemoryKeyValueStorage {
  ThrowingKeyValueStorage({
    this.throwOnGetJson = false,
    this.throwOnSetJson = false,
    this.throwOnRemove = false,
    this.throwOnContainsKey = false,
  });

  bool throwOnGetJson;
  bool throwOnSetJson;
  bool throwOnRemove;
  bool throwOnContainsKey;

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    if (throwOnGetJson) {
      throw StateError('getJson failed');
    }
    return super.getJson(key);
  }

  @override
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    if (throwOnSetJson) {
      throw StateError('setJson failed');
    }
    await super.setJson(key, value);
  }

  @override
  Future<void> remove(String key) async {
    if (throwOnRemove) {
      throw StateError('remove failed');
    }
    await super.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    if (throwOnContainsKey) {
      throw StateError('containsKey failed');
    }
    return super.containsKey(key);
  }
}

class FakeAuthRepository implements IAuthRepository {
  Future<Result<AuthFailure, UserEntity>> Function(String, String)? onLogin;
  Future<Result<AuthFailure, void>> Function()? onLogout;
  Future<Result<AuthFailure, UserEntity?>> Function()? onGetCurrentUser;
  Future<bool> Function()? onIsLoggedIn;

  int loginCallCount = 0;
  String? lastUsername;
  String? lastPassword;

  @override
  Future<Result<AuthFailure, UserEntity>> login({
    required String username,
    required String password,
  }) async {
    loginCallCount += 1;
    lastUsername = username;
    lastPassword = password;
    final loginHandler = onLogin;
    if (loginHandler != null) {
      return loginHandler(username, password);
    }
    return const Failure(AuthFailure.unexpected('Missing login stub'));
  }

  @override
  Future<Result<AuthFailure, void>> logout() async {
    final logoutHandler = onLogout;
    if (logoutHandler != null) {
      return logoutHandler();
    }
    return const Success(null);
  }

  @override
  Future<Result<AuthFailure, UserEntity?>> getCurrentUser() async {
    final getCurrentUserHandler = onGetCurrentUser;
    if (getCurrentUserHandler != null) {
      return getCurrentUserHandler();
    }
    return const Success(null);
  }

  @override
  Future<bool> isLoggedIn() async {
    final isLoggedInHandler = onIsLoggedIn;
    if (isLoggedInHandler != null) {
      return isLoggedInHandler();
    }
    return false;
  }
}
