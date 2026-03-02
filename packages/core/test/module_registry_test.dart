import 'package:flutter_test/flutter_test.dart';
import 'package:core/src/di/module_registry.dart';
import 'package:core/src/di/service_locator.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:interfaces/core/i_service_locator.dart';

/// 测试用模块 - 无依赖
class MockLoggerModule implements IModule {
  @override
  String get name => 'MockLogger';

  @override
  int get priority => 0;

  @override
  List<Type> get dependencies => [];

  @override
  List<Type> get provides => [MockLoggerModule];

  bool registered = false;
  bool initialized = false;

  @override
  Future<void> register(IServiceLocator locator) async {
    registered = true;
    locator.registerSingleton<MockLoggerModule>(this);
  }

  @override
  Future<void> init() async {
    initialized = true;
  }

  @override
  Future<void> dispose() async {}
}

/// 测试用模块 - 有依赖
class MockNetworkModule implements IModule {
  @override
  String get name => 'MockNetwork';

  @override
  int get priority => 40;

  @override
  List<Type> get dependencies => [MockLoggerModule];

  @override
  List<Type> get provides => [MockNetworkModule];

  bool registered = false;
  bool initialized = false;

  @override
  Future<void> register(IServiceLocator locator) async {
    registered = true;
    locator.registerSingleton<MockNetworkModule>(this);
  }

  @override
  Future<void> init() async {
    initialized = true;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  group('ModuleRegistry', () {
    late ModuleRegistry registry;

    setUp(() async {
      registry = ModuleRegistry();
      // 重置 ServiceLocator 单例状态
      await ServiceLocator().reset();
    });

    tearDown(() async {
      await registry.disposeAll();
    });

    group('initializeAll', () {
      test('should initialize modules in priority order', () async {
        final List<String> initOrder = [];

        final lowPriority = _OrderTrackingModule('Low', 100, initOrder);
        final highPriority = _OrderTrackingModule('High', 10, initOrder);
        final mediumPriority = _OrderTrackingModule('Medium', 50, initOrder);

        registry.registerModules([lowPriority, highPriority, mediumPriority]);
        await registry.initializeAll();

        expect(initOrder, ['High', 'Medium', 'Low']);
      });

      test('should register and init each module', () async {
        final logger = MockLoggerModule();
        registry.registerModule(logger);

        await registry.initializeAll();

        expect(logger.registered, true);
        expect(logger.initialized, true);
      });

      test('should respect dependency order over priority', () async {
        final List<String> initOrder = [];

        final provider = _ProviderModule(initOrder);
        final consumer = _ConsumerModule(initOrder);

        // Consumer has higher priority (lower number) but depends on Provider
        registry.registerModules([consumer, provider]);
        await registry.initializeAll();

        expect(initOrder, ['Provider', 'Consumer']);
      });
    });

    group('module registration', () {
      test(
        'should deduplicate modules with same name when registered twice',
        () async {
          final first = _CountingModule(
            name: 'DuplicateModule',
            priority: 10,
            dependencies: const [],
            provides: const [],
          );
          final second = _CountingModule(name: 'DuplicateModule');

          registry.registerModule(first);
          registry.registerModule(second);
          await registry.initializeAll();

          expect(first.initCount, 0);
          expect(second.initCount, 1);
        },
      );

      test(
        'should replace previously registered modules when replace is true',
        () async {
          final original = _CountingModule(name: 'Original');
          final replacement = _CountingModule(name: 'Replacement');

          registry.registerModules([original]);
          registry.registerModules([replacement], replace: true);
          await registry.initializeAll();

          expect(original.initCount, 0);
          expect(replacement.initCount, 1);
        },
      );

      test(
        'should not duplicate same module across repeated registerModules calls',
        () async {
          final module = _CountingModule(name: 'RepeatRegister');

          registry.registerModules([module]);
          registry.registerModules([module]);
          await registry.initializeAll();

          expect(module.initCount, 1);
        },
      );
    });

    group('dependency validation', () {
      test(
        'should succeed when dependencies are registered in order',
        () async {
          final logger = MockLoggerModule();
          final network = MockNetworkModule();

          // Logger (priority 0) 先于 Network (priority 40) 注册
          registry.registerModules([logger, network]);

          // 不应抛出异常
          await registry.initializeAll();

          expect(logger.registered, true);
          expect(network.registered, true);
        },
      );

      test('should throw when dependency is not registered', () async {
        // 只注册 Network，不注册它依赖的 Logger
        final network = MockNetworkModule();
        registry.registerModule(network);

        expect(
          () => registry.initializeAll(),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('No module provides MockLoggerModule'),
            ),
          ),
        );
      });
    });

    group('initializeAllWithProgress', () {
      test('should call progress callback for each module', () async {
        final logger = MockLoggerModule();
        final network = MockNetworkModule();

        registry.registerModules([logger, network]);

        final List<String> progressLog = [];

        await registry.initializeAllWithProgress((module, current, total) {
          progressLog.add('${module.name}: $current/$total');
        });

        expect(progressLog, ['MockLogger: 1/2', 'MockNetwork: 2/2']);
      });

      test('should work without progress callback (null)', () async {
        final logger = MockLoggerModule();
        registry.registerModule(logger);

        // 不应抛出异常
        await registry.initializeAllWithProgress(null);

        expect(logger.initialized, true);
      });
    });

    group('disposeAll', () {
      test('should dispose modules in reverse order', () async {
        final List<String> disposeOrder = [];

        final first = _OrderTrackingModule('First', 10, [], disposeOrder);
        final second = _OrderTrackingModule('Second', 20, [], disposeOrder);
        final third = _OrderTrackingModule('Third', 30, [], disposeOrder);

        registry.registerModules([first, second, third]);
        await registry.initializeAll();
        await registry.disposeAll();

        // 销毁顺序应该是反向的
        expect(disposeOrder, ['Third', 'Second', 'First']);
      });
    });
  });
}

