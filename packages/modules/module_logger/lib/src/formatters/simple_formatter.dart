import 'dart:convert';

import 'package:interfaces/logger/log_entity.dart';

/// Simple text formatter.
/// Format: [timestamp] [level] message
class SimpleFormatter {
  String format(LogEntry entry) {
    final timestamp = _formatTimestamp(entry.timestamp);
    final level = entry.level.name.toUpperCase().padRight(7);
    final buffer = StringBuffer('[$timestamp] [$level] ${entry.message}');

    if (entry.error != null) {
      buffer.write('\n  Error: ${entry.error}');
    }

    if (entry.stackTrace != null) {
      buffer.write('\n  StackTrace:\n${_formatStackTrace(entry.stackTrace!)}');
    }

    if (entry.extras != null && entry.extras!.isNotEmpty) {
      buffer.write('\n  Extras: ${jsonEncode(entry.extras)}');
    }

    return buffer.toString();
  }

  String _formatTimestamp(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}.'
        '${time.millisecond.toString().padLeft(3, '0')}';
  }

  String _formatStackTrace(StackTrace stackTrace) {
    return stackTrace
        .toString()
        .split('\n')
        .take(5) // Show only the first 5 lines.
        .map((line) => '    $line')
        .join('\n');
  }
}
