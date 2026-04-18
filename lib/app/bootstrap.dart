import 'package:flutter/widgets.dart';
import 'package:flutter_arms/app/app.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/error/error_handler.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 应用统一启动入口。
///
/// 启动流程：
/// 1. 确保 Flutter 绑定已初始化
/// 2. 初始化 Hive 存储（加密盒子）
/// 3. 根据持久化的语言偏好设置初始 locale
/// 4. 通过 `ProviderScope` 的 overrides 注入 `appEnvProvider`，避免使用静态单例
Future<void> bootstrap({required AppFlavor flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveKvStorage.ensureInitialized();

  final storedLocale = HiveKvStorage.instance.getLocale();
  if (storedLocale != null) {
    await LocaleSettings.setLocale(AppLocaleUtils.parse(storedLocale));
  }

  runApp(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(AppEnv.fromFlavor(flavor)),
      ],
      observers: const [AppProviderObserver()],
      child: const App(),
    ),
  );
}
