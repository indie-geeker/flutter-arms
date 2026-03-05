import 'package:interfaces/analytics/i_analytics.dart';

/// Region-aware analytics proxy.
///
/// Delegates analytics calls to different implementations based on the
/// user's region. Designed for scenarios where Firebase Analytics is
/// unavailable (e.g. mainland China) and an alternative SDK (e.g. Umeng)
/// is required.
///
/// Usage:
/// ```dart
/// final analytics = RegionAwareAnalytics(
///   defaultAnalytics: FirebaseAnalyticsImpl(),
///   chinaAnalytics: UmengAnalyticsImpl(),
///   isInChina: () => regionService.isInChina,
/// );
/// ```
class RegionAwareAnalytics implements IAnalytics {
  final IAnalytics _defaultAnalytics;
  final IAnalytics _chinaAnalytics;
  final bool Function() _isInChina;

  /// Creates a region-aware analytics proxy.
  ///
  /// [defaultAnalytics] Analytics used outside of China (e.g. Firebase).
  /// [chinaAnalytics] Analytics used in China (e.g. Umeng).
  /// [isInChina] Callback that returns true when the user is in China.
  RegionAwareAnalytics({
    required IAnalytics defaultAnalytics,
    required IAnalytics chinaAnalytics,
    required bool Function() isInChina,
  })  : _defaultAnalytics = defaultAnalytics,
        _chinaAnalytics = chinaAnalytics,
        _isInChina = isInChina;

  IAnalytics get _active => _isInChina() ? _chinaAnalytics : _defaultAnalytics;

  @override
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) {
    return _active.logEvent(name, parameters: parameters);
  }

  @override
  Future<void> setUserId(String? userId) {
    return _active.setUserId(userId);
  }

  @override
  Future<void> setUserProperty(String name, String? value) {
    return _active.setUserProperty(name, value);
  }

  @override
  Future<void> logScreenView(
    String screenName, {
    String? screenClass,
  }) {
    return _active.logScreenView(screenName, screenClass: screenClass);
  }
}
