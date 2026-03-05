import 'package:flutter/foundation.dart';
import 'package:interfaces/logger/log_output.dart';
import 'package:interfaces/logger/log_entity.dart';
import 'package:interfaces/logger/log_level.dart';
import '../formatters/simple_formatter.dart';

/// Console output.
/// Supports colored logs (in compatible terminals).
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
      LogLevel.debug => '\x1B[37m', // White
      LogLevel.info => '\x1B[36m', // Cyan
      LogLevel.warning => '\x1B[33m', // Yellow
      LogLevel.error => '\x1B[31m', // Red
      LogLevel.fatal => '\x1B[35m', // Purple
    };
    return '$color$text$reset';
  }
}
