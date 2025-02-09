import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// 测试用的简单页面
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/details/123'),
          child: const Text('Go to Details'),
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  final String id;
  const DetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details $id')),
      body: Center(
        child: Text('Detail page with ID: $id'),
      ),
    );
  }
}

void main() {
  group('Router Tests', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/details/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DetailsPage(id: id);
            },
          ),
        ],
      );
    });

    testWidgets('Initial route shows HomePage', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));

      // 验证首页显示正确
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Go to Details'), findsOneWidget);
    });

    testWidgets('Navigation to details page works', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));

      // 点击导航按钮
      await tester.tap(find.text('Go to Details'));
      await tester.pumpAndSettle();

      // 验证详情页显示正确
      expect(find.byType(DetailsPage), findsOneWidget);
      expect(find.text('Details 123'), findsOneWidget);
      expect(find.text('Detail page with ID: 123'), findsOneWidget);
    });
  });
}
