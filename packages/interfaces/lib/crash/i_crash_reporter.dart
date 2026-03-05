/// Crash reporter interface.
///
/// Provides an abstraction for error and crash reporting.
/// Implementations include Sentry, HTTP-based reporting, or local file logging.
abstract class ICrashReporter {
  /// Records an error with optional stack trace and context.
  ///
  /// [error] The error or exception that occurred.
  /// [stackTrace] Optional stack trace associated with the error.
  /// [context] Optional map of additional context/metadata.
  Future<void> recordError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  });

  /// Sets the user identifier for crash reports.
  ///
  /// [userId] The user ID, or null to clear.
  Future<void> setUserId(String? userId);

  /// Adds a breadcrumb log message for debugging.
  ///
  /// [message] A descriptive log message.
  /// [category] Optional category for the breadcrumb.
  Future<void> log(String message, {String? category});
}
