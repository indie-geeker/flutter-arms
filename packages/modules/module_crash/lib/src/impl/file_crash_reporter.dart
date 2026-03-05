import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:interfaces/crash/i_crash_reporter.dart';

/// File-based crash reporter.
///
/// Writes crash reports as `.txt` files to a local directory.
/// Useful for offline crash collection or as a fallback reporter.
class FileCrashReporter implements ICrashReporter {
  final String _directory;
  String? _userId;

  /// Creates a file crash reporter.
  ///
  /// [directory] Directory to write crash files into.
  /// Defaults to the system temp directory.
  FileCrashReporter({String? directory})
    : _directory = directory ?? Directory.systemTemp.path;

  @override
  Future<void> recordError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    try {
      final timestamp = DateTime.now().toUtc().toIso8601String();
      final filename = 'crash_${timestamp.replaceAll(RegExp(r'[:\.]'), '-')}.txt';
      final file = File('$_directory/$filename');

      final buffer = StringBuffer()
        ..writeln('=== Crash Report ===')
        ..writeln('Timestamp: $timestamp')
        ..writeln('User: ${_userId ?? 'unknown'}')
        ..writeln()
        ..writeln('Error: $error')
        ..writeln();

      if (stackTrace != null) {
        buffer
          ..writeln('Stack Trace:')
          ..writeln(stackTrace);
      }

      if (context != null && context.isNotEmpty) {
        buffer.writeln('Context:');
        context.forEach((key, value) {
          buffer.writeln('  $key: $value');
        });
      }

      await file.writeAsString(buffer.toString());
      debugPrint('[CrashReporter] Wrote crash report to: ${file.path}');
    } catch (e) {
      // Crash reporter should not throw.
      debugPrint('[CrashReporter] Failed to write crash file: $e');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    _userId = userId;
  }

  @override
  Future<void> log(String message, {String? category}) async {
    debugPrint('[CrashReporter] Log: ${category != null ? '[$category] ' : ''}$message');
  }
}
