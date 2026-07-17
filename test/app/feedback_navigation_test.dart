import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/app/app_router.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/feedback/application/feedback_usecases.dart';
import 'package:flutter_arms/features/feedback/domain/entities/faq_item.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/get_feedback_ticket_usecase.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/get_feedback_tickets_usecase.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/search_faqs_usecase.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockKvStorage extends Mock implements KvStorage {}

class _MockSearchFaqsUseCase extends Mock implements SearchFaqsUseCase {}

class _MockGetFeedbackTicketsUseCase extends Mock
    implements GetFeedbackTicketsUseCase {}

class _MockGetFeedbackTicketUseCase extends Mock
    implements GetFeedbackTicketUseCase {}

FeedbackTicket _ticket() => FeedbackTicket(
  id: 'ticket-1',
  category: FeedbackCategory.bug,
  message: 'The save button does not respond.',
  status: FeedbackStatus.reviewing,
  createdAt: DateTime.utc(2026, 7, 16, 12),
);

void main() {
  late _MockKvStorage storage;
  late _MockSearchFaqsUseCase searchFaqs;
  late _MockGetFeedbackTicketsUseCase getTickets;
  late _MockGetFeedbackTicketUseCase getTicket;

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
    storage = _MockKvStorage();
    searchFaqs = _MockSearchFaqsUseCase();
    getTickets = _MockGetFeedbackTicketsUseCase();
    getTicket = _MockGetFeedbackTicketUseCase();

    when(storage.getThemeMode).thenReturn(ThemeMode.system);
    when(storage.getThemeSeedColor).thenReturn(const Color(0xFF1D4ED8));
    when(storage.getLocale).thenReturn(null);
    when(storage.isOnboardingDone).thenReturn(true);
    when(storage.getAccessToken).thenReturn('access-token');
    when(storage.getRefreshToken).thenReturn('refresh-token');
    when(storage.getUserMap).thenReturn(null);
  });

  Future<AppRouter> routerFor(
    WidgetTester tester,
    AppFlavor flavor,
  ) async {
    late AppRouter router;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(AppEnv.fromFlavor(flavor)),
          kvStorageProvider.overrideWithValue(storage),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            router = AppRouter(ref);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return router;
  }

  testWidgets('route table keeps feedback guarded and Showcase dev-only', (
    tester,
  ) async {
    const argumentFreeFeedbackRoutes = <PageRouteInfo<void>>[
      FeedbackCenterRoute(),
      SubmitFeedbackRoute(),
    ];
    expect(argumentFreeFeedbackRoutes, hasLength(2));

    final devRouter = await routerFor(tester, AppFlavor.dev);
    final devRoutes = devRouter.routes;
    final devNames = devRoutes.map((route) => route.page.name).toSet();

    expect(devNames, contains(ShowcaseRoute.name));
    expect(
      devNames,
      containsAll(<String>{
        FeedbackCenterRoute.name,
        SubmitFeedbackRoute.name,
        FeedbackDetailRoute.name,
      }),
    );
    for (final routeName in <String>{
      FeedbackCenterRoute.name,
      SubmitFeedbackRoute.name,
      FeedbackDetailRoute.name,
    }) {
      final route = devRoutes.singleWhere(
        (candidate) => candidate.page.name == routeName,
      );
      expect(route.guards, isNotEmpty);
    }

    final home = devRoutes.singleWhere(
      (route) => route.page.name == HomeRoute.name,
    );
    expect(
      home.children?.map((route) => route.page.name),
      <String>[HomeTabRoute.name, ProfileRoute.name],
    );

    final prodRouter = await routerFor(tester, AppFlavor.prod);
    final prodNames = prodRouter.routes.map((route) => route.page.name).toSet();
    expect(prodNames, isNot(contains(ShowcaseRoute.name)));
    expect(prodNames, contains(FeedbackCenterRoute.name));
  });

  testWidgets('two-tab shell opens feedback submit and typed detail routes', (
    tester,
  ) async {
    final ticket = _ticket();
    when(
      () => searchFaqs(''),
    ).thenAnswer((_) async => const Result<List<FaqItem>>.success([]));
    when(
      getTickets.call,
    ).thenAnswer(
      (_) async => Result<List<FeedbackTicket>>.success([ticket]),
    );
    when(
      () => getTicket(ticket.id),
    ).thenAnswer((_) async => Result<FeedbackTicket>.success(ticket));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(AppEnv.fromFlavor(AppFlavor.dev)),
          kvStorageProvider.overrideWithValue(storage),
          searchFaqsUseCaseProvider.overrideWithValue(searchFaqs),
          getFeedbackTicketsUseCaseProvider.overrideWithValue(getTickets),
          getFeedbackTicketUseCaseProvider.overrideWithValue(getTicket),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(2));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Search'), findsNothing);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Help & Feedback'),
      120,
      scrollable: find.byType(Scrollable),
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('Help & Feedback')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Help & Feedback'));
    await tester.pumpAndSettle();

    expect(find.text('Help & Feedback'), findsOneWidget);
    expect(find.text(ticket.message), findsOneWidget);

    await tester.tap(find.byKey(const Key('feedbackSubmitCta')));
    await tester.pumpAndSettle();
    expect(find.text('Send feedback'), findsWidgets);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await Scrollable.ensureVisible(
      tester.element(find.text(ticket.message)),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(ticket.message));
    await tester.pumpAndSettle();

    expect(find.text('Feedback details'), findsOneWidget);
    expect(find.text(ticket.message), findsOneWidget);
    verify(() => getTicket(ticket.id)).called(1);
  });
}
