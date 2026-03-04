import 'package:interfaces/core/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:example/src/features/authentication/di/auth_providers.dart';
import 'package:example/src/features/authentication/domain/usecases/login_usecase.dart';
import 'package:example/src/shared/auth/auth_shared.dart';
import '../state/login_state.dart';

part 'login_notifier.g.dart';

/// Login state manager
///
/// Uses Riverpod annotation for state management
@riverpod
class LoginNotifier extends _$LoginNotifier {
  late final LoginUseCase _loginUseCase;

  @override
  LoginState build() {
    // Get UseCase from dependency injection
    _loginUseCase = ref.read(loginUseCaseProvider);
    return const LoginState.initial();
  }

  /// Execute login
  Future<void> login(String username, String password) async {
    // 1. Set loading state
    state = const LoginState.loading();

    // 2. Call use case to execute login
    final result = await _loginUseCase(
      usernameStr: username,
      passwordStr: password,
    );

    // 3. Handle result
    switch (result) {
      case Failure(:final error):
        state = LoginState.failure(error);
      case Success(:final value):
        // Login success: write to global session state
        ref.read(authSessionProvider.notifier).setAuthenticated(
              userId: value.id,
              username: value.username,
            );
        state = const LoginState.success();
    }
  }

  /// Reset state
  void reset() {
    state = const LoginState.initial();
  }
}

/// Login form state manager
///
/// Manages form input and validation
@riverpod
class LoginFormNotifier extends _$LoginFormNotifier {
  @override
  LoginFormState build() {
    return const LoginFormState();
  }

  /// Update username
  void updateUsername(String username) {
    state = state.copyWith(username: username, usernameError: null);
  }

  /// Update password
  void updatePassword(String password) {
    state = state.copyWith(password: password, passwordError: null);
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  /// Clear all errors
  void clearErrors() {
    state = state.clearErrors();
  }

  /// Reset form
  void reset() {
    state = const LoginFormState();
  }
}
