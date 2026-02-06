import 'package:flutter/foundation.dart';
import 'package:interfaces/logger/log_entity.dart';
import 'package:interfaces/logger/log_output.dart';

import 'disposable_log_output.dart';

/// Web/非 IO 平台上的文件输出占位实现。
/// 保持 API 兼容，但不会落盘写文件。
class FileOutput implements LogOutput, DisposableLogOutput {
  static bool _warnedUnsupported = false;
  final String filePath;
  final int maxFileSize; // bytes

  FileOutput(
    this.filePath, {
    this.maxFileSize = 10 * 1024 * 1024,
  });

  @override
  void write(LogEntry entry) {
    if (_warnedUnsupported) return;
    _warnedUnsupported = true;
    debugPrint(
      'FileOutput is not supported on this platform. '
      'Skipped log write to "$filePath".',
    );
  }

  @override
  Future<void> dispose() async {}
}
