import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app_router.dart';
import 'package:flutter_arms/features/auth/auth_providers.dart';
import 'package:flutter_arms/features/auth/presentation/view_models/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Profile Tab 页。
@RoutePage()
class ProfilePage extends ConsumerWidget {
  /// 构造函数。
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FilledButton.icon(
          onPressed: () async {
            await ref.read(logoutUseCaseProvider)();
            ref.read(authNotifierProvider.notifier).setAuthenticated(false);
            if (context.mounted) {
              context.router.replace(const LoginRoute());
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text('退出登录'),
        ),
      ),
    );
  }
}
