import 'dart:convert';
import 'package:interfaces/logger/log_entity.dart';

/// JSON formatter.
/// Suitable for structured log analysis and remote reporting.
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

    if (entry.extras != null && entry.extras!.isNotEmpty) {
      map['extras'] = entry.extras;
    }

    return jsonEncode(map);
  }
}
