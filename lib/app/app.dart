import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'language/generated/l10n.dart';
import 'providers/locale_providers.dart';
import 'providers/theme_providers.dart';

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 Riverpod 获取主题配置
    final themeConfigAsync = ref.watch(themeConfigProvider);

    // 获取语言设置
    final localeAsync = ref.watch(localeNotifierProvider);

    // 处理加载状态
    return themeConfigAsync.when(
      data: (themeConfig) {
        return MaterialApp(
          title: '音乐应用',
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
          home: const HomePage(),
        );
      },
      loading: () => MaterialApp(
        title: '音乐应用',
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stackTrace) => MaterialApp(
        title: '音乐应用',
        home: Scaffold(
          body: Center(
            child: Text('加载主题时出错: $error'),
          ),
        ),
      ),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听主题模式状态
    final themeModeAsync = ref.watch(themeModeNotifierProvider);

    // 监听主题颜色状态
    final themeColorsAsync = ref.watch(themeColorsNotifierProvider);

    // 获取当前主题（异步）
    final currentThemeAsync = ref.watch(currentThemeProvider(context));

    // 处理加载状态
    return currentThemeAsync.when(
      data: (currentTheme) {
        final colors = currentTheme.colors;
        final textStyles = currentTheme.textStyles;

        // 获取控制器
        final themeModeNotifier = ref.watch(themeModeNotifierProvider.notifier);
        final themeColorsNotifier =
            ref.watch(themeColorsNotifierProvider.notifier);

        // 获取语言控制器
        final localeNotifier = ref.read(localeNotifierProvider.notifier);
// 获取当前语言名称
        final localeName = ref.watch(currentLocaleNameProvider);

        // 获取翻译
        final s = S.of(context);
        return Scaffold(
          appBar: AppBar(
            title:  Text(s.appName),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 使用主题颜色和文字样式
                Text(
                  '当前主题模式: ${_getThemeModeName(themeModeAsync.valueOrNull ?? ThemeMode.system)}',
                  style: textStyles.bodyText1,
                ),
                const SizedBox(height: 20),

                // 主题切换按钮
                ElevatedButton(
                  onPressed: () {
                    // 切换主题模式
                    themeModeNotifier.toggleThemeMode();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: colors.primary,
                  ),
                  child: Text('切换主题', style: textStyles.button),
                ),

                const SizedBox(height: 10),

                // 自定义主题颜色按钮
                ElevatedButton(
                  onPressed: () {
                    // 自定义主题颜色
                    themeColorsNotifier.updateColors(
                      primary: Colors.purple,
                      secondary: Colors.amber,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: colors.secondary,
                  ),
                  child: Text('自定义颜色', style: textStyles.button),
                ),

                const SizedBox(height: 10),

                // 重置主题颜色按钮
                ElevatedButton(
                  onPressed: () {
                    // 重置为默认颜色
                    themeColorsNotifier.resetToDefault();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: colors.error,
                  ),
                  child: Text('重置颜色', style: textStyles.button),
                ),

                // 切换到下一个语言
                ElevatedButton(
                  onPressed: () => localeNotifier.toggleNextLocale(),
                  child: Text('切换语言'),
                ),
                Text('当前语言: $localeName')
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('音乐应用'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: const Text('音乐应用'),
        ),
        body: Center(
          child: Text('加载主题时出错: $error'),
        ),
      ),
    );
  }

  // 获取主题模式名称
  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
      case ThemeMode.system:
        return '跟随系统';
    }
  }
}
