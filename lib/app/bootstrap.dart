import 'package:flutter/widgets.dart';
import 'package:flutter_arms/app/app.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/error/error_handler.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 应用统一启动入口。
Future<void> bootstrap({required AppFlavor flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnv.setup(flavor: flavor);
  await HiveKvStorage.ensureInitialized();

  final storedLocale = HiveKvStorage.instance.getLocale();
  if (storedLocale != null) {
    await LocaleSettings.setLocale(AppLocaleUtils.parse(storedLocale));
  }

  runApp(
    const ProviderScope(
      observers: [AppProviderObserver()],
      child: App(),
    ),
  );
}
