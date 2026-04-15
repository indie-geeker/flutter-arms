import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/app/app_router.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
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
    LocaleSettings.setLocaleSync(AppLocale.en);
    mockKvStorage = _MockKvStorage();
    when(() => mockKvStorage.isOnboardingDone()).thenReturn(false);
    when(() => mockKvStorage.markOnboardingDone()).thenAnswer((_) async {});
  });

  Future<void> pumpOnboarding(WidgetTester tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [kvStorageProvider.overrideWithValue(mockKvStorage)],
          child: MaterialApp.router(routerConfig: _TestRouter().config()),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('swipe changes the visible slide', (tester) async {
    await pumpOnboarding(tester);

    expect(find.text('Start fast'), findsOneWidget);

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

    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('skip completes onboarding and navigates to login', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    verify(() => mockKvStorage.markOnboardingDone()).called(1);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('start cta completes onboarding and navigates to login', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    verify(() => mockKvStorage.markOnboardingDone()).called(1);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
