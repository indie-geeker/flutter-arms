import 'package:interfaces/core/result.dart';
import 'package:example/src/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:example/src/features/authentication/data/models/user_model.dart';
import 'package:example/src/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:example/src/features/authentication/domain/failures/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_doubles.dart';

void main() {
  group('AuthRepositoryImpl', () {
    test(
      'does not re-validate username length and still persists user',
      () async {
        final storage = InMemoryKeyValueStorage();
        final dataSource = AuthLocalDataSource(storage);
        final repository = AuthRepositoryImpl(dataSource);

        final result = await repository.login(
          username: 'ab',
          password: 'secret',
        );
        final persisted = await dataSource.getCurrentUser();

        expect(result, isA<Success>());
        expect(
          (result as Success).value.username,
          'ab',
        );
        expect(persisted?.username, 'ab');
      },
    );

    test(
      'does not re-validate password length and still persists user',
      () async {
        final storage = InMemoryKeyValueStorage();
        final dataSource = AuthLocalDataSource(storage);
        final repository = AuthRepositoryImpl(dataSource);

        final result = await repository.login(
          username: 'alice',
          password: '12',
        );
        final persisted = await dataSource.getCurrentUser();

        expect(result, isA<Success>());
        expect(
          (result as Success).value.username,
          'alice',
        );
        expect(persisted?.username, 'alice');
      },
    );

    test('saves user and returns domain entity on successful login', () async {
      final storage = InMemoryKeyValueStorage();
      final dataSource = AuthLocalDataSource(storage);
      final repository = AuthRepositoryImpl(dataSource);

      final result = await repository.login(
        username: 'alice',
        password: 'secret',
      );
      final persisted = await dataSource.getCurrentUser();

      expect(result, isA<Success>());
      expect(
        (result as Success).value.username,
        'alice',
      );
      expect(persisted?.username, 'alice');
    });

    test('returns storageError when persistence throws during login', () async {
      final storage = ThrowingKeyValueStorage()..throwOnSetJson = true;
      final repository = AuthRepositoryImpl(AuthLocalDataSource(storage));

      final result = await repository.login(
        username: 'alice',
        password: 'secret',
      );

      expect(result, isA<Failure>());
      expect(
        (result as Failure).error,
        const AuthFailure.storageError('Bad state: setJson failed'),
      );
    });

    test('clears persisted user on logout', () async {
      final storage = InMemoryKeyValueStorage();
      final dataSource = AuthLocalDataSource(storage);
      final repository = AuthRepositoryImpl(dataSource);
      await dataSource.saveCurrentUser(
        UserModel(id: 'u1', username: 'alice', loginTime: DateTime(2026, 1, 1)),
      );

      final result = await repository.logout();

      expect(result, isA<Success>());
      expect(await dataSource.hasCurrentUser(), isFalse);
    });

    test('returns storageError when logout fails', () async {
      final storage = ThrowingKeyValueStorage()..throwOnRemove = true;
      final repository = AuthRepositoryImpl(AuthLocalDataSource(storage));

      final result = await repository.logout();

      expect(result, isA<Failure>());
      expect(
        (result as Failure).error,
        const AuthFailure.storageError('Bad state: remove failed'),
      );
    });

    test('maps current user model to domain entity', () async {
      final storage = InMemoryKeyValueStorage();
      final dataSource = AuthLocalDataSource(storage);
      final repository = AuthRepositoryImpl(dataSource);
      await dataSource.saveCurrentUser(
        UserModel(id: 'u2', username: 'bob', loginTime: DateTime(2026, 2, 2)),
      );

      final result = await repository.getCurrentUser();

      expect(result, isA<Success>());
      expect(
        (result as Success).value?.username,
        'bob',
      );
    });

    test('returns storageError when getCurrentUser fails', () async {
      final storage = ThrowingKeyValueStorage()..throwOnGetJson = true;
      final repository = AuthRepositoryImpl(AuthLocalDataSource(storage));

      final result = await repository.getCurrentUser();

      expect(result, isA<Failure>());
      expect(
        (result as Failure).error,
        const AuthFailure.storageError('Bad state: getJson failed'),
      );
    });

    test('returns false when isLoggedIn throws', () async {
      final storage = ThrowingKeyValueStorage()..throwOnContainsKey = true;
      final repository = AuthRepositoryImpl(AuthLocalDataSource(storage));

      final isLoggedIn = await repository.isLoggedIn();

      expect(isLoggedIn, isFalse);
    });
  });
}
