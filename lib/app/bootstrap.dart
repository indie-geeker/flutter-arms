import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_arms/app/app.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/error/error_handler.dart';
import 'package:flutter_arms/core/logger/app_logger.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker/talker.dart';

/// 应用统一启动入口。
///
/// 启动流程：
/// 1. 通过 `runZonedGuarded` 捕获异步域内所有未处理异常。
/// 2. 绑定 `FlutterError.onError` / `PlatformDispatcher.onError` 到 Talker。
/// 3. 初始化 Hive 存储（加密盒子）与持久化的语言偏好。
/// 4. 通过 `ProviderScope` 的 overrides 注入 `appEnvProvider`，避免使用静态单例。
Future<void> bootstrap({required AppFlavor flavor}) async {
  final env = AppEnv.fromFlavor(flavor);
  final logger = Talker(
    settings: TalkerSettings(enabled: env.enableLog, useConsoleLogs: true),
  );

  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        logger.handle(details.exception, details.stack, 'FlutterError');
        FlutterError.presentError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        logger.handle(error, stack, 'PlatformDispatcher');
        return true;
      };

      await HiveKvStorage.ensureInitialized();
      final storedLocale = HiveKvStorage.instance.getLocale();
      if (storedLocale != null) {
        await LocaleSettings.setLocale(AppLocaleUtils.parse(storedLocale));
      }

      runApp(
        ProviderScope(
          overrides: [
            appEnvProvider.overrideWithValue(env),
            appLoggerProvider.overrideWithValue(logger),
          ],
          observers: const [AppProviderObserver()],
          child: const App(),
        ),
      );
    },
    (error, stack) {
      logger.handle(error, stack, 'ZoneUncaught');
    },
  );
}
