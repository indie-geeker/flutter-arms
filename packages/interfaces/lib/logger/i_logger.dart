import 'log_level.dart';
import 'log_output.dart';

/// Logger interface.
///
/// Defines structured logging with configurable levels, multiple outputs,
/// and contextual `extras` for machine-readable metadata.
/// Implementations live in `packages/modules/module_logger`.
abstract class ILogger {
  /// Initializes the logging subsystem.
  void init({LogLevel level = LogLevel.debug, List<LogOutput>? outputs});

  /// Logs a debug-level message.
  void debug(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  });

  /// Logs an info-level message.
  void info(String message, {Map<String, dynamic>? extras});

  /// Logs a warning-level message.
  void warning(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  });

  /// Logs an error-level message.
  void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  });

  /// Logs a fatal-level message.
  void fatal(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  });

  /// Logs a message at a custom [level].
  void log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  });

  /// Changes the minimum log level at runtime.
  void setLevel(LogLevel level);

  /// Registers an additional log output sink.
  void addOutput(LogOutput output);
}
