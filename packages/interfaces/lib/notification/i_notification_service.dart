/// Notification service interface.
///
/// Provides an abstraction for push notification services.
/// Implementations include FCM (international), JPush (China),
/// UniPush (China), or console/noop for development and testing.
abstract class INotificationService {
  /// Initializes the notification service.
  ///
  /// Must be called before using any other method.
  /// Typically requests permissions and registers with the push server.
  Future<void> initialize();

  /// Returns the current push notification token.
  ///
  /// Returns null if the token is not yet available or the service
  /// has not been initialized.
  Future<String?> getToken();

  /// Stream of incoming notification payloads.
  ///
  /// Emits a map for each received notification containing the
  /// message data. Listeners should be set up before [initialize]
  /// to avoid missing early messages.
  Stream<Map<String, dynamic>> get onMessage;

  /// Subscribes to a notification topic.
  ///
  /// [topic] The topic name to subscribe to (e.g. 'news', 'promotions').
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribes from a notification topic.
  ///
  /// [topic] The topic name to unsubscribe from.
  Future<void> unsubscribeFromTopic(String topic);
}
