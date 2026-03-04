import 'package:core/src/init/initializer.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppInitializer', () {
    test('should initialize modules and report progress', () async {
      final initializer = AppInitializer();
      final module = _CoreTestModule('CoreTest');
      final progress = <String>[];

      await initializer.initialize(modules: [module], onProgress: progress.add);

      expect(module.registerCount, 1);
      expect(module.initCount, 1);
      expect(progress, hasLength(1));
      expect(progress.first, contains('CoreTest'));

      await initializer.dispose();
      expect(module.disposeCount, 1);
    });

    test(
      'should keep initialization idempotent for duplicate module names',
      () async {
        final initializer = AppInitializer();
        final first = _CoreTestModule('Duplicate');
        final second = _CoreTestModule('Duplicate');

        await initializer.initialize(modules: [first, second]);

        expect(first.initCount, 0);
        expect(second.initCount, 1);

        await initializer.dispose();
      },
    );
  });
}

class _CoreTestModule implements IModule {
  @override
  bool get isHealthy => true;

  _CoreTestModule(this.name);

  @override
  final String name;

  int registerCount = 0;
  int initCount = 0;
  int disposeCount = 0;

  @override
  int get priority => 0;

  @override
  List<Type> get dependencies => const [];

  @override
  List<Type> get provides => <Type>[_CoreTestModule];

  @override
  Future<void> register(IServiceLocator locator) async {
    registerCount++;
    locator.registerSingleton<_CoreTestModule>(this);
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
