import 'package:flutter/foundation.dart';
import 'package:interfaces/logger/log_entity.dart';
import 'package:interfaces/logger/log_output.dart';

import 'disposable_log_output.dart';

/// Stub file output for Web/non-IO platforms.
/// Maintains API compatibility but does not write to disk.
class FileOutput implements LogOutput, DisposableLogOutput {
  static bool _warnedUnsupported = false;
  final String filePath;
  final int maxFileSize; // bytes

  FileOutput(this.filePath, {this.maxFileSize = 10 * 1024 * 1024});

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
