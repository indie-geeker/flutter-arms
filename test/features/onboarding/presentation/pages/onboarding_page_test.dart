import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/app/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class _MockKvStorage extends Mock implements KvStorage {}

class _TestRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: OnboardingRoute.page, initial: true),
    AutoRoute(page: LoginRoute.page),
  ];
}

void main() {
  late _MockKvStorage mockKvStorage;

  setUp(() {
    mockKvStorage = _MockKvStorage();
    when(() => mockKvStorage.isOnboardingDone()).thenReturn(false);
    when(() => mockKvStorage.markOnboardingDone()).thenAnswer((_) async {});
  });

  Future<void> pumpOnboarding(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [kvStorageProvider.overrideWithValue(mockKvStorage)],
        child: MaterialApp.router(routerConfig: _TestRouter().config()),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('swipe changes the visible slide', (tester) async {
    await pumpOnboarding(tester);

    expect(find.text('快速启动模板'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Clean Architecture + MVVM'), findsOneWidget);
  });

  testWidgets('shows start cta on the last slide', (tester) async {
    await pumpOnboarding(tester);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('开始使用'), findsOneWidget);
    expect(find.text('下一步'), findsNothing);
  });

  testWidgets('skip completes onboarding and navigates to login', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text('跳过'));
    await tester.pumpAndSettle();

    verify(() => mockKvStorage.markOnboardingDone()).called(1);
    expect(find.text('欢迎登录'), findsOneWidget);
  });

  testWidgets('start cta completes onboarding and navigates to login', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('开始使用'));
    await tester.pumpAndSettle();

    verify(() => mockKvStorage.markOnboardingDone()).called(1);
    expect(find.text('欢迎登录'), findsOneWidget);
  });
}
