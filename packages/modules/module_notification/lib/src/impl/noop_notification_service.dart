import 'dart:async';

import 'package:interfaces/notification/i_notification_service.dart';

/// No-op notification service for testing.
///
/// All methods are silent no-ops. Use this in test environments
/// where push notification side effects are undesirable.
class NoopNotificationService implements INotificationService {
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;

  @override
  Future<void> subscribeToTopic(String topic) async {}

  @override
  Future<void> unsubscribeFromTopic(String topic) async {}
}
