import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

/// Authentication failure type.
///
/// Encapsulates all possible authentication failure scenarios using Union Types pattern.
@freezed
class AuthFailure with _$AuthFailure {
  // Validation failures.
  const factory AuthFailure.emptyUsername() = _EmptyUsername;
  const factory AuthFailure.emptyPassword() = _EmptyPassword;
  const factory AuthFailure.invalidUsername(String message) = _InvalidUsername;
  const factory AuthFailure.invalidPassword(String message) = _InvalidPassword;

  // Business failures.
  const factory AuthFailure.invalidCredentials() = _InvalidCredentials;
  const factory AuthFailure.userNotFound() = _UserNotFound;

  // Infrastructure failures.
  const factory AuthFailure.storageError(String message) = _StorageError;
  const factory AuthFailure.networkError(String message) = _NetworkError;
  const factory AuthFailure.unexpected(String message) = _Unexpected;
}
