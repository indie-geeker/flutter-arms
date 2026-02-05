
import 'package:flutter/foundation.dart';
import 'package:interfaces/logger/log_output.dart';
import 'package:interfaces/logger/log_entity.dart';
import 'package:interfaces/logger/log_level.dart';
import '../formatters/simple_formatter.dart';

/// 控制台输出
/// 支持彩色日志（在支持的终端中）
class ConsoleOutput implements LogOutput {
  final SimpleFormatter _formatter = SimpleFormatter();
  final bool useColors;

  ConsoleOutput({this.useColors = true});

  @override
  void write(LogEntry entry) {
    final formatted = _formatter.format(entry);
    final output = useColors ? _colorize(formatted, entry.level) : formatted;
    debugPrint(output);
  }

  String _colorize(String text, LogLevel level) {
    const reset = '\x1B[0m';
    final color = switch (level) {
      LogLevel.debug => '\x1B[37m',    // 白色
      LogLevel.info => '\x1B[36m',     // 青色
      LogLevel.warning => '\x1B[33m',  // 黄色
      LogLevel.error => '\x1B[31m',    // 红色
      LogLevel.fatal => '\x1B[35m',    // 紫色
    };
    return '$color$text$reset';
  }
}