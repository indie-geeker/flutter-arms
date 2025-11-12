import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interfaces/logger/log_level.dart';
import 'package:module_logger/src/logger_module.dart';
import 'package:module_storage/src/storage_module.dart';
import '../router/app_router.dart';

/// FlutterArms 示例应用
///
/// 使用 Clean Architecture 和模块化架构
class ArmsApp extends StatelessWidget {
  const ArmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppInitializerWidget(
      modules: [
        // Logger Module - 最先初始化
        LoggerModule(initialLevel: LogLevel.debug),

        // Storage Module - 用于持久化
        StorageModule(),
      ],

      // 自定义加载界面
      loadingBuilder: (context, progress) {
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(progress.message, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '${progress.current} / ${progress.total}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      // 应用主体
      child: const ProviderScope(child: _ArmsMainApp()),
    );
  }
}

/// 应用主体（在模块初始化后显示）
class _ArmsMainApp extends StatelessWidget {
  const _ArmsMainApp();

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MaterialApp.router(
      title: 'FlutterArms Example',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter.config(),
    );
  }

  /// 浅色主题
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// 深色主题
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
