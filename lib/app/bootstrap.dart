import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_arms/app/app.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/app/app_screen_size_config.dart';
import 'package:flutter_arms/core/auth/auth_token_refresher.dart';
import 'package:flutter_arms/core/error/error_handler.dart';
import 'package:flutter_arms/core/logger/app_logger.dart';
import 'package:flutter_arms/core/logger/talker_app_logger.dart';
import 'package:flutter_arms/core/storage/hive_storage_initializer.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/auth/application/auth_token_refresher_impl.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_size_adapter/screen_size_adapter.dart';

/// 应用统一启动入口。
///
/// 启动流程：
/// 1. 通过 `runZonedGuarded` 捕获异步域内所有未处理异常。
/// 2. 绑定 `FlutterError.onError` / `PlatformDispatcher.onError` 到日志端口。
/// 3. 通过存储初始化器初始化存储，并恢复持久化语言偏好。
/// 4. 通过 `ProviderScope` 的 overrides 注入基础设施，避免使用静态单例。
Future<void> bootstrap({required AppFlavor flavor}) async {
  final env = AppEnv.fromFlavor(flavor);
  final logger = TalkerAppLogger.fromEnv(env);

  await runZonedGuarded<Future<void>>(
    () async {
      ScreenSizeWidgetsFlutterBinding.ensureInitialized(
        appScreenSizeAdapterConfig,
      );

      FlutterError.onError = (FlutterErrorDetails details) {
        logger.handle(details.exception, details.stack, 'FlutterError');
        FlutterError.presentError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        logger.handle(error, stack, 'PlatformDispatcher');
        return true;
      };

      final storage = await const HiveStorageInitializer().initialize();
      final storedLocale = storage.getLocale();
      if (storedLocale != null) {
        await LocaleSettings.setLocale(AppLocaleUtils.parse(storedLocale));
      }

      runApp(
        ProviderScope(
          overrides: [
            appEnvProvider.overrideWithValue(env),
            appLoggerProvider.overrideWithValue(logger),
            kvStorageProvider.overrideWithValue(storage),
            authTokenRefresherProvider.overrideWith(
              (ref) => ref.read(authRemoteTokenRefresherProvider),
            ),
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
