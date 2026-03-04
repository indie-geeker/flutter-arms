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

/// 应用路由 Provider
///
/// 将 ref 传给 AppRouter，使 AuthGuard 可读取全局认证状态。
/// keepAlive: true 确保整个应用生命周期内只有一个 AppRouter 实例。
@Riverpod(keepAlive: true)
AppRouter appRouter(Ref ref) => AppRouter(ref);

/// FlutterArms 示例应用
///
/// 使用 Clean Architecture 和模块化架构
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

      // 自定义加载界面
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

      // 应用主体
      child: const ProviderScope(child: _ArmsMainApp()),
    );
  }
}

/// 应用主体（在模块初始化后显示）
class _ArmsMainApp extends ConsumerWidget {
  const _ArmsMainApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 启动时恢复认证状态（仅执行一次）
    ref.watch(sessionRestoreProvider);

    final appRouter = ref.watch(appRouterProvider);
    final themeState = ref.watch(themeProvider);
    final localeState = ref.watch(localeProvider);

    // 加载中时显示简单的加载界面
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
