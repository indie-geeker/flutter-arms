
import 'package:interfaces/logger/log_entity.dart';

/// 简单的文本格式化器
/// 格式: [时间] [级别] 消息
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
        .take(5) // 只显示前5行
        .map((line) => '    $line')
        .join('\n');
  }
}