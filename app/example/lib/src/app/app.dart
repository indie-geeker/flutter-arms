import 'package:core/core.dart';
import 'package:example/src/bootstrap/module_composition.dart';
import 'package:example/src/bootstrap/module_profile.dart';
import 'package:example/src/features/authentication/di/auth_providers.dart';
import 'package:example/src/shared/theme/app_theme_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../l10n/app_localizations.dart';
import 'package:example/src/features/settings/settings.dart';
import 'package:example/src/router/app_router.dart';

part 'app.g.dart';

/// Application router provider.
///
/// Passes ref to AppRouter so AuthGuard can read global auth state.
/// keepAlive: true ensures a single AppRouter instance for the entire app lifecycle.
@Riverpod(keepAlive: true)
AppRouter appRouter(Ref ref) => AppRouter(ref);

/// FlutterArms example application.
///
/// Built with Clean Architecture and modular architecture.
class ArmsApp extends StatelessWidget {
  const ArmsApp({
    super.key,
    this.enableFullStackProfile = kEnableFullStackProfile,
  });

  final bool enableFullStackProfile;

  @override
  Widget build(BuildContext context) {
    return AppInitializerWidget(
      modules: buildBootstrapModules(
        enableFullStackProfile: enableFullStackProfile,
      ),

      // Custom loading screen.
      loadingBuilder: (context, progress) {
        return MaterialApp(
          onGenerateRoute: (settings) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          progress.message,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${progress.current} / ${progress.total}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },

      // Application body.
      child: const ProviderScope(child: _ArmsMainApp()),
    );
  }
}

/// Application body (shown after module initialization).
class _ArmsMainApp extends ConsumerWidget {
  const _ArmsMainApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Restore auth state at startup (runs only once).
    ref.watch(sessionRestoreProvider);

    final appRouter = ref.watch(appRouterProvider);
    final themeState = ref.watch(themeProvider);
    final localeState = ref.watch(localeProvider);

    // Show simple loading screen while loading.
    if (themeState.isLoading || localeState.isLoading) {
      return MaterialApp(
        onGenerateRoute: (settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      );
    }

    return MaterialApp.router(
      title: 'FlutterArms Example',
      debugShowCheckedModeBanner: false,
      theme: AppThemeFactory.light(themeState.colorScheme),
      darkTheme: AppThemeFactory.dark(themeState.colorScheme),
      themeMode: themeState.themeMode,
      locale: localeState.appLocale.locale,
      supportedLocales: AppLocale.values.map((e) => e.locale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter.config(),
    );
  }
}
