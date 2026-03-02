import 'package:core/src/di/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';

/// Integration test: full module lifecycle with dependency chain.
///
/// Verifies that Logger → Storage → Cache → Network initializes in the
/// correct dependency order and disposes in reverse order, using a mock
/// service locator for complete test isolation.
void main() {
  group('Module lifecycle integration', () {
    late MockServiceLocator locator;
    late ModuleRegistry registry;

    setUp(() {
      locator = MockServiceLocator();
      registry = ModuleRegistry(locator: locator);
    });

    tearDown(() async {
      await registry.disposeAll();
    });

    test('full 4-module chain initializes in dependency order', () async {
      final events = <String>[];

      final logger = _TrackingModule(
        'Logger',
        priority: 0,
        dependencies: [],
        provides: [_LoggerService],
        events: events,
      );
      final storage = _TrackingModule(
        'Storage',
        priority: 10,
        dependencies: [_LoggerService],
        provides: [_StorageService],
        events: events,
      );
      final cache = _TrackingModule(
        'Cache',
        priority: 30,
        dependencies: [_LoggerService, _StorageService],
        provides: [_CacheService],
        events: events,
      );
      final network = _TrackingModule(
        'Network',
        priority: 40,
        dependencies: [_LoggerService, _CacheService],
        provides: [_NetworkService],
        events: events,
      );

      // Register in reverse order to verify topological sort works
      registry.registerModules([network, cache, storage, logger]);
      await registry.initializeAll();

      // Must initialize in dependency order regardless of registration order
      expect(events, [
        'Logger:register',
        'Logger:init',
        'Storage:register',
        'Storage:init',
        'Cache:register',
        'Cache:init',
        'Network:register',
        'Network:init',
      ]);
    });

    test('full chain disposes in reverse order', () async {
      final events = <String>[];

      final logger = _TrackingModule(
        'Logger',
        priority: 0,
        dependencies: [],
        provides: [_LoggerService],
        events: events,
      );
      final storage = _TrackingModule(
        'Storage',
        priority: 10,
        dependencies: [_LoggerService],
        provides: [_StorageService],
        events: events,
      );
      final cache = _TrackingModule(
        'Cache',
        priority: 30,
        dependencies: [_LoggerService, _StorageService],
        provides: [_CacheService],
        events: events,
      );

      registry.registerModules([logger, storage, cache]);
      await registry.initializeAll();

      events.clear();
      await registry.disposeAll();

      expect(events, ['Cache:dispose', 'Storage:dispose', 'Logger:dispose']);
    });

    test('progress callback reports correct counts', () async {
      final progress = <String>[];

      final logger = _TrackingModule(
        'Logger',
        priority: 0,
        dependencies: [],
        provides: [_LoggerService],
      );
      final storage = _TrackingModule(
        'Storage',
        priority: 10,
        dependencies: [_LoggerService],
        provides: [_StorageService],
      );

      registry.registerModules([logger, storage]);
      await registry.initializeAllWithProgress((module, current, total) {
        progress.add('${module.name}:$current/$total');
      });

      expect(progress, ['Logger:1/2', 'Storage:2/2']);
    });
  });

  group('Error recovery integration', () {
    late MockServiceLocator locator;
    late ModuleRegistry registry;

    setUp(() {
      locator = MockServiceLocator();
      registry = ModuleRegistry(locator: locator);
    });

    tearDown(() async {
      await locator.reset();
    });

    test('init failure rolls back previously initialized modules', () async {
      final events = <String>[];

      final logger = _TrackingModule(
        'Logger',
        priority: 0,
        dependencies: [],
        provides: [_LoggerService],
        events: events,
      );
      final failingStorage = _TrackingModule(
        'Storage',
        priority: 10,
        dependencies: [_LoggerService],
        provides: [_StorageService],
        events: events,
        failOnInit: true,
      );

      registry.registerModules([logger, failingStorage]);

      expect(() => registry.initializeAll(), throwsA(isA<StateError>()));

      // Logger should have been rolled back (disposed)
      await pumpEventQueue();
      expect(
        events,
        containsAllInOrder([
          'Logger:register',
          'Logger:init',
          'Storage:register',
          'Logger:dispose',
        ]),
      );
    });

    test(
      'register failure rolls back previously initialized modules',
      () async {
        final events = <String>[];

        final logger = _TrackingModule(
          'Logger',
          priority: 0,
          dependencies: [],
          provides: [_LoggerService],
          events: events,
        );
        final failingStorage = _TrackingModule(
          'Storage',
          priority: 10,
          dependencies: [_LoggerService],
          provides: [_StorageService],
          events: events,
          failOnRegister: true,
        );

        registry.registerModules([logger, failingStorage]);

        expect(() => registry.initializeAll(), throwsA(isA<StateError>()));

        await pumpEventQueue();
        expect(
          events,
          containsAllInOrder([
            'Logger:register',
            'Logger:init',
            'Logger:dispose',
          ]),
        );
      },
    );

    test('missing dependency throws descriptive error', () async {
      final network = _TrackingModule(
        'Network',
        priority: 40,
        dependencies: [_LoggerService, _CacheService],
        provides: [_NetworkService],
      );

      registry.registerModule(network);

      expect(
        () => registry.initializeAll(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('No module provides'),
          ),
        ),
      );
    });

    test('circular dependency is detected', () async {
      final a = _TrackingModule(
        'ModuleA',
        priority: 0,
        dependencies: [_CacheService],
        provides: [_LoggerService],
      );
      final b = _TrackingModule(
        'ModuleB',
        priority: 0,
        dependencies: [_LoggerService],
        provides: [_CacheService],
      );

      registry.registerModules([a, b]);

      expect(
        () => registry.initializeAll(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('circular'),
          ),
        ),
      );
    });

    test('re-initialization after failure succeeds', () async {
      final events = <String>[];
      var attemptCount = 0;

      final logger = _TrackingModule(
        'Logger',
        priority: 0,
        dependencies: [],
        provides: [_LoggerService],
        events: events,
      );

      // Module that fails on first attempt, succeeds on second
      final storage = _TrackingModule(
        'Storage',
        priority: 10,
        dependencies: [_LoggerService],
        provides: [_StorageService],
        events: events,
        initCallback: () {
          attemptCount++;
          if (attemptCount == 1) {
            throw StateError('Transient failure');
          }
        },
      );

      registry.registerModules([logger, storage]);

      // First attempt should fail
      expect(() => registry.initializeAll(), throwsA(isA<StateError>()));

      await pumpEventQueue();
      events.clear();

      // Second attempt should succeed (re-register fresh modules)
      final freshLocator = MockServiceLocator();
      final freshRegistry = ModuleRegistry(locator: freshLocator);
      freshRegistry.registerModules([logger, storage]);
      await freshRegistry.initializeAll();

      expect(events.where((e) => e.endsWith(':init')).length, 2);
      await freshRegistry.disposeAll();
    });
  });
}

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

