import 'package:interfaces/core/result.dart';
import 'package:example/src/features/authentication/di/auth_providers.dart';
import 'package:example/src/features/authentication/domain/entities/user_entity.dart';
import 'package:example/src/features/authentication/domain/failures/auth_failure.dart';
import 'package:example/src/features/authentication/domain/usecases/login_usecase.dart';
import 'package:example/src/features/authentication/presentation/notifiers/login_notifier.dart';
import 'package:example/src/features/authentication/presentation/state/login_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_doubles.dart';

void main() {
  group('LoginNotifier', () {
    test('emits loading then success when login succeeds', () async {
      final user = UserEntity(
        id: 'u1',
        username: 'alice',
        loginTime: DateTime(2026, 1, 1),
      );
      final repository = FakeAuthRepository()
        ..onLogin = (username, password) async => Success(user);
      final container = ProviderContainer(
        overrides: [
          loginUseCaseProvider.overrideWithValue(LoginUseCase(repository)),
        ],
      );
      addTearDown(container.dispose);

      final states = <LoginState>[];
      final subscription = container.listen<LoginState>(
        loginProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await container.read(loginProvider.notifier).login('alice', 'secret');

      expect(states.first, const LoginState.initial());
      expect(states, contains(const LoginState.loading()));
      expect(states.last, const LoginState.success());
      expect(repository.loginCallCount, 1);
    });

    test('emits failure when login usecase returns failure', () async {
      final repository = FakeAuthRepository()
        ..onLogin = (username, password) async =>
            const Failure(AuthFailure.invalidCredentials());
      final container = ProviderContainer(
        overrides: [
          loginUseCaseProvider.overrideWithValue(LoginUseCase(repository)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(loginProvider.notifier).login('alice', 'wrong-pass');

      expect(
        container.read(loginProvider),
        const LoginState.failure(AuthFailure.invalidCredentials()),
      );
    });

    test('reset moves state back to initial', () async {
      final repository = FakeAuthRepository()
        ..onLogin = (username, password) async =>
            const Failure(AuthFailure.invalidCredentials());
      final container = ProviderContainer(
        overrides: [
          loginUseCaseProvider.overrideWithValue(LoginUseCase(repository)),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(loginProvider.notifier);
      await notifier.login('alice', 'wrong-pass');
      notifier.reset();

      expect(container.read(loginProvider), const LoginState.initial());
    });
  });

  group('LoginFormNotifier', () {
    test('updates input fields and clears validation errors', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(loginFormProvider.notifier);
      notifier.state = const LoginFormState(
        username: '',
        password: '',
        usernameError: 'invalid username',
        passwordError: 'invalid password',
      );

      notifier.updateUsername('alice');
      notifier.updatePassword('secret');

      final state = container.read(loginFormProvider);
      expect(state.username, 'alice');
      expect(state.password, 'secret');
      expect(state.usernameError, isNull);
      expect(state.passwordError, isNull);
    });

    test('toggles password visibility and resets form state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(loginFormProvider.notifier);

      notifier.togglePasswordVisibility();
      expect(container.read(loginFormProvider).obscurePassword, isTrue);

      notifier.reset();
      expect(container.read(loginFormProvider), const LoginFormState());
    });

    test('clearErrors removes both usernameError and passwordError', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(loginFormProvider.notifier);
      notifier.state = const LoginFormState(
        username: 'alice',
        password: 'secret',
        usernameError: 'u-error',
        passwordError: 'p-error',
      );

      notifier.clearErrors();

      final state = container.read(loginFormProvider);
      expect(state.usernameError, isNull);
      expect(state.passwordError, isNull);
    });
  });
}
