import 'package:flutter_test/flutter_test.dart';
import 'package:interfaces/analytics/i_analytics.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:module_analytics/module_analytics.dart';

void main() {
  group('ConsoleAnalyticsImpl', () {
    late ConsoleAnalyticsImpl analytics;

    setUp(() {
      analytics = ConsoleAnalyticsImpl();
    });

    test('logEvent completes without error', () async {
      await analytics.logEvent('test_event', parameters: {'key': 'value'});
    });

    test('setUserId completes without error', () async {
      await analytics.setUserId('user-123');
    });

    test('setUserProperty completes without error', () async {
      await analytics.setUserProperty('subscription', 'premium');
    });

    test('logScreenView completes without error', () async {
      await analytics.logScreenView('HomeScreen', screenClass: 'HomeScreen');
    });
  });

  group('NoopAnalyticsImpl', () {
    late NoopAnalyticsImpl analytics;

    setUp(() {
      analytics = NoopAnalyticsImpl();
    });

    test('logEvent is no-op', () async {
      await analytics.logEvent('test_event', parameters: {'key': 'value'});
    });

    test('setUserId is no-op', () async {
      await analytics.setUserId('user-123');
    });

    test('setUserProperty is no-op', () async {
      await analytics.setUserProperty('name', 'value');
    });

    test('logScreenView is no-op', () async {
      await analytics.logScreenView('TestScreen');
    });
  });

  group('RegionAwareAnalytics', () {
    late _MockAnalytics defaultAnalytics;
    late _MockAnalytics chinaAnalytics;
    late bool isInChina;

    setUp(() {
      defaultAnalytics = _MockAnalytics();
      chinaAnalytics = _MockAnalytics();
      isInChina = false;
    });

    RegionAwareAnalytics createProxy() {
      return RegionAwareAnalytics(
        defaultAnalytics: defaultAnalytics,
        chinaAnalytics: chinaAnalytics,
        isInChina: () => isInChina,
      );
    }

    test('delegates to default analytics when not in China', () async {
      final proxy = createProxy();
      await proxy.logEvent('test');

      expect(defaultAnalytics.events, ['test']);
      expect(chinaAnalytics.events, isEmpty);
    });

    test('delegates to China analytics when in China', () async {
      isInChina = true;
      final proxy = createProxy();
      await proxy.logEvent('test');

      expect(chinaAnalytics.events, ['test']);
      expect(defaultAnalytics.events, isEmpty);
    });

    test('switches delegate dynamically', () async {
      final proxy = createProxy();

      await proxy.logEvent('event1');
      expect(defaultAnalytics.events, ['event1']);

      isInChina = true;
      await proxy.logEvent('event2');
      expect(chinaAnalytics.events, ['event2']);
    });

    test('setUserId delegates to active analytics', () async {
      final proxy = createProxy();
      await proxy.setUserId('user-1');
      expect(defaultAnalytics.userIds, ['user-1']);

      isInChina = true;
      await proxy.setUserId('user-2');
      expect(chinaAnalytics.userIds, ['user-2']);
    });

    test('logScreenView delegates to active analytics', () async {
      final proxy = createProxy();
      await proxy.logScreenView('Home');
      expect(defaultAnalytics.screenViews, ['Home']);
    });
  });

  group('AnalyticsModule', () {
    test('registers IAnalytics with default ConsoleAnalyticsImpl', () async {
      final locator = _MockServiceLocator();
      final module = AnalyticsModule();

      await module.register(locator);

      expect(locator.registered[IAnalytics], isA<ConsoleAnalyticsImpl>());
    });

    test('registers IAnalytics with custom factory', () async {
      final locator = _MockServiceLocator();
      final noop = NoopAnalyticsImpl();
      final module = AnalyticsModule(factory: (_) => noop);

      await module.register(locator);

      expect(locator.registered[IAnalytics], same(noop));
    });

    test('name is Analytics', () {
      expect(AnalyticsModule().name, 'Analytics');
    });

    test('provides IAnalytics', () {
      expect(AnalyticsModule().provides, [IAnalytics]);
    });

    test('priority matches InitPriorities.analytics', () {
      expect(AnalyticsModule().priority, 60);
    });
  });
}

// -- Test helpers --

class _MockAnalytics implements IAnalytics {
  final List<String> events = [];
  final List<String?> userIds = [];
  final List<String> screenViews = [];

  @override
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    events.add(name);
  }

  @override
  Future<void> setUserId(String? userId) async {
    userIds.add(userId);
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {}

  @override
  Future<void> logScreenView(
    String screenName, {
    String? screenClass,
  }) async {
    screenViews.add(screenName);
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
