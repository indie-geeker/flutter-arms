import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:interfaces/logger/log_entity.dart';
import 'package:interfaces/logger/log_output.dart';

import '../formatters/simple_formatter.dart';
import 'disposable_log_output.dart';

/// File output.
/// Supports log rotation (by file size).
class FileOutput implements LogOutput, DisposableLogOutput {
  final String filePath;
  final int maxFileSize; // bytes
  final SimpleFormatter _formatter = SimpleFormatter();
  IOSink? _sink;
  final List<String> _pendingLines = <String>[];
  Future<void>? _drainFuture;
  bool _isDisposed = false;

  FileOutput(
    this.filePath, {
    this.maxFileSize = 10 * 1024 * 1024, // Default 10MB
  });

  @override
  void write(LogEntry entry) {
    if (_isDisposed) return;

    _pendingLines.add(_formatter.format(entry));
    _drainFuture ??= _drainQueue();
  }

  Future<void> _ensureFile() async {
    if (_sink != null) return;

    final file = File(filePath);
    await file.parent.create(recursive: true);
    _sink = file.openWrite(mode: FileMode.append);
  }

  Future<void> _rotateIfNeeded() async {
    final file = File(filePath);
    if (!await file.exists()) return;

    final size = await file.length();
    if (size > maxFileSize) {
      await _sink?.close();
      _sink = null;

      // Rename the old file.
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await file.rename('$filePath.$timestamp');
    }
  }

  Future<void> _drainQueue() async {
    try {
      while (_pendingLines.isNotEmpty) {
        final batch = List<String>.from(_pendingLines);
        _pendingLines.clear();

        await _ensureFile();
        for (final line in batch) {
          _sink?.writeln(line);
        }
        await _sink?.flush();
        await _rotateIfNeeded();
      }
    } catch (e) {
      debugPrint('FileOutput error: $e');
    } finally {
      _drainFuture = null;
      // Handle logs appended after drain finished.
      if (_pendingLines.isNotEmpty && !_isDisposed) {
        _drainFuture = _drainQueue();
      }
    }
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    await (_drainFuture ?? Future<void>.value());

    // Under extreme concurrency, dispose and drain may interleave;
    // do a final safety drain.
    if (_pendingLines.isNotEmpty) {
      await _drainQueue();
      await (_drainFuture ?? Future<void>.value());
    }

    await _sink?.flush();
    await _sink?.close();
    _sink = null;
  }
}
