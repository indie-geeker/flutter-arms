import 'package:flutter_arms/app/app_env.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker/talker.dart';

part 'app_logger.g.dart';

/// 全局日志封装。
class AppLogger {
  AppLogger._();

  static final Talker _talker = Talker(
    settings: TalkerSettings(
      enabled: AppEnv.current.enableLog,
      useConsoleLogs: true,
    ),
  );

  /// 获取日志实例。
  static Talker get instance => _talker;
}

/// 日志依赖注入。
@Riverpod(keepAlive: true)
Talker appLogger(Ref ref) => AppLogger.instance;
