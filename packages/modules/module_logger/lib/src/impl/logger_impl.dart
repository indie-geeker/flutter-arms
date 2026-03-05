import 'package:flutter/foundation.dart';
import 'package:interfaces/logger/i_logger.dart';
import 'package:interfaces/logger/log_level.dart';
import 'package:interfaces/logger/log_output.dart';
import 'package:interfaces/logger/log_entity.dart';

/// Default implementation of the ILogger interface.
class LoggerImpl implements ILogger {
  LogLevel _level = LogLevel.debug;
  final List<LogOutput> _outputs = [];

  @override
  void init({LogLevel level = LogLevel.debug, List<LogOutput>? outputs}) {
    _level = level;
    _outputs
      ..clear()
      ..addAll(outputs ?? const <LogOutput>[]);
  }

  @override
  void debug(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    log(
      LogLevel.debug,
      message,
      error: error,
      stackTrace: stackTrace,
      extras: extras,
    );
  }

  @override
  void info(String message, {Map<String, dynamic>? extras}) {
    log(LogLevel.info, message, extras: extras);
  }

  @override
  void warning(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    log(
      LogLevel.warning,
      message,
      error: error,
      stackTrace: stackTrace,
      extras: extras,
    );
  }

  @override
  void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    log(
      LogLevel.error,
      message,
      error: error,
      stackTrace: stackTrace,
      extras: extras,
    );
  }

  @override
  void fatal(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    log(
      LogLevel.fatal,
      message,
      error: error,
      stackTrace: stackTrace,
      extras: extras,
    );
  }

  @override
  void log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    // Level filtering.
    if (level < _level) return;

    final entry = LogEntry(
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
      extras: extras != null ? Map<String, dynamic>.from(extras) : null,
    );

    // Dispatch to all output sinks.
    for (final output in _outputs) {
      try {
        output.write(entry);
      } catch (e) {
        // Output errors should not affect the main flow.
        debugPrint('LogOutput error: $e');
      }
    }
  }

  @override
  void setLevel(LogLevel level) {
    _level = level;
  }

  @override
  void addOutput(LogOutput output) {
    _outputs.add(output);
  }
}
