import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../router/app_router.dart';
import '../notifiers/home_notifier.dart';

/// 主页
///
/// 登录后的主要界面
@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _handleLogout(BuildContext context, WidgetRef ref) {
    ref.read(homeNotifierProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userState = ref.watch(homeNotifierProvider);

    // 监听登出状态
    ref.listen(homeNotifierProvider, (previous, next) {
      next.whenOrNull(
        loggedOut: () {
          // 登出成功，返回登录页
          context.router.replace(const LoginRoute());
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context, ref),
          ),
        ],
      ),
      body: Center(
        child: HomeContent(
          userState: userState,
          onLogout: () => _handleLogout(context, ref),
        ),
      ),
    );
  }
}

/// 主页内容
///
/// 分离为独立 class 以提高代码组织性
class HomeContent extends StatelessWidget {
  final HomeState userState;
  final VoidCallback onLogout;

  const HomeContent({
    super.key,
    required this.userState,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return userState.when(
      loading: () => const CircularProgressIndicator(),
      loaded: (user) => UserInfoCard(
        username: user.username,
        loginTime: user.loginTime,
        onLogout: onLogout,
      ),
      error: (message) => ErrorDisplay(message: message),
      loggedOut: () => const SizedBox.shrink(),
    );
  }
}

/// 用户信息卡片
class UserInfoCard extends StatelessWidget {
  final String username;
  final DateTime loginTime;
  final VoidCallback onLogout;

  const UserInfoCard({
    super.key,
    required this.username,
    required this.loginTime,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 用户头像
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 50,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // 欢迎文字
            Text(
              'Welcome!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 用户名
            Text(
              username,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // 登录时间
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Logged in at ${_formatTime(loginTime)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 登出按钮
            ElevatedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}

/// 错误显示组件
class ErrorDisplay extends StatelessWidget {
  final String message;

  const ErrorDisplay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          'Error',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