/// 辅助类：追踪初始化/销毁顺序
class _OrderTrackingModule implements IModule {
  final String _name;
  final int _priority;
  final List<String> _initOrder;
  final List<String>? _disposeOrder;

  _OrderTrackingModule(
    this._name,
    this._priority,
    this._initOrder, [
    this._disposeOrder,
  ]);

  @override
  String get name => _name;

  @override
  int get priority => _priority;

  @override
  List<Type> get dependencies => [];

  @override
  List<Type> get provides => [];

  @override
  Future<void> register(IServiceLocator locator) async {}

  @override
  Future<void> init() async {
    _initOrder.add(_name);
  }

  @override
  Future<void> dispose() async {
    _disposeOrder?.add(_name);
  }
}

class _ProviderModule implements IModule {
  final List<String> _initOrder;

  _ProviderModule(this._initOrder);

  @override
  String get name => 'Provider';

  @override
  int get priority => 100;

  @override
  List<Type> get dependencies => [];

  @override
  List<Type> get provides => [_ProviderModule];

  @override
  Future<void> register(IServiceLocator locator) async {
    locator.registerSingleton<_ProviderModule>(this);
  }

  @override
  Future<void> init() async {
    _initOrder.add(name);
  }

  @override
  Future<void> dispose() async {}
}

class _ConsumerModule implements IModule {
  final List<String> _initOrder;

  _ConsumerModule(this._initOrder);

  @override
  String get name => 'Consumer';

  @override
  int get priority => 0;

  @override
  List<Type> get dependencies => [_ProviderModule];

  @override
  List<Type> get provides => [_ConsumerModule];

  @override
  Future<void> register(IServiceLocator locator) async {
    locator.registerSingleton<_ConsumerModule>(this);
  }

  @override
  Future<void> init() async {
    _initOrder.add(name);
  }

  @override
  Future<void> dispose() async {}
}

class _CountingModule implements IModule {
  _CountingModule({
    required this.name,
    this.priority = 0,
    this.dependencies = const [],
    this.provides = const [],
  });

  @override
  final String name;

  @override
  final int priority;

  @override
  final List<Type> dependencies;

  @override
  final List<Type> provides;

  int registerCount = 0;
  int initCount = 0;
  int disposeCount = 0;

  @override
  Future<void> register(IServiceLocator locator) async {
    registerCount++;
  }

  @override
  Future<void> init() async {
    initCount++;
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
  }
}
