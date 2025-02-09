// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arms/main.dart';

// 创建一个简单的计数器 provider
final counterProvider = StateProvider<int>((ref) => 0);

// 创建一个简单的测试组件
class TestWidget extends ConsumerWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return MaterialApp(
      home: Scaffold(
        body: Text('Count: $count'),
        floatingActionButton: FloatingActionButton(
          onPressed: () => ref.read(counterProvider.notifier).state++,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

void main() {
  group('Riverpod Counter Tests', () {
    testWidgets('Counter increments when button is tapped',
        (WidgetTester tester) async {
      // 使用 ProviderScope 包装测试组件
      await tester.pumpWidget(
        const ProviderScope(
          child: TestWidget(),
        ),
      );

      // 验证初始计数为0
      expect(find.text('Count: 0'), findsOneWidget);

      // 点击按钮
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // 验证计数增加到1
      expect(find.text('Count: 1'), findsOneWidget);
    });

    test('Provider state updates correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 检查初始状态
      expect(container.read(counterProvider), 0);

      // 更新状态
      container.read(counterProvider.notifier).state = 1;

      // 验证状态更新
      expect(container.read(counterProvider), 1);
    });
  });
}
