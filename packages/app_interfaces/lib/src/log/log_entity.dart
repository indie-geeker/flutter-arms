import 'log_level.dart';

/// 日志条目
class LogEntry {
  /// 创建日志条目
  ///
  /// [level] 日志级别
  /// [message] 日志消息
  /// [tag] 日志标签
  /// [timestamp] 时间戳
  /// [error] 错误对象
  /// [stackTrace] 堆栈跟踪
  LogEntry({
    required this.level,
    required this.message,
    this.tag,
    DateTime? timestamp,
    this.error,
    this.stackTrace,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 日志级别
  final LogLevel level;

  /// 日志消息
  final String message;

  /// 日志标签
  final String? tag;

  /// 时间戳
  final DateTime timestamp;

  /// 错误对象
  final Object? error;

  /// 堆栈跟踪
  final StackTrace? stackTrace;

  @override
  String toString() => '[$level] ${tag != null ? '[$tag] ' : ''}$message';
}