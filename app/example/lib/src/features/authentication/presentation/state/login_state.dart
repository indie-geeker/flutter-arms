import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/failures/auth_failure.dart';

part 'login_state.freezed.dart';

/// Login state.
///
/// Represents different login states using Union Types pattern.
@freezed
abstract class LoginState with _$LoginState {
  /// Initial state.
  const factory LoginState.initial() = _Initial;

  /// Loading.
  const factory LoginState.loading() = _Loading;

  /// Login succeeded.
  const factory LoginState.success() = _Success;

  /// Login failed.
  const factory LoginState.failure(AuthFailure failure) = _Failure;
}

/// Login form state.
///
/// Manages form validation and error messages.
@freezed
abstract class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default('') String username,
    @Default('') String password,
    @Default(false) bool obscurePassword,
    String? usernameError,
    String? passwordError,
  }) = _LoginFormState;
}

/// Extension methods for form validation.
extension LoginFormStateX on LoginFormState {
  /// Whether the form is valid.
  bool get isValid =>
      username.isNotEmpty &&
      password.isNotEmpty &&
      usernameError == null &&
      passwordError == null;

  /// Clears all errors.
  LoginFormState clearErrors() {
    return copyWith(usernameError: null, passwordError: null);
  }
}
