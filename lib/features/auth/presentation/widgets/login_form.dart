import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app_router.dart';
import 'package:flutter_arms/core/error/failures.dart';
import 'package:flutter_arms/features/auth/presentation/view_models/login_view_model.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_arms/shared/dialogs/app_dialog.dart';
import 'package:flutter_arms/shared/widgets/app_button.dart';
import 'package:flutter_arms/shared/widgets/app_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 登录表单。
class LoginForm extends ConsumerWidget {
  /// 构造函数。
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;

    ref.listen(loginViewModelProvider, (previous, next) {
      if (next.error != null) {
        switch (next.error!) {
          case NetworkFailure(:final message):
            // 网络错误：可扩展为显示"重试"按钮
            AppDialog.showError(context, message);
          case AuthFailure(:final message):
            // 认证错误：可扩展为跳转重新登录
            AppDialog.showError(context, message);
          case UnknownFailure(:final message):
            AppDialog.showError(context, message);
        }
      }

      if (next.isLoginSuccess) {
        context.router.replace(const HomeRoute());
      }
    });

    final state = ref.watch(loginViewModelProvider);
    final notifier = ref.read(loginViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppTextField(
          label: t.auth.username,
          initialValue: state.username,
          onChanged: notifier.updateUsername,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: t.auth.password,
          initialValue: state.password,
          isPassword: true,
          onChanged: notifier.updatePassword,
        ),
        const SizedBox(height: 24),
        AppButton(
          text: t.auth.submit,
          isLoading: state.isLoading,
          onPressed: notifier.login,
        ),
      ],
    );
  }
}
