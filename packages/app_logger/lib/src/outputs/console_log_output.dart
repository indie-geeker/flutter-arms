import 'package:app_interfaces/app_interfaces.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Console output implementation that writes log entries to the debug console.
///
/// This output uses ANSI color codes to provide colored output in supporting
/// terminals and uses [debugPrint] for output to ensure compatibility with
/// Flutter's logging system.
///
/// Example usage:
/// ```dart
/// final consoleOutput = ConsoleLogOutput();
/// final logger = CompositeLogger(outputs: [consoleOutput]);
/// logger.info('This will appear in the console');
/// ```
class ConsoleLogOutput implements LogOutput {
  /// ANSI escape sequence color codes
  static const String _resetColor = '\u001b[0m';
  static const String _debugColor = '\u001b[37m'; // Gray
  static const String _infoColor = '\u001b[36m'; // Cyan
  static const String _warningColor = '\u001b[33m'; // Yellow
  static const String _errorColor = '\u001b[31m'; // Red
  static const String _fatalColor = '\u001b[35m'; // Magenta
  static const String _verboseColor = '\u001b[34m'; // Blue

  /// Whether to use colored output
  final bool useColors;

  /// Creates a console log output.
  ///
  /// [useColors] Whether to use ANSI color codes for colored output.
  /// Defaults to true.
  ConsoleLogOutput({this.useColors = true});

  @override
  void write(LogEntry entry) {
    try {
      final prefix = _getLevelPrefix(entry.level);
      final color = useColors ? _getLevelColor(entry.level) : '';
      final reset = useColors ? _resetColor : '';
      final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(entry.timestamp);
      final tagInfo = entry.tag != null ? '[${entry.tag}] ' : '';

      debugPrint('$timestamp $color$prefix$reset $tagInfo$color${entry.message}$reset');

      if (entry.error != null) {
        final errorColor = useColors ? _errorColor : '';
        debugPrint('${errorColor}Error: ${entry.error}$reset');
      }

      if (entry.stackTrace != null) {
        debugPrint('StackTrace: ${entry.stackTrace}');
      }
    } catch (e) {
      // Fallback to simple debugPrint if formatting fails
      debugPrint('ConsoleLogOutput error: $e');
      debugPrint('Original message: ${entry.message}');
    }
  }

  /// Gets the log level prefix string.
  String _getLevelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG]';
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.warning:
        return '[WARN]';
      case LogLevel.error:
        return '[ERROR]';
      case LogLevel.fatal:
        return '[FATAL]';
      case LogLevel.verbose:
        return '[VERBOSE]';
    }
  }

  /// Gets the ANSI color code for the log level.
  String _getLevelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return _debugColor;
      case LogLevel.info:
        return _infoColor;
      case LogLevel.warning:
        return _warningColor;
      case LogLevel.error:
        return _errorColor;
      case LogLevel.fatal:
        return _fatalColor;
      case LogLevel.verbose:
        return _verboseColor;
    }
  }
}
