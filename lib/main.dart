import 'package:flutter/material.dart';
import 'package:flutter_arms/core/errors/global_error_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/config/config_manager.dart';
import 'app/config/env_config.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  GlobalErrorHandler().init(
    onError: (error, stackTrace) {
      // 错误日志记录
      debugPrint('GlobalErrorHandler 未捕获异常: $error');
      debugPrint('堆栈: $stackTrace');
      // 错误上报服务（可选）
      // CrashReportingService.report(error, stackTrace);
    },
  );

  ConfigManager().initialize(Environment.dev);
  
  // 使用 ProviderScope 包装应用， SharedPreferences 下放到 splash 初始化
  runApp(
    const ProviderScope(
      child: ArmsApp(),
    ),
  );
}
