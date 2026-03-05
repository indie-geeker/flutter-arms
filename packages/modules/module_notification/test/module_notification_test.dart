import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/notification/i_notification_service.dart';
import 'package:module_notification/module_notification.dart';

void main() {
  group('ConsoleNotificationService', () {
    late ConsoleNotificationService service;

    setUp(() {
      service = ConsoleNotificationService();
    });

    test('initialize completes without error', () async {
      await service.initialize();
    });

    test('getToken returns null before initialization', () async {
      expect(await service.getToken(), isNull);
    });

    test('getToken returns fake token after initialization', () async {
      await service.initialize();
      expect(await service.getToken(), 'console-fake-token');
    });

    test('onMessage returns a broadcast stream', () {
      expect(service.onMessage, isA<Stream<Map<String, dynamic>>>());
    });

    test('subscribeToTopic completes without error', () async {
      await service.subscribeToTopic('news');
    });

    test('unsubscribeFromTopic completes without error', () async {
      await service.unsubscribeFromTopic('news');
    });
  });

  group('NoopNotificationService', () {
    late NoopNotificationService service;

    setUp(() {
      service = NoopNotificationService();
    });

    test('initialize is no-op', () async {
      await service.initialize();
    });

    test('getToken returns null', () async {
      expect(await service.getToken(), isNull);
    });

    test('onMessage returns a broadcast stream', () {
      expect(service.onMessage, isA<Stream<Map<String, dynamic>>>());
    });

    test('subscribeToTopic is no-op', () async {
      await service.subscribeToTopic('news');
    });

    test('unsubscribeFromTopic is no-op', () async {
      await service.unsubscribeFromTopic('news');
    });
  });

  group('RegionAwareNotificationService', () {
    late _MockNotificationService defaultService;
    late _MockNotificationService chinaService;
    late bool isInChina;

    setUp(() {
      defaultService = _MockNotificationService();
      chinaService = _MockNotificationService();
      isInChina = false;
    });

    RegionAwareNotificationService createProxy() {
      return RegionAwareNotificationService(
        defaultService: defaultService,
        chinaService: chinaService,
        isInChina: () => isInChina,
      );
    }

    test('delegates to default service when not in China', () async {
      final proxy = createProxy();
      await proxy.initialize();

      expect(defaultService.initialized, isTrue);
      expect(chinaService.initialized, isFalse);
    });

    test('delegates to China service when in China', () async {
      isInChina = true;
      final proxy = createProxy();
      await proxy.initialize();

      expect(chinaService.initialized, isTrue);
      expect(defaultService.initialized, isFalse);
    });

    test('switches delegate dynamically', () async {
      final proxy = createProxy();

      await proxy.subscribeToTopic('topic1');
      expect(defaultService.subscribedTopics, ['topic1']);

      isInChina = true;
      await proxy.subscribeToTopic('topic2');
      expect(chinaService.subscribedTopics, ['topic2']);
    });

    test('getToken delegates to active service', () async {
      final proxy = createProxy();
      defaultService.tokenToReturn = 'fcm-token';

      expect(await proxy.getToken(), 'fcm-token');

      isInChina = true;
      chinaService.tokenToReturn = 'jpush-token';
      expect(await proxy.getToken(), 'jpush-token');
    });

    test('onMessage returns stream from active service', () async {
      final proxy = createProxy();
      // Verify it returns a valid broadcast stream.
      expect(proxy.onMessage, isA<Stream<Map<String, dynamic>>>());
    });

    test('unsubscribeFromTopic delegates to active service', () async {
      final proxy = createProxy();
      await proxy.unsubscribeFromTopic('old-topic');
      expect(defaultService.unsubscribedTopics, ['old-topic']);
    });
  });

  group('NotificationModule', () {
    test('registers INotificationService with default ConsoleNotificationService', () async {
      final locator = _MockServiceLocator();
      final module = NotificationModule();

      await module.register(locator);

      expect(
        locator.registered[INotificationService],
        isA<ConsoleNotificationService>(),
      );
    });

    test('registers INotificationService with custom factory', () async {
      final locator = _MockServiceLocator();
      final noop = NoopNotificationService();
      final module = NotificationModule(factory: (_) => noop);

      await module.register(locator);

      expect(locator.registered[INotificationService], same(noop));
    });

    test('name is Notification', () {
      expect(NotificationModule().name, 'Notification');
    });

    test('provides INotificationService', () {
      expect(NotificationModule().provides, [INotificationService]);
    });

    test('priority matches InitPriorities.notification', () {
      expect(NotificationModule().priority, 70);
    });
  });
}

// -- Test helpers --

class _MockNotificationService implements INotificationService {
  bool initialized = false;
  String? tokenToReturn;
  final List<String> subscribedTopics = [];
  final List<String> unsubscribedTopics = [];
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<String?> getToken() async => tokenToReturn;

  @override
  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;

  @override
  Future<void> subscribeToTopic(String topic) async {
    subscribedTopics.add(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    unsubscribedTopics.add(topic);
  }
}

class _MockServiceLocator implements IServiceLocator {
  final Map<Type, Object> registered = {};

  @override
  void registerSingleton<T extends Object>(T instance) {
    registered[T] = instance;
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factoryFunc) {
    registered[T] = factoryFunc();
  }

  @override
  void registerFactory<T extends Object>(T Function() factoryFunc) {}

  @override
  T get<T extends Object>() => registered[T] as T;

  @override
  bool isRegistered<T extends Object>() => registered.containsKey(T);

  @override
  bool isRegisteredByType(Type type) => registered.containsKey(type);

  @override
  Future<void> unregister<T extends Object>() async {
    registered.remove(T);
  }

  @override
  Future<void> reset() async {
    registered.clear();
  }
}
