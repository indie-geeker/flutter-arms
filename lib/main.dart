import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/config/config_manager.dart';
import 'app/config/env_config.dart';
import 'di/injection.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  ConfigManager().initialize(Environment.dev);
  
  // 使用 ProviderScope 包装应用，并提供 SharedPreferences 实例
  runApp(
    ProviderScope(
      overrides: [
        // 提供 SharedPreferences 实例
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}
