import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/logger/log_level.dart';
import 'package:interfaces/logger/log_output.dart';

/// Mock implementation of ILogger for testing
class MockLogger implements ILogger {
  final List<LogEntry> logs = [];

  @override
  void init({LogLevel level = LogLevel.debug, List<LogOutput>? outputs}) {
    // Mock init - do nothing
  }

  @override
  void debug(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? extras}) {
    logs.add(LogEntry('debug', message, error, stackTrace));
  }

  @override
  void info(String message, {Map<String, dynamic>? extras}) {
    logs.add(LogEntry('info', message, null, null));
  }

  @override
  void warning(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? extras}) {
    logs.add(LogEntry('warning', message, error, stackTrace));
  }

  @override
  void error(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? extras}) {
    logs.add(LogEntry('error', message, error, stackTrace));
  }

  @override
  void fatal(String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? extras}) {
    logs.add(LogEntry('fatal', message, error, stackTrace));
  }

  @override
  void log(LogLevel level, String message, {dynamic error, StackTrace? stackTrace, Map<String, dynamic>? extras}) {
    logs.add(LogEntry(level.toString(), message, error, stackTrace));
  }

  @override
  void setLevel(LogLevel level) {
    // Mock - do nothing
  }

  @override
  void addOutput(LogOutput output) {
    // Mock - do nothing
  }

  /// Test helper to check if a log exists
  bool hasLog(String level, String messageContains) {
    return logs.any((entry) =>
        entry.level == level && entry.message.contains(messageContains));
  }

  /// Test helper to clear logs
  void clearLogs() => logs.clear();
}

class LogEntry {
  final String level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  LogEntry(this.level, this.message, this.error, this.stackTrace);
}
