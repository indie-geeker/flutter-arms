import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/logger/log_level.dart';
import 'package:module_cache/module_cache.dart';
import 'package:module_logger/module_logger.dart';
import 'package:module_network/module_network.dart';
import 'package:module_storage/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../l10n/app_localizations.dart';
import '../presentation/notifiers/locale_notifier.dart';
import '../presentation/notifiers/theme_notifier.dart';
import '../presentation/state/locale_state.dart';
import '../router/app_router.dart';

part 'app.g.dart';

const bool kEnableFullStackProfile = bool.fromEnvironment(
  'ARMS_EXAMPLE_FULL_STACK',
  defaultValue: false,
);

/// 应用路由 Provider
///
/// 确保整个应用生命周期内只有一个 AppRouter 实例
@Riverpod(keepAlive: true)
AppRouter appRouter(Ref ref) => AppRouter();

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

List<IModule> buildBootstrapModules({
  bool enableFullStackProfile = kEnableFullStackProfile,
  bool enableSecureStorage = true,
}) {
  final modules = <IModule>[
    LoggerModule(initialLevel: LogLevel.debug),
    StorageModule(
      config: StorageConfig(enableSecureStorage: enableSecureStorage),
    ),
  ];

  if (enableFullStackProfile) {
    modules.addAll([
      CacheModule(),
      NetworkModule(
        baseUrl: 'https://api.example.com',
        enableCache: true,
        connectTimeout: const Duration(seconds: 30),
      ),
    ]);
  }

  return modules;
}

/// 应用主体（在模块初始化后显示）
class _ArmsMainApp extends ConsumerWidget {
  const _ArmsMainApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);
    final themeState = ref.watch(themeProvider);
    final localeState = ref.watch(localeProvider);

    // 加载中时显示简单的加载界面
    if (themeState.isLoading || localeState.isLoading) {
      return MaterialApp(
        onGenerateRoute: (settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) =>
                const Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        },
      );
    }

    return MaterialApp.router(
      title: 'FlutterArms Example',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(themeState.colorScheme.color),
      darkTheme: _buildDarkTheme(themeState.colorScheme.color),
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

  /// 浅色主题
  ThemeData _buildLightTheme(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// 深色主题
  ThemeData _buildDarkTheme(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
