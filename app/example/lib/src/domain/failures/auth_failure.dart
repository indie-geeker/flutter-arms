import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_failure.freezed.dart';

/// 认证失败类型
///
/// 使用 Union Types 模式封装所有可能的认证失败场景
@freezed
class AuthFailure with _$AuthFailure {
  // 验证失败
  const factory AuthFailure.emptyUsername() = _EmptyUsername;
  const factory AuthFailure.emptyPassword() = _EmptyPassword;
  const factory AuthFailure.invalidUsername(String message) = _InvalidUsername;
  const factory AuthFailure.invalidPassword(String message) = _InvalidPassword;

  // 业务失败
  const factory AuthFailure.invalidCredentials() = _InvalidCredentials;
  const factory AuthFailure.userNotFound() = _UserNotFound;

  // 基础设施失败
  const factory AuthFailure.storageError(String message) = _StorageError;
  const factory AuthFailure.networkError(String message) = _NetworkError;
  const factory AuthFailure.unexpected(String message) = _Unexpected;
}
