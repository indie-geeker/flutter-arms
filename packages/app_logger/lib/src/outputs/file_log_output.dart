import 'dart:convert';

import 'package:app_interfaces/app_interfaces.dart';
import 'package:flutter/foundation.dart';

/// File output implementation that writes log entries to persistent storage.
///
/// This output writes logs in JSON format to a file using the provided
/// [IKeyValueStorage] implementation. It supports automatic file rotation when
/// the file size exceeds a specified limit.
///
/// Example usage:
/// ```dart
/// final storage = SharedPreferencesStorage(); // or any IKeyValueStorage implementation
/// final fileOutput = FileLogOutput(
///   storage,
///   fileName: 'app.log',
///   maxFileSize: 1024 * 1024, // 1MB
///   maxFiles: 3,
/// );
/// final logger = CompositeLogger(outputs: [fileOutput]);
/// logger.info('This will be written to a file');
/// ```
class FileLogOutput implements LogOutput {
  /// Storage implementation for persisting logs
  final IKeyValueStorage _storage;

  /// Base name of the log file
  final String fileName;

  /// Maximum file size in bytes before rotation
  final int maxFileSize;

  /// Maximum number of rotated files to keep
  final int maxFiles;

  /// Key for storing the current log file content
  late final String _currentLogKey;

  /// Key for storing the current file size
  late final String _sizeKey;

  /// Creates a file log output.
  ///
  /// [_storage] Storage implementation to use for persisting logs
  /// [fileName] Name of the log file. Defaults to 'app.log'
  /// [maxFileSize] Maximum size in bytes before file rotation. Defaults to 1MB
  /// [maxFiles] Maximum number of rotated files to keep. Defaults to 3
  FileLogOutput(
    this._storage, {
    this.fileName = 'app.log',
    this.maxFileSize = 1024 * 1024,
    this.maxFiles = 3,
  }) {
    _currentLogKey = 'log_file_$fileName';
    _sizeKey = 'log_file_size_$fileName';
  }

  @override
  void write(LogEntry entry) {
    // Fire and forget - don't block logging for async storage operations
    _writeAsync(entry).catchError((e) {
      debugPrint('FileLogOutput error: $e');
    });
  }

  /// Asynchronously writes a log entry to storage.
  Future<void> _writeAsync(LogEntry entry) async {
    try {
      // Convert entry to JSON
      final logJson = _entryToJson(entry);
      final logLine = '${jsonEncode(logJson)}\n';

      // Get current file content and size
      final currentContent = await _storage.getString(_currentLogKey) ?? '';
      final currentSize = await _storage.getInt(_sizeKey) ?? 0;

      // Check if rotation is needed
      if (currentSize + logLine.length > maxFileSize) {
        await _rotateFiles();
        // Start new file
        await _storage.setString(_currentLogKey, logLine);
        await _storage.setInt(_sizeKey, logLine.length);
      } else {
        // Append to current file
        await _storage.setString(_currentLogKey, currentContent + logLine);
        await _storage.setInt(_sizeKey, currentSize + logLine.length);
      }
    } catch (e) {
      // Log to debug console but don't throw
      debugPrint('FileLogOutput error: $e');
    }
  }

  /// Rotates log files.
  ///
  /// Shifts existing rotated files and creates a new active log file.
  /// Files are rotated as: app.log -> app.log.1 -> app.log.2 -> app.log.3
  Future<void> _rotateFiles() async {
    try {
      // Remove oldest file if we're at max
      final oldestKey = 'log_file_$fileName.$maxFiles';
      await _storage.remove(oldestKey);
      await _storage.remove('log_file_size_$fileName.$maxFiles');

      // Shift existing rotated files
      for (int i = maxFiles - 1; i >= 1; i--) {
        final currentKey = 'log_file_$fileName.$i';
        final nextKey = 'log_file_$fileName.${i + 1}';
        final currentSizeKey = 'log_file_size_$fileName.$i';
        final nextSizeKey = 'log_file_size_$fileName.${i + 1}';

        final content = await _storage.getString(currentKey);
        final size = await _storage.getInt(currentSizeKey);

        if (content != null) {
          await _storage.setString(nextKey, content);
          await _storage.setInt(nextSizeKey, size ?? 0);
          await _storage.remove(currentKey);
          await _storage.remove(currentSizeKey);
        }
      }

      // Move current log to .1
      final currentContent = await _storage.getString(_currentLogKey);
      final currentSize = await _storage.getInt(_sizeKey);

      if (currentContent != null) {
        await _storage.setString('log_file_$fileName.1', currentContent);
        await _storage.setInt('log_file_size_$fileName.1', currentSize ?? 0);
      }

      // Clear current log
      await _storage.remove(_currentLogKey);
      await _storage.remove(_sizeKey);
    } catch (e) {
      debugPrint('FileLogOutput rotation error: $e');
    }
  }

  /// Converts a log entry to a JSON map.
  Map<String, dynamic> _entryToJson(LogEntry entry) {
    final json = <String, dynamic>{
      'timestamp': entry.timestamp.toIso8601String(),
      'level': entry.level.toString().split('.').last,
      'message': entry.message,
    };

    if (entry.tag != null) {
      json['tag'] = entry.tag;
    }

    if (entry.error != null) {
      json['error'] = entry.error.toString();
    }

    if (entry.stackTrace != null) {
      json['stackTrace'] = entry.stackTrace.toString();
    }

    return json;
  }

  /// Retrieves the current log file content.
  ///
  /// Returns the content of the active log file, or an empty string if
  /// no logs exist.
  Future<String> getCurrentLogContent() async {
    return await _storage.getString(_currentLogKey) ?? '';
  }

  /// Retrieves a rotated log file content.
  ///
  /// [index] The rotation index (1 to maxFiles)
  ///
  /// Returns the content of the rotated log file, or an empty string if
  /// the file doesn't exist.
  Future<String> getRotatedLogContent(int index) async {
    if (index < 1 || index > maxFiles) {
      return '';
    }
    return await _storage.getString('log_file_$fileName.$index') ?? '';
  }

  /// Clears all log files including rotated ones.
  Future<void> clearLogs() async {
    try {
      // Clear current log
      await _storage.remove(_currentLogKey);
      await _storage.remove(_sizeKey);

      // Clear rotated logs
      for (int i = 1; i <= maxFiles; i++) {
        await _storage.remove('log_file_$fileName.$i');
        await _storage.remove('log_file_size_$fileName.$i');
      }
    } catch (e) {
      debugPrint('FileLogOutput clear error: $e');
    }
  }

  /// Gets the current file size in bytes.
  Future<int> getCurrentFileSize() async {
    return await _storage.getInt(_sizeKey) ?? 0;
  }
}
