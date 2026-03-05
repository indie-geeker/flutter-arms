import 'package:interfaces/analytics/i_analytics.dart';

/// No-op analytics implementation.
///
/// Silently discards all analytics events.
/// Useful for tests or when analytics is disabled.
class NoopAnalyticsImpl implements IAnalytics {
  @override
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}

  @override
  Future<void> logScreenView(
    String screenName, {
    String? screenClass,
  }) async {}
}
