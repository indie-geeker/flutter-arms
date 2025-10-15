import 'dart:collection';

import 'package:app_interfaces/app_interfaces.dart';

/// Memory output implementation that stores log entries in memory.
///
/// This output maintains a circular buffer of log entries with a configurable
/// maximum size. When the buffer is full, the oldest entries are removed to
/// make room for new ones.
///
/// Example usage:
/// ```dart
/// final memoryOutput = MemoryLogOutput(maxEntries: 500);
/// final logger = CompositeLogger(outputs: [memoryOutput]);
/// logger.info('This will be stored in memory');
///
/// // Later, retrieve logs
/// final recentLogs = memoryOutput.getLogs(limit: 10);
/// final errorLogs = memoryOutput.getLogs(level: LogLevel.error);
///
/// // Export logs in different formats
/// final textLogs = memoryOutput.exportLogs('text');
/// final jsonLogs = memoryOutput.exportLogs('json');
/// final csvLogs = memoryOutput.exportLogs('csv');
/// ```
class MemoryLogOutput implements LogOutput {
  /// Maximum number of log entries to store
  final int maxEntries;

  /// Internal queue storing log entries
  final Queue<LogEntry> _logEntries = Queue<LogEntry>();

  /// Creates a memory log output.
  ///
  /// [maxEntries] Maximum number of log entries to keep in memory.
  /// Defaults to 1000. When this limit is reached, the oldest entries
  /// are automatically removed.
  MemoryLogOutput({this.maxEntries = 1000});

  @override
  void write(LogEntry entry) {
    try {
      _logEntries.add(entry);

      // Remove oldest entries if we exceed the limit
      while (_logEntries.length > maxEntries) {
        _logEntries.removeFirst();
      }
    } catch (e) {
      // Silently handle errors to avoid interrupting logging
    }
  }

  /// Retrieves log entries with optional filtering.
  ///
  /// [level] Filter by specific log level
  /// [tag] Filter by specific tag
  /// [limit] Maximum number of entries to return (most recent)
  ///
  /// Returns a list of log entries matching the specified criteria.
  List<LogEntry> getLogs({
    LogLevel? level,
    String? tag,
    int? limit,
  }) {
    // Filter log entries
    final filteredLogs = _logEntries.where((entry) {
      if (level != null && entry.level != level) {
        return false;
      }
      if (tag != null && entry.tag != tag) {
        return false;
      }
      return true;
    }).toList();

    // Apply limit (return most recent entries)
    if (limit != null && limit > 0 && filteredLogs.length > limit) {
      return filteredLogs.sublist(filteredLogs.length - limit);
    }

    return filteredLogs;
  }

  /// Clears all stored log entries.
  void clearLogs() {
    _logEntries.clear();
  }

  /// Exports all stored logs in the specified format.
  ///
  /// Supported formats:
  /// - 'text': Human-readable text format with timestamps
  /// - 'json': JSON array format for programmatic parsing
  /// - 'csv': Comma-separated values with headers
  ///
  /// [format] The export format (text, json, or csv). Defaults to 'text'.
  ///
  /// Returns a string containing all logs in the specified format.
  String exportLogs([String format = 'text']) {
    switch (format.toLowerCase()) {
      case 'json':
        return _exportAsJson();
      case 'csv':
        return _exportAsCsv();
      case 'text':
      default:
        return _exportAsText();
    }
  }

  /// Exports logs as human-readable text.
  String _exportAsText() {
    final buffer = StringBuffer();
    for (final entry in _logEntries) {
      buffer.writeln('${entry.timestamp.toIso8601String()} '
          '[${entry.level.toString().split('.').last.toUpperCase()}] '
          '${entry.tag != null ? '[${entry.tag}] ' : ''}'
          '${entry.message}');

      if (entry.error != null) {
        buffer.writeln('  Error: ${entry.error}');
      }
      if (entry.stackTrace != null) {
        buffer.writeln('  StackTrace: ${entry.stackTrace}');
      }
    }
    return buffer.toString();
  }

  /// Exports logs as CSV format with headers.
  String _exportAsCsv() {
    final buffer = StringBuffer();
    // Add CSV header
    buffer.writeln('Timestamp,Level,Tag,Message,Error,StackTrace');

    // Add log entries
    for (final entry in _logEntries) {
      final timestamp = entry.timestamp.toIso8601String();
      final level = entry.level.toString().split('.').last.toUpperCase();
      final tag = entry.tag ?? '';
      final message = _escapeCsvField(entry.message);
      final error = _escapeCsvField(entry.error?.toString() ?? '');
      final stackTrace = _escapeCsvField(entry.stackTrace?.toString() ?? '');

      buffer.writeln('$timestamp,$level,$tag,$message,$error,$stackTrace');
    }

    return buffer.toString();
  }

  /// Escapes special characters in CSV fields.
  String _escapeCsvField(String field) {
    if (field.contains('"') ||
        field.contains(',') ||
        field.contains('\n') ||
        field.contains('\r')) {
      // Wrap field in quotes and escape internal quotes
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// Exports logs as JSON array.
  String _exportAsJson() {
    final buffer = StringBuffer();
    buffer.writeln('[');

    for (int i = 0; i < _logEntries.length; i++) {
      final entry = _logEntries.elementAt(i);

      buffer.writeln('  {');
      buffer.writeln('    "timestamp": "${entry.timestamp.toIso8601String()}",');
      buffer.writeln('    "level": "${entry.level.toString().split('.').last}",');
      if (entry.tag != null) {
        buffer.writeln('    "tag": "${entry.tag}",');
      }
      buffer.writeln('    "message": "${_escapeJsonString(entry.message)}"');
      if (entry.error != null) {
        buffer.writeln('    ,"error": "${_escapeJsonString(entry.error.toString())}"');
      }
      if (entry.stackTrace != null) {
        buffer.writeln('    ,"stackTrace": "${_escapeJsonString(entry.stackTrace.toString())}"');
      }
      buffer.writeln('  }${i < _logEntries.length - 1 ? ',' : ''}');
    }

    buffer.writeln(']');
    return buffer.toString();
  }

  /// Escapes special characters in JSON strings.
  String _escapeJsonString(String string) {
    return string
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  /// Gets the current number of stored entries.
  int get entryCount => _logEntries.length;
}
