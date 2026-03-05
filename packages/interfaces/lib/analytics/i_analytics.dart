/// Analytics interface.
///
/// Provides an abstraction for event tracking and user analytics.
/// Implementations include Firebase Analytics, Umeng, or console logging
/// for development.
abstract class IAnalytics {
  /// Logs a custom analytics event.
  ///
  /// [name] Event name.
  /// [parameters] Optional event parameters.
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters});

  /// Sets the user identifier for analytics.
  ///
  /// [userId] The user ID, or null to clear.
  Future<void> setUserId(String? userId);

  /// Sets a user property.
  ///
  /// [name] Property name.
  /// [value] Property value, or null to clear.
  Future<void> setUserProperty(String name, String? value);

  /// Logs a screen view event.
  ///
  /// [screenName] Name of the screen.
  /// [screenClass] Optional screen class identifier.
  Future<void> logScreenView(String screenName, {String? screenClass});
}
