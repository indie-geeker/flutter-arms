import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:example/l10n/app_localizations.dart';
import 'package:example/src/di/providers.dart';
import 'package:example/src/router/app_router.dart';
import '../notifiers/home_notifier.dart';

/// Home screen.
///
/// Main interface after login.
@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _handleLogout(WidgetRef ref) {
    ref.read(homeProvider.notifier).logout();
  }

  void _handleNetworkDemoTap(
    BuildContext context, {
    required String disabledMessage,
    required bool isAvailable,
  }) {
    if (isAvailable) {
      context.router.push(const NetworkDemoRoute());
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(disabledMessage),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final userState = ref.watch(homeProvider);
    final networkDemoAvailable = ref.watch(fullStackDemoAvailableProvider);

    // Listen to logout state.
    ref.listen(homeProvider, (previous, next) {
      next.whenOrNull(
        loggedOut: () {
          // Logout succeeded, return to login.
          context.router.replace(const LoginRoute());
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            tooltip: l10n.networkDemo,
            onPressed: () => _handleNetworkDemoTap(
              context,
              disabledMessage: l10n.fullStackProfileDisabled,
              isAvailable: networkDemoAvailable,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
            onPressed: () => context.router.push(const SettingsRoute()),
          ),
          IconButton(
            key: const Key('home_logout_button'),
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
            onPressed: () => _handleLogout(ref),
          ),
        ],
      ),
      body: Center(
        child: HomeContent(
          userState: userState,
          onLogout: () => _handleLogout(ref),
        ),
      ),
    );
  }
}

/// Home screen content.
///
/// Separated into a standalone class for better code organization.
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

/// User info card.
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
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User avatar.
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

            // Welcome text.
            Text(
              l10n.welcome,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Username.
            Text(
              username,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Login time.
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
                    l10n.loggedInAt(_formatTime(loginTime)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout button.
            ElevatedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: Text(l10n.logout),
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

/// Error display widget.
class ErrorDisplay extends StatelessWidget {
  final String message;

  const ErrorDisplay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          l10n.error,
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
