import 'package:flutter_arms/core/error/failures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

/// 登录页面状态。
@freezed
abstract class LoginState with _$LoginState {
  /// 构造函数。
  const factory LoginState({
    @Default('') String username,
    @Default('') String password,
    @Default(false) bool isLoading,
    @Default(false) bool isLoginSuccess,
    Failure? error,
  }) = _LoginState;
}
