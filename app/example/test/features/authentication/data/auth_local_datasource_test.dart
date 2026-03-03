import 'package:example/src/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:example/src/features/authentication/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_doubles.dart';

void main() {
  UserModel buildUser() {
    return UserModel(
      id: 'u1',
      username: 'alice',
      loginTime: DateTime(2026, 1, 1, 9, 30),
    );
  }

  group('AuthLocalDataSource', () {
    test('stores user in key-value storage', () async {
      final storage = InMemoryKeyValueStorage();
      final dataSource = AuthLocalDataSource(storage);

      await dataSource.saveCurrentUser(buildUser());

      final json = await storage.getJson('current_user');
      expect(json, isNotNull);
      expect(json?['username'], 'alice');
    });

    test('loads current user from storage', () async {
      final storage = InMemoryKeyValueStorage();
      final user = buildUser();
      final dataSource = AuthLocalDataSource(storage);
      await storage.setJson('current_user', user.toJson());

      final loaded = await dataSource.getCurrentUser();

      expect(loaded, user);
    });

    test('clears corrupted key-value payload and returns null', () async {
      final storage = InMemoryKeyValueStorage();
      final dataSource = AuthLocalDataSource(storage);
      await storage.setJson('current_user', <String, dynamic>{'id': 'u1'});

      final loaded = await dataSource.getCurrentUser();

      expect(loaded, isNull);
      expect(await storage.containsKey('current_user'), isFalse);
    });

    test('hasCurrentUser checks key-value storage', () async {
      final storage = InMemoryKeyValueStorage();
      final dataSource = AuthLocalDataSource(storage);

      expect(await dataSource.hasCurrentUser(), isFalse);

      await storage.setJson('current_user', <String, dynamic>{'id': 'u1'});
      expect(await dataSource.hasCurrentUser(), isTrue);
    });

    test('clearCurrentUser removes key-value entries', () async {
      final storage = InMemoryKeyValueStorage();
      final dataSource = AuthLocalDataSource(storage);
      await storage.setJson('current_user', <String, dynamic>{'id': 'u1'});

      await dataSource.clearCurrentUser();

      expect(await storage.containsKey('current_user'), isFalse);
    });
  });
}
