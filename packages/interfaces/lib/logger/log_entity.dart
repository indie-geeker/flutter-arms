import 'log_level.dart';

/// Log entry.
class LogEntry {
  /// Creates a log entry.
  ///
  /// [level] Log level
  /// [message] Log message
  /// [tag] Log tag
  /// [timestamp] Timestamp
  /// [error] Error object
  /// [stackTrace] Stack trace
  /// [extras] Structured log context
  LogEntry({
    required this.level,
    required this.message,
    this.tag,
    DateTime? timestamp,
    this.error,
    this.stackTrace,
    this.extras,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Log level.
  final LogLevel level;

  /// Log message.
  final String message;

  /// Log tag.
  final String? tag;

  /// Timestamp.
  final DateTime timestamp;

  /// Error object.
  final Object? error;

  /// Stack trace.
  final StackTrace? stackTrace;

  /// Structured log context.
  final Map<String, dynamic>? extras;

  @override
  String toString() => '[$level] ${tag != null ? '[$tag] ' : ''}$message';
}
