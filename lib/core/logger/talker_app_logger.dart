import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/logger/app_log.dart';
import 'package:talker/talker.dart';

/// Talker 日志适配器。
final class TalkerAppLogger implements AppLog {
  /// 构造函数。
  TalkerAppLogger(this.talker);

  /// 根据环境创建 Talker 适配器。
  factory TalkerAppLogger.fromEnv(AppEnv env) {
    return TalkerAppLogger(
      Talker(
        settings: TalkerSettings(
          enabled: env.enableLog,
          useConsoleLogs: true,
        ),
      ),
    );
  }

  /// 底层 Talker 实例，仅供 core adapter 使用。
  final Talker talker;

  @override
  void debug(Object message, [Object? error, StackTrace? stackTrace]) {
    talker.debug(message, error, stackTrace);
  }

  @override
  void error(Object message, [Object? error, StackTrace? stackTrace]) {
    talker.error(message, error, stackTrace);
  }

  @override
  void handle(Object error, StackTrace? stackTrace, [String? context]) {
    talker.handle(error, stackTrace, context);
  }

  @override
  void info(Object message, [Object? error, StackTrace? stackTrace]) {
    talker.info(message, error, stackTrace);
  }

  @override
  void warning(Object message, [Object? error, StackTrace? stackTrace]) {
    talker.warning(message, error, stackTrace);
  }
}
