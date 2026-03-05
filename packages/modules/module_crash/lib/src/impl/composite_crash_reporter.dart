import 'package:interfaces/crash/i_crash_reporter.dart';

/// Composite crash reporter.
///
/// Fans out crash reports to multiple [ICrashReporter] instances.
/// Useful for sending crashes to both Sentry and a custom HTTP endpoint,
/// or to both a file logger and a remote service.
///
/// Errors in individual reporters are isolated — one failing reporter
/// does not prevent others from receiving the report.
class CompositeCrashReporter implements ICrashReporter {
  final List<ICrashReporter> _reporters;

  /// Creates a composite crash reporter.
  ///
  /// [reporters] List of crash reporters to delegate to.
  CompositeCrashReporter(List<ICrashReporter> reporters)
    : _reporters = List.unmodifiable(reporters);

  @override
  Future<void> recordError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    for (final reporter in _reporters) {
      try {
        await reporter.recordError(error, stackTrace: stackTrace, context: context);
      } catch (_) {
        // Isolated failure — other reporters continue.
      }
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    for (final reporter in _reporters) {
      try {
        await reporter.setUserId(userId);
      } catch (_) {
        // Isolated failure.
      }
    }
  }

  @override
  Future<void> log(String message, {String? category}) async {
    for (final reporter in _reporters) {
      try {
        await reporter.log(message, category: category);
      } catch (_) {
        // Isolated failure.
      }
    }
  }
}
