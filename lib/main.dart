import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/config/config_manager.dart';
import 'app/config/env_config.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();


  ConfigManager().initialize(Environment.dev);
  
  // 使用 ProviderScope 包装应用，并提供 SharedPreferences 实例
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
