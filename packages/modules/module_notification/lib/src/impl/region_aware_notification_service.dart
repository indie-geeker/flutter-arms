import 'package:interfaces/notification/i_notification_service.dart';

/// Region-aware notification service proxy.
///
/// Delegates notification calls to different implementations based on the
/// user's region. Designed for scenarios where FCM is unavailable
/// (e.g. mainland China) and an alternative push service (e.g. JPush,
/// UniPush) is required.
///
/// Usage:
/// ```dart
/// final notifications = RegionAwareNotificationService(
///   defaultService: FcmNotificationService(),
///   chinaService: JPushNotificationService(),
///   isInChina: () => regionService.isInChina,
/// );
/// ```
class RegionAwareNotificationService implements INotificationService {
  final INotificationService _defaultService;
  final INotificationService _chinaService;
  final bool Function() _isInChina;

  /// Creates a region-aware notification service proxy.
  ///
  /// [defaultService] Notification service used outside of China (e.g. FCM).
  /// [chinaService] Notification service used in China (e.g. JPush, UniPush).
  /// [isInChina] Callback that returns true when the user is in China.
  RegionAwareNotificationService({
    required INotificationService defaultService,
    required INotificationService chinaService,
    required bool Function() isInChina,
  })  : _defaultService = defaultService,
        _chinaService = chinaService,
        _isInChina = isInChina;

  INotificationService get _active =>
      _isInChina() ? _chinaService : _defaultService;

  @override
  Future<void> initialize() => _active.initialize();

  @override
  Future<String?> getToken() => _active.getToken();

  @override
  Stream<Map<String, dynamic>> get onMessage => _active.onMessage;

  @override
  Future<void> subscribeToTopic(String topic) =>
      _active.subscribeToTopic(topic);

  @override
  Future<void> unsubscribeFromTopic(String topic) =>
      _active.unsubscribeFromTopic(topic);
}
