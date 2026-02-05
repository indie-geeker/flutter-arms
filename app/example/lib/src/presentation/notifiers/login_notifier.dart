import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../di/providers.dart';
import '../../domain/usecases/login_usecase.dart';
import '../state/login_state.dart';

part 'login_notifier.g.dart';

/// 登录状态管理器
///
/// 使用 Riverpod annotation 定义状态管理
@riverpod
class LoginNotifier extends _$LoginNotifier {
  late final LoginUseCase _loginUseCase;

  @override
  LoginState build() {
    // 从依赖注入获取 UseCase
    _loginUseCase = ref.read(loginUseCaseProvider);
    return const LoginState.initial();
  }

  /// 执行登录
  Future<void> login(String username, String password) async {
    // 1. 设置加载状态
    state = const LoginState.loading();

    // 2. 调用用例执行登录
    final result = await _loginUseCase(
      usernameStr: username,
      passwordStr: password,
    );

    // 3. 处理结果
    result.fold(
      (failure) => state = LoginState.failure(failure),
      (_) => state = const LoginState.success(),
    );
  }

  /// 重置状态
  void reset() {
    state = const LoginState.initial();
  }
}

/// 登录表单状态管理器
///
/// 管理表单输入和验证
@riverpod
class LoginFormNotifier extends _$LoginFormNotifier {
  @override
  LoginFormState build() {
    return const LoginFormState();
  }

  /// 更新用户名
  void updateUsername(String username) {
    state = state.copyWith(username: username);
    _validateUsername();
  }

  /// 更新密码
  void updatePassword(String password) {
    state = state.copyWith(password: password);
    _validatePassword();
  }

  /// 切换密码可见性
  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  /// 验证用户名
  void _validateUsername() {
    if (state.usernameError != null) {
      state = state.copyWith(usernameError: null);
    }
  }

  /// 验证密码
  void _validatePassword() {
    if (state.passwordError != null) {
      state = state.copyWith(passwordError: null);
    }
  }

  /// 清除所有错误
  void clearErrors() {
    state = state.clearErrors();
  }

  /// 重置表单
  void reset() {
    state = const LoginFormState();
  }
}
