import 'package:flutter/material.dart';
import 'package:flutter_arms/core/logger/app_logger.dart';
import 'package:flutter_arms/core/logger/talker_app_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'dev_log_viewer.g.dart';

/// 开发日志面板入口。
abstract interface class DevLogViewer {
  /// 是否支持打开日志面板。
  bool get isAvailable;

  /// 打开日志面板。
  void open(BuildContext context);
}

/// Talker 日志面板入口。
final class TalkerDevLogViewer implements DevLogViewer {
  /// 构造函数。
  const TalkerDevLogViewer(this._logger);

  final TalkerAppLogger _logger;

  @override
  bool get isAvailable => true;

  @override
  void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TalkerScreen(talker: _logger.talker),
      ),
    );
  }
}

/// 不支持可视化日志时的空入口。
final class NoopDevLogViewer implements DevLogViewer {
  /// 构造函数。
  const NoopDevLogViewer();

  @override
  bool get isAvailable => false;

  @override
  void open(BuildContext context) {}
}

/// 开发日志面板入口依赖。
@Riverpod(keepAlive: true)
DevLogViewer devLogViewer(Ref ref) {
  final logger = ref.read(appLoggerProvider);
  if (logger case final TalkerAppLogger talkerLogger) {
    return TalkerDevLogViewer(talkerLogger);
  }

  return const NoopDevLogViewer();
}
