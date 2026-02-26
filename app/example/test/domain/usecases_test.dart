import 'package:dartz/dartz.dart';
import 'package:example/src/domain/entities/user_entity.dart';
import 'package:example/src/domain/failures/auth_failure.dart';
import 'package:example/src/domain/usecases/get_current_user_usecase.dart';
import 'package:example/src/domain/usecases/login_usecase.dart';
import 'package:example/src/domain/usecases/logout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_doubles.dart';

void main() {
  group('LoginUseCase', () {
    test(
      'returns username validation failure before hitting repository',
      () async {
        final repository = FakeAuthRepository()
          ..onLogin = (username, password) async =>
              throw StateError('should not be called');
        final useCase = LoginUseCase(repository);

        final result = await useCase(usernameStr: '', passwordStr: 'secret');

        expect(result, left(const AuthFailure.emptyUsername()));
        expect(repository.loginCallCount, 0);
      },
    );

    test(
      'returns password validation failure before hitting repository',
      () async {
        final repository = FakeAuthRepository()
          ..onLogin = (username, password) async =>
              throw StateError('should not be called');
        final useCase = LoginUseCase(repository);

        final result = await useCase(usernameStr: 'alice', passwordStr: '');

        expect(result, left(const AuthFailure.emptyPassword()));
        expect(repository.loginCallCount, 0);
      },
    );

    test('delegates login to repository after validation', () async {
      final user = UserEntity(
        id: 'u1',
        username: 'alice',
        loginTime: DateTime(2026, 1, 1),
      );
      final repository = FakeAuthRepository()
        ..onLogin = (username, password) async => right(user);
      final useCase = LoginUseCase(repository);

      final result = await useCase(usernameStr: 'alice', passwordStr: 'secret');

      expect(result, right<AuthFailure, UserEntity>(user));
      expect(repository.loginCallCount, 1);
      expect(repository.lastUsername, 'alice');
      expect(repository.lastPassword, 'secret');
    });
  });

  group('GetCurrentUserUseCase', () {
    test('returns repository result directly', () async {
      final user = UserEntity(
        id: 'u2',
        username: 'bob',
        loginTime: DateTime(2026, 2, 2),
      );
      final repository = FakeAuthRepository()
        ..onGetCurrentUser = () async => right(user);
      final useCase = GetCurrentUserUseCase(repository);

      final result = await useCase();

      expect(result, right<AuthFailure, UserEntity?>(user));
    });
  });

  group('LogoutUseCase', () {
    test('returns repository result directly', () async {
      final repository = FakeAuthRepository()
        ..onLogout = () async => right(unit);
      final useCase = LogoutUseCase(repository);

      final result = await useCase();

      expect(result, right<AuthFailure, Unit>(unit));
    });
  });
}
