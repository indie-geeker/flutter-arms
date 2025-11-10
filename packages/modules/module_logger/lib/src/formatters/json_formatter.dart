
import 'dart:convert';
import 'package:interfaces/logger/log_entity.dart';

/// JSON 格式化器
/// 适用于结构化日志分析和远程上报
class JsonFormatter {
  String format(LogEntry entry) {
    final map = <String, dynamic>{
      'timestamp': entry.timestamp.toIso8601String(),
      'level': entry.level.name,
      'message': entry.message,
    };

    if (entry.tag != null) {
      map['tag'] = entry.tag;
    }

    if (entry.error != null) {
      map['error'] = entry.error.toString();
    }

    if (entry.stackTrace != null) {
      map['stackTrace'] = entry.stackTrace.toString();
    }

    return jsonEncode(map);
  }
}