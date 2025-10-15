import 'model/log_entity.dart';

/// Abstract interface for log output destinations.
///
/// Implementations of this interface handle writing log entries to various
/// destinations such as console, files, memory, or remote servers.
///
/// Example usage:
/// ```dart
/// class CustomLogOutput implements LogOutput {
///   @override
///   void write(LogEntry entry) {
///     // Write log entry to custom destination
///     print('${entry.timestamp}: ${entry.message}');
///   }
/// }
/// ```
abstract class LogOutput {
  /// Writes a log entry to the output destination.
  ///
  /// This method should handle the log entry and write it to the appropriate
  /// destination. Implementations should handle errors gracefully and not throw
  /// exceptions as this could interrupt the logging flow.
  ///
  /// [entry] The log entry to write
  void write(LogEntry entry);
}
