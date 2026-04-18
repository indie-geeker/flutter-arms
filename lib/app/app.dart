import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/app/app_router.dart';
import 'package:flutter_arms/core/theme/app_theme.dart';
import 'package:flutter_arms/core/theme/theme_notifier.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 应用根组件。
class App extends ConsumerStatefulWidget {
  /// 构造函数。
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter(ref);
  }

  @override
  void dispose() {
    _router.authListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeNotifierProvider);
    final env = ref.watch(appEnvProvider);

    return TranslationProvider(
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: env.appName,
            debugShowCheckedModeBanner: false,
            locale: TranslationProvider.of(context).flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: AppTheme.light(seedColor: themeState.seedColor),
            darkTheme: AppTheme.dark(seedColor: themeState.seedColor),
            themeMode: themeState.mode,
            routerConfig: _router.config(
              reevaluateListenable: _router.authListenable,
            ),
          );
        },
      ),
    );
  }
}
