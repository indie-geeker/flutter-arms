import 'log_entity.dart';

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

  void write(LogEntry entry);
}
