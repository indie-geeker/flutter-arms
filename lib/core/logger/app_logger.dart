import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/logger/app_log.dart';
import 'package:flutter_arms/core/logger/talker_app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_logger.g.dart';

/// 日志依赖注入。根据 `appEnvProvider.enableLog` 决定是否启用。
@Riverpod(keepAlive: true)
AppLog appLogger(Ref ref) {
  final env = ref.watch(appEnvProvider);
  return TalkerAppLogger.fromEnv(env);
}
