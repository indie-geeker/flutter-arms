import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:interfaces/notification/i_notification_service.dart';

/// Console notification service for development and debugging.
///
/// Prints notification operations to the debug console.
/// Use this implementation during local development to observe
/// notification lifecycle without requiring a real push server.
class ConsoleNotificationService implements INotificationService {
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    _initialized = true;
    debugPrint('[Notification] Service initialized (console mode)');
  }

  @override
  Future<String?> getToken() async {
    debugPrint('[Notification] getToken() → console-fake-token');
    return _initialized ? 'console-fake-token' : null;
  }

  @override
  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;

  @override
  Future<void> subscribeToTopic(String topic) async {
    debugPrint('[Notification] Subscribed to topic: $topic');
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    debugPrint('[Notification] Unsubscribed from topic: $topic');
  }
}
