import 'package:core/src/init/initializer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interfaces/core/i_service_locator.dart';
import 'package:interfaces/core/module_registry.dart';

void main() {
  group('AppInitializerWidget lifecycle', () {
    testWidgets('controller shutdown disposes modules predictably', (
      tester,
    ) async {
      final controller = AppInitializerController();
      final module = _WidgetTestModule('LifecycleModule');

      await tester.pumpWidget(
        MaterialApp(
          home: AppInitializerWidget(
            modules: [module],
            controller: controller,
            child: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(module.initCount, 1);
      expect(module.disposeCount, 0);

      final shutdownFuture = controller.shutdown();
      expect(module.disposeStarted, isTrue);
      await shutdownFuture;
      expect(module.disposeCount, 1);

      // Idempotent: repeated shutdown should not re-dispose
      await controller.shutdown();
      expect(module.disposeCount, 1);
    });

    testWidgets('unmount does not trigger async dispose implicitly', (
      tester,
    ) async {
      final controller = AppInitializerController();
      final module = _WidgetTestModule('UnmountModule');

      await tester.pumpWidget(
        MaterialApp(
          home: AppInitializerWidget(
            modules: [module],
            controller: controller,
            child: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(module.disposeCount, 0);
      await controller.shutdown();
      expect(module.disposeCount, 0);
    });
  });
}

class _WidgetTestModule implements IModule {
  @override
  bool get isHealthy => true;

  _WidgetTestModule(this.name);

  @override
  final String name;

  int initCount = 0;
  int disposeCount = 0;
  bool disposeStarted = false;

  @override
  int get priority => 0;

  @override
  List<Type> get dependencies => const [];

  @override
  List<Type> get provides => const [];

  @override
  Future<void> register(IServiceLocator locator) async {}

  @override
  Future<void> init() async {
    initCount++;
  }

  @override
  Future<void> dispose() async {
    disposeStarted = true;
    disposeCount++;
  }
}