/// Marker types for dependency resolution
abstract class _LoggerService {}

abstract class _StorageService {}

abstract class _CacheService {}

abstract class _NetworkService {}

/// Module that records lifecycle events and optionally fails.
class _TrackingModule implements IModule {
  _TrackingModule(
    this._name, {
    required int priority,
    required List<Type> dependencies,
    required List<Type> provides,
    List<String>? events,
    this.failOnInit = false,
    this.failOnRegister = false,
    this.initCallback,
  }) : _priority = priority,
       _dependencies = dependencies,
       _provides = provides,
       _events = events ?? [];

  final String _name;
  final int _priority;
  final List<Type> _dependencies;
  final List<Type> _provides;
  final List<String> _events;
  final bool failOnInit;
  final bool failOnRegister;
  final void Function()? initCallback;

  @override
  String get name => _name;

  @override
  int get priority => _priority;

  @override
  List<Type> get dependencies => _dependencies;

  @override
  List<Type> get provides => _provides;

  @override
  Future<void> register(IServiceLocator locator) async {
    _events.add('$_name:register');
    if (failOnRegister) {
      throw StateError('$_name register failed');
    }
    // Register a marker so dependency validation passes
    for (final type in _provides) {
      if (!locator.isRegisteredByType(type)) {
        locator.registerSingleton<Object>(Object());
        // Re-register under the specific type for isRegisteredByType
        _registerMarker(locator, type);
      }
    }
  }

  void _registerMarker(IServiceLocator locator, Type type) {
    // Use the marker type for dependency resolution
    if (type == _LoggerService) {
      locator.registerSingleton<_LoggerService>(_LoggerServiceImpl());
    } else if (type == _StorageService) {
      locator.registerSingleton<_StorageService>(_StorageServiceImpl());
    } else if (type == _CacheService) {
      locator.registerSingleton<_CacheService>(_CacheServiceImpl());
    } else if (type == _NetworkService) {
      locator.registerSingleton<_NetworkService>(_NetworkServiceImpl());
    }
  }

  @override
  Future<void> init() async {
    initCallback?.call();
    if (failOnInit) {
      throw StateError('$_name init failed');
    }
    _events.add('$_name:init');
  }

  @override
  Future<void> dispose() async {
    _events.add('$_name:dispose');
  }
}

class _LoggerServiceImpl implements _LoggerService {}

class _StorageServiceImpl implements _StorageService {}

class _CacheServiceImpl implements _CacheService {}

class _NetworkServiceImpl implements _NetworkService {}

/// Mock ServiceLocator for integration testing (isolated from global state).
class MockServiceLocator implements IServiceLocator {
  final Map<Type, dynamic> _services = {};

  @override
  void registerSingleton<T extends Object>(T instance) {
    _services[T] = instance;
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factoryFunc) {
    _services[T] = factoryFunc;
  }

  @override
  void registerFactory<T extends Object>(T Function() factory) {
    _services[T] = factory;
  }

  @override
  T get<T extends Object>() {
    final service = _services[T];
    if (service == null) {
      throw StateError('Service of type $T not registered');
    }
    if (service is Function) {
      return service() as T;
    }
    return service as T;
  }

  @override
  bool isRegistered<T extends Object>() => _services.containsKey(T);

  @override
  bool isRegisteredByType(Type type) => _services.containsKey(type);

  @override
  Future<void> unregister<T extends Object>() async {
    _services.remove(T);
  }

  @override
  Future<void> reset() async {
    _services.clear();
  }
}
