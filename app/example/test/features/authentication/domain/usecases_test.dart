import 'package:interfaces/core/result.dart';
import 'package:example/src/features/authentication/domain/entities/user_entity.dart';
import 'package:example/src/features/authentication/domain/failures/auth_failure.dart';
import 'package:example/src/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:example/src/features/authentication/domain/usecases/login_usecase.dart';
import 'package:example/src/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_doubles.dart';

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

        expect(result, isA<Failure<AuthFailure, UserEntity>>());
        expect(
          (result as Failure<AuthFailure, UserEntity>).error,
          const AuthFailure.emptyUsername(),
        );
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

        expect(result, isA<Failure<AuthFailure, UserEntity>>());
        expect(
          (result as Failure<AuthFailure, UserEntity>).error,
          const AuthFailure.emptyPassword(),
        );
        expect(repository.loginCallCount, 0);
      },
    );

    test(
      'returns invalid username failure before hitting repository',
      () async {
        final repository = FakeAuthRepository()
          ..onLogin = (username, password) async =>
              throw StateError('should not be called');
        final useCase = LoginUseCase(repository);

        final result = await useCase(usernameStr: 'ab', passwordStr: 'secret');

        expect(result, isA<Failure<AuthFailure, UserEntity>>());
        expect(
          (result as Failure<AuthFailure, UserEntity>).error,
          const AuthFailure.invalidUsername(
            'Username must be at least 3 characters',
          ),
        );
        expect(repository.loginCallCount, 0);
      },
    );

    test(
      'returns invalid password failure before hitting repository',
      () async {
        final repository = FakeAuthRepository()
          ..onLogin = (username, password) async =>
              throw StateError('should not be called');
        final useCase = LoginUseCase(repository);

        final result = await useCase(usernameStr: 'alice', passwordStr: '12');

        expect(result, isA<Failure<AuthFailure, UserEntity>>());
        expect(
          (result as Failure<AuthFailure, UserEntity>).error,
          const AuthFailure.invalidPassword(
            'Password must be at least 3 characters',
          ),
        );
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
        ..onLogin = (username, password) async => Success(user);
      final useCase = LoginUseCase(repository);

      final result = await useCase(usernameStr: 'alice', passwordStr: 'secret');

      expect(result, isA<Success<AuthFailure, UserEntity>>());
      expect(
        (result as Success<AuthFailure, UserEntity>).value,
        user,
      );
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
        ..onGetCurrentUser = () async => Success(user);
      final useCase = GetCurrentUserUseCase(repository);

      final result = await useCase();

      expect(result, isA<Success<AuthFailure, UserEntity?>>());
      expect(
        (result as Success<AuthFailure, UserEntity?>).value,
        user,
      );
    });
  });

  group('LogoutUseCase', () {
    test('returns repository result directly', () async {
      final repository = FakeAuthRepository()
        ..onLogout = () async => const Success(null);
      final useCase = LogoutUseCase(repository);

      final result = await useCase();

      expect(result, isA<Success<AuthFailure, void>>());
    });
  });
}
