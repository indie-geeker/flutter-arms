import 'dart:convert';

import 'package:example/src/data/datasources/auth_local_datasource.dart';
import 'package:example/src/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_doubles.dart';

void main() {
  UserModel buildUser() {
    return UserModel(
      id: 'u1',
      username: 'alice',
      loginTime: DateTime(2026, 1, 1, 9, 30),
    );
  }

  group('AuthLocalDataSource', () {
    test(
      'stores user in key-value storage when secure storage is absent',
      () async {
        final storage = InMemoryKeyValueStorage();
        final dataSource = AuthLocalDataSource(storage);

        await dataSource.saveCurrentUser(buildUser());

        final json = await storage.getJson('current_user');
        expect(json, isNotNull);
        expect(json?['username'], 'alice');
      },
    );

    test(
      'stores user in secure storage and removes plain data when available',
      () async {
        final storage = InMemoryKeyValueStorage();
        final secureStorage = InMemorySecureStorage();
        final dataSource = AuthLocalDataSource(
          storage,
          secureStorage: secureStorage,
        );
        await storage.setJson('current_user', <String, dynamic>{
          'legacy': true,
        });

        await dataSource.saveCurrentUser(buildUser());

        expect(
          await secureStorage.read('current_user'),
          contains('"username":"alice"'),
        );
        expect(await storage.containsKey('current_user'), isFalse);
      },
    );

    test('loads current user from secure storage first', () async {
      final storage = InMemoryKeyValueStorage();
      final secureStorage = InMemorySecureStorage();
      final user = buildUser();
      final dataSource = AuthLocalDataSource(
        storage,
        secureStorage: secureStorage,
      );
      await secureStorage.write('current_user', jsonEncode(user.toJson()));

      final loaded = await dataSource.getCurrentUser();

      expect(loaded, user);
    });

    test('clears corrupted secure payload and returns null', () async {
      final storage = InMemoryKeyValueStorage();
      final secureStorage = InMemorySecureStorage();
      final dataSource = AuthLocalDataSource(
        storage,
        secureStorage: secureStorage,
      );
      await secureStorage.write('current_user', '{invalid-json');
      await storage.setJson('current_user', <String, dynamic>{'legacy': true});

      final loaded = await dataSource.getCurrentUser();

      expect(loaded, isNull);
      expect(await secureStorage.containsKey('current_user'), isFalse);
      expect(await storage.containsKey('current_user'), isFalse);
    });

    test('clears corrupted key-value payload and returns null', () async {
      final storage = InMemoryKeyValueStorage();
      final dataSource = AuthLocalDataSource(storage);
      await storage.setJson('current_user', <String, dynamic>{'id': 'u1'});

      final loaded = await dataSource.getCurrentUser();

      expect(loaded, isNull);
      expect(await storage.containsKey('current_user'), isFalse);
    });

    test(
      'hasCurrentUser prefers secure storage then falls back to key-value',
      () async {
        final storage = InMemoryKeyValueStorage();
        final secureStorage = InMemorySecureStorage();
        final dataSource = AuthLocalDataSource(
          storage,
          secureStorage: secureStorage,
        );

        expect(await dataSource.hasCurrentUser(), isFalse);

        await storage.setJson('current_user', <String, dynamic>{'id': 'u1'});
        expect(await dataSource.hasCurrentUser(), isTrue);

        await secureStorage.write('current_user', '{"id":"secure"}');
        expect(await dataSource.hasCurrentUser(), isTrue);
      },
    );

    test('clearCurrentUser removes secure and key-value entries', () async {
      final storage = InMemoryKeyValueStorage();
      final secureStorage = InMemorySecureStorage();
      final dataSource = AuthLocalDataSource(
        storage,
        secureStorage: secureStorage,
      );
      await storage.setJson('current_user', <String, dynamic>{'id': 'u1'});
      await secureStorage.write('current_user', '{"id":"u1"}');

      await dataSource.clearCurrentUser();

      expect(await storage.containsKey('current_user'), isFalse);
      expect(await secureStorage.containsKey('current_user'), isFalse);
    });
  });
}
