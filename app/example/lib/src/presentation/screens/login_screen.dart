import 'package:auto_route/auto_route.dart';
import 'package:example/src/domain/failures/auth_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../router/app_router.dart';
import '../notifiers/login_notifier.dart';
import '../state/login_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// 登录页面
@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final formNotifier = ref.read(loginFormProvider.notifier);
    final loginNotifier = ref.read(loginProvider.notifier);

    // 清除之前的错误
    formNotifier.clearErrors();

    // 执行登录
    loginNotifier.login(_usernameController.text, _passwordController.text);
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 监听登录状态
    ref.listen<LoginState>(loginProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        success: () {
          // 登录成功，导航到主页
          context.router.replace(const HomeRoute());
        },
        failure: (failure) {
          // 显示错误信息
          final message = failure.when(
            emptyUsername: () => 'Username is required',
            emptyPassword: () => 'Password is required',
            invalidUsername: (msg) => msg,
            invalidPassword: (msg) => msg,
            invalidCredentials: () => 'Invalid username or password',
            userNotFound: () => 'User not found',
            storageError: (msg) => 'Storage error: $msg',
            networkError: (msg) => 'Network error: $msg',
            unexpected: (msg) => 'Unexpected error: $msg',
          );
          _showErrorSnackBar(message);
        },
      );
    });

    final loginState = ref.watch(loginProvider);
    final formState = ref.watch(loginFormProvider);
    final isLoading = loginState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: LoginFormContent(
                usernameController: _usernameController,
                passwordController: _passwordController,
                formState: formState,
                isLoading: isLoading,
                onUsernameChanged: (value) {
                  ref
                      .read(loginFormProvider.notifier)
                      .updateUsername(value);
                },
                onPasswordChanged: (value) {
                  ref
                      .read(loginFormProvider.notifier)
                      .updatePassword(value);
                },
                onTogglePasswordVisibility: () {
                  ref
                      .read(loginFormProvider.notifier)
                      .togglePasswordVisibility();
                },
                onLogin: _handleLogin,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 登录表单内容
///
/// 分离为独立 class 以提高代码组织性
class LoginFormContent extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final LoginFormState formState;
  final bool isLoading;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onLogin;

  const LoginFormContent({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.formState,
    required this.isLoading,
    required this.onUsernameChanged,
    required this.onPasswordChanged,
    required this.onTogglePasswordVisibility,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Logo 区域
        const LoginHeader(),
        const SizedBox(height: 48),

        // 用户名输入框
        CustomTextField(
          controller: usernameController,
          label: 'Username',
          hint: 'Enter your username',
          prefixIcon: Icons.person_outline,
          errorText: formState.usernameError,
          onChanged: onUsernameChanged,
          enabled: !isLoading,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // 密码输入框
        CustomTextField(
          controller: passwordController,
          label: 'Password',
          hint: 'Enter your password',
          obscureText: !formState.obscurePassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: formState.obscurePassword
              ? Icons.visibility_off
              : Icons.visibility,
          onSuffixIconPressed: onTogglePasswordVisibility,
          errorText: formState.passwordError,
          onChanged: onPasswordChanged,
          enabled: !isLoading,
          textInputAction: TextInputAction.done,
          onEditingComplete: formState.isValid && !isLoading ? onLogin : null,
        ),
        const SizedBox(height: 32),

        // 登录按钮
        CustomButton(
          text: 'Login',
          onPressed: formState.isValid && !isLoading ? onLogin : null,
          isLoading: isLoading,
          icon: Icons.login,
        ),
      ],
    );
  }
}

/// 登录页面头部
///
/// 显示 Logo 和欢迎文字
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Logo/Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.shield_outlined,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),

        // 标题
        Text(
          'Welcome Back',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // 副标题
        Text(
          'Sign in to continue',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
