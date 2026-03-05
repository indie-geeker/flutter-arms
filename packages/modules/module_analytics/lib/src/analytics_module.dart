import 'package:interfaces/analytics/i_analytics.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';

import 'impl/console_analytics.dart';

/// Analytics module.
///
/// Registers an [IAnalytics] implementation into the service locator.
/// By default, uses [ConsoleAnalyticsImpl] for development.
/// Override [createAnalytics] to provide a custom implementation
/// (e.g. Firebase, Umeng, or [RegionAwareAnalytics]).
class AnalyticsModule extends BaseModule {
  final IAnalytics Function(IServiceLocator locator)? _factory;

  /// Creates an analytics module.
  ///
  /// [factory] Optional factory to produce a custom [IAnalytics].
  /// Defaults to [ConsoleAnalyticsImpl] when omitted.
  AnalyticsModule({IAnalytics Function(IServiceLocator locator)? factory})
    : _factory = factory;

  @override
  String get name => 'Analytics';

  @override
  int get priority => InitPriorities.analytics;

  @override
  List<Type> get provides => [IAnalytics];

  @override
  Future<void> onRegister(IServiceLocator locator) async {
    final analytics = _factory?.call(locator) ?? ConsoleAnalyticsImpl();
    locator.registerSingleton<IAnalytics>(analytics);
  }
}
