import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/config_manager.dart';
import 'config/env_config.dart';
import 'language/generated/l10n.dart';
import 'providers/locale_providers.dart';
import 'providers/theme_providers.dart';
import 'routes/app_router.dart';

class ArmsApp extends ConsumerWidget {
  const ArmsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    // 使用 Riverpod 获取主题配置
    final themeConfigAsync = ref.watch(themeConfigProvider);

    // 获取语言设置
    final localeAsync = ref.watch(localeNotifierProvider);

    EnvConfig envConfig = ConfigManager().getEnvConfig();


    // 处理加载状态
    return themeConfigAsync.when(
      data: (themeConfig) {
        return MaterialApp.router(
          title: envConfig.appName,
          // 国际化配置
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          locale: localeAsync.valueOrNull,
          // 使用主题配置
          theme: themeConfig.lightTheme.themeData,
          darkTheme: themeConfig.darkTheme.themeData,
          themeMode: themeConfig.themeMode,
          
          // 路由配置 - 使用全局定义的appRouter
          routerConfig: appRouter.config(),
        );
      },
      loading: () => MaterialApp(
        title: envConfig.appName,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stackTrace) => MaterialApp(
        title: envConfig.appName,
        home: Scaffold(
          body: Center(
            child: Text('加载主题时出错: $error'),
          ),
        ),
      ),
    );
  }
}
