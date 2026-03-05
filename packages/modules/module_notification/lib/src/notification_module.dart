import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/notification/i_notification_service.dart';

import 'impl/console_notification_service.dart';

/// Notification module.
///
/// Registers an [INotificationService] implementation into the service locator.
/// By default, uses [ConsoleNotificationService] for development.
/// Override via the [factory] parameter to provide a custom implementation
/// (e.g. FCM, JPush, or [RegionAwareNotificationService]).
class NotificationModule extends BaseModule {
  final INotificationService Function(IServiceLocator locator)? _factory;

  /// Creates a notification module.
  ///
  /// [factory] Optional factory to produce a custom [INotificationService].
  /// Defaults to [ConsoleNotificationService] when omitted.
  NotificationModule({
    INotificationService Function(IServiceLocator locator)? factory,
  }) : _factory = factory;

  @override
  String get name => 'Notification';

  @override
  int get priority => InitPriorities.notification;

  @override
  List<Type> get provides => [INotificationService];

  @override
  Future<void> onRegister(IServiceLocator locator) async {
    final service =
        _factory?.call(locator) ?? ConsoleNotificationService();
    locator.registerSingleton<INotificationService>(service);
  }
}
