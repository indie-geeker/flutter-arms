import 'package:flutter/foundation.dart';
import 'package:interfaces/analytics/i_analytics.dart';

/// Console analytics implementation.
///
/// Prints analytics events to the debug console.
/// Useful for development and debugging.
class ConsoleAnalyticsImpl implements IAnalytics {
  @override
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    debugPrint('[Analytics] Event: $name${parameters != null ? ' $parameters' : ''}');
  }

  @override
  Future<void> setUserId(String? userId) async {
    debugPrint('[Analytics] UserId: $userId');
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    debugPrint('[Analytics] UserProperty: $name = $value');
  }

  @override
  Future<void> logScreenView(
    String screenName, {
    String? screenClass,
  }) async {
    debugPrint('[Analytics] ScreenView: $screenName${screenClass != null ? ' ($screenClass)' : ''}');
  }
}
