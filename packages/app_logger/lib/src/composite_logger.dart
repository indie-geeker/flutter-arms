import 'package:app_interfaces/app_interfaces.dart';
import 'package:flutter/foundation.dart';

/// Composite logger implementation that delegates logging to multiple outputs.
///
/// This logger follows the composite pattern, allowing you to configure
/// multiple log outputs (console, file, memory, remote, etc.) and write
/// to all of them simultaneously. Each output is called independently,
/// so a failure in one output won't affect the others.
///
/// Example usage:
/// ```dart
/// // Create outputs
/// final consoleOutput = ConsoleLogOutput();
/// final memoryOutput = MemoryLogOutput(maxEntries: 500);
/// final fileOutput = FileLogOutput(storage);
///
/// // Create composite logger
/// final logger = CompositeLogger(
///   outputs: [consoleOutput, memoryOutput, fileOutput],
///   minLevel: LogLevel.debug,
///   enabled: true,
/// );
///
/// // Use the logger
/// logger.info('Application started');
/// logger.error('An error occurred', error: exception, stackTrace: stackTrace);
///
/// // Change log level at runtime
/// logger.setMinLevel(LogLevel.warning);
///
/// // Disable logging
/// logger.setEnabled(false);
/// ```
class CompositeLogger implements ILogger {
  /// List of outputs to write logs to
  final List<LogOutput> _outputs;

  /// Minimum log level to record
  LogLevel _minLevel;

  /// Whether logging is enabled
  bool _enabled;

  /// Creates a composite logger.
  ///
  /// [outputs] List of log outputs to write to. Each log entry will be
  /// sent to all outputs in the list.
  /// [minLevel] Minimum log level to record. Logs below this level will
  /// be ignored. Defaults to [LogLevel.debug].
  /// [enabled] Whether logging is enabled initially. Defaults to true.
  CompositeLogger({
    required List<LogOutput> outputs,
    LogLevel minLevel = LogLevel.debug,
    bool enabled = true,
  })  : _outputs = outputs,
        _minLevel = minLevel,
        _enabled = enabled;

  @override
  void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.debug,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.info,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.fatal,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Check if logging is enabled and level is sufficient
    if (!_enabled || level.index < _minLevel.index) {
      return;
    }

    // Create log entry
    final entry = LogEntry(
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    // Write to all outputs independently
    for (final output in _outputs) {
      try {
        output.write(entry);
      } catch (e, stackTrace) {
        // Log errors to debug console but don't throw
        // This prevents one failing output from breaking all logging
        debugPrint('CompositeLogger: Error writing to output $output: $e');
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  @override
  void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  @override
  LogLevel get minLevel => _minLevel;

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  @override
  bool get isEnabled => _enabled;

  @override
  List<LogEntry> getLogs({
    LogLevel? level,
    String? tag,
    int? limit,
  }) {
    // This method is deprecated in the new architecture
    // Users should access logs directly from MemoryLogOutput if needed
    throw UnsupportedError(
      'getLogs is not supported in CompositeLogger. '
      'Use MemoryLogOutput directly to retrieve logs.',
    );
  }

  @override
  void clearLogs() {
    // This method is deprecated in the new architecture
    // Users should access logs directly from MemoryLogOutput if needed
    throw UnsupportedError(
      'clearLogs is not supported in CompositeLogger. '
      'Use MemoryLogOutput directly to clear logs.',
    );
  }

  @override
  String exportLogs([String format = 'text']) {
    // This method is deprecated in the new architecture
    // Users should access logs directly from MemoryLogOutput if needed
    throw UnsupportedError(
      'exportLogs is not supported in CompositeLogger. '
      'Use MemoryLogOutput directly to export logs.',
    );
  }

  /// Gets the list of configured outputs.
  List<LogOutput> get outputs => List.unmodifiable(_outputs);

  /// Gets the number of configured outputs.
  int get outputCount => _outputs.length;
}
