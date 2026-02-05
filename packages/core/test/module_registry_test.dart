import 'package:test/test.dart';
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

    setUp(() {
      registry = ModuleRegistry();
      // 重置 ServiceLocator 单例状态
      ServiceLocator().reset();
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
    });

    group('dependency validation', () {
      test('should succeed when dependencies are registered in order', () async {
        final logger = MockLoggerModule();
        final network = MockNetworkModule();

        // Logger (priority 0) 先于 Network (priority 40) 注册
        registry.registerModules([logger, network]);

        // 不应抛出异常
        await registry.initializeAll();

        expect(logger.registered, true);
        expect(network.registered, true);
      });

      test('should throw when dependency is not registered', () async {
        // 只注册 Network，不注册它依赖的 Logger
        final network = MockNetworkModule();
        registry.registerModule(network);

        expect(
          () => registry.initializeAll(),
          throwsA(isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('MockNetwork depends on MockLoggerModule'),
          )),
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

        expect(progressLog, [
          'MockLogger: 1/2',
          'MockNetwork: 2/2',
        ]);
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
