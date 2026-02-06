import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:interfaces/logger/log_entity.dart';
import 'package:interfaces/logger/log_output.dart';

import '../formatters/simple_formatter.dart';
import 'disposable_log_output.dart';

/// 文件输出
/// 支持日志轮转（按文件大小）
class FileOutput implements LogOutput, DisposableLogOutput {
  final String filePath;
  final int maxFileSize; // bytes
  final SimpleFormatter _formatter = SimpleFormatter();
  IOSink? _sink;

  FileOutput(
    this.filePath, {
    this.maxFileSize = 10 * 1024 * 1024, // 默认 10MB
  });

  @override
  void write(LogEntry entry) async {
    try {
      await _ensureFile();
      final formatted = _formatter.format(entry);
      _sink?.writeln(formatted);
      await _sink?.flush();

      // 检查文件大小，必要时轮转
      await _rotateIfNeeded();
    } catch (e) {
      debugPrint('FileOutput error: $e');
    }
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

      // 重命名旧文件
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await file.rename('$filePath.$timestamp');
    }
  }

  @override
  Future<void> dispose() async {
    await _sink?.close();
    _sink = null;
  }
}
