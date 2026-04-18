import 'package:flutter_arms/app/app_env.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker/talker.dart';

part 'app_logger.g.dart';

/// 日志依赖注入。根据 `appEnvProvider.enableLog` 决定是否启用。
@Riverpod(keepAlive: true)
Talker appLogger(Ref ref) {
  final env = ref.watch(appEnvProvider);
  return Talker(
    settings: TalkerSettings(
      enabled: env.enableLog,
      useConsoleLogs: true,
    ),
  );
}
