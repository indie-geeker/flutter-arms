import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/failures/auth_failure.dart';

part 'login_state.freezed.dart';

/// 登录状态
///
/// 使用 Union Types 模式表示登录过程的不同状态
@freezed
abstract class LoginState with _$LoginState {
  /// 初始状态
  const factory LoginState.initial() = _Initial;

  /// 加载中
  const factory LoginState.loading() = _Loading;

  /// 登录成功
  const factory LoginState.success() = _Success;

  /// 登录失败
  const factory LoginState.failure(AuthFailure failure) = _Failure;
}

/// 登录表单状态
///
/// 管理表单验证和错误信息
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

/// 扩展方法用于表单验证
extension LoginFormStateX on LoginFormState {
  /// 表单是否有效
  bool get isValid =>
      username.length >= 3 &&
      password.length >= 3 &&
      usernameError == null &&
      passwordError == null;

  /// 清除所有错误
  LoginFormState clearErrors() {
    return copyWith(usernameError: null, passwordError: null);
  }
}
