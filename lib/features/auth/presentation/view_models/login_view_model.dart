import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/auth/auth_providers.dart';
import 'package:flutter_arms/features/auth/presentation/states/login_state.dart';
import 'package:flutter_arms/features/auth/presentation/view_models/auth_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_view_model.g.dart';

/// 登录页面 ViewModel。
@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginState build() {
    return const LoginState();
  }

  /// 更新账号。
  void updateUsername(String value) {
    state = state.copyWith(username: value, errorMessage: null);
  }

  /// 更新密码。
  void updatePassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  /// 执行登录。
  Future<void> login() async {
    if (state.username.trim().isEmpty || state.password.trim().isEmpty) {
      state = state.copyWith(errorMessage: '请输入账号和密码');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isLoginSuccess: false,
    );

    final result = await ref.read(loginUseCaseProvider)(
      username: state.username,
      password: state.password,
    );

    switch (result) {
      case Success():
        ref.read(authNotifierProvider.notifier).setAuthenticated(true);
        state = state.copyWith(
          isLoading: false,
          isLoginSuccess: true,
          errorMessage: null,
        );
      case FailureResult(:final error):
        state = state.copyWith(
          isLoading: false,
          isLoginSuccess: false,
          errorMessage: error,
        );
    }
  }

  /// 执行登出。
  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider)();
    ref.read(authNotifierProvider.notifier).setAuthenticated(false);
    state = const LoginState();
  }
}
