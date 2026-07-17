import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/application/feedback_usecases.dart';
import 'package:flutter_arms/features/feedback/domain/entities/faq_item.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/get_feedback_tickets_usecase.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/search_faqs_usecase.dart';
import 'package:flutter_arms/features/feedback/presentation/pages/feedback_center_page.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSearchFaqsUseCase extends Mock implements SearchFaqsUseCase {}

class _MockGetFeedbackTicketsUseCase extends Mock
    implements GetFeedbackTicketsUseCase {}

const _faq = FaqItem(
  id: 'faq-1',
  question: 'How do I report a bug?',
  answer: 'Choose Bug and describe what happened.',
);

FeedbackTicket _ticket() => FeedbackTicket(
  id: 'ticket-1',
  category: FeedbackCategory.bug,
  message: 'The save button does not respond.',
  status: FeedbackStatus.reviewing,
  createdAt: DateTime.utc(2026, 7, 16, 12),
);

void main() {
  late _MockSearchFaqsUseCase searchFaqs;
  late _MockGetFeedbackTicketsUseCase getTickets;

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
    searchFaqs = _MockSearchFaqsUseCase();
    getTickets = _MockGetFeedbackTicketsUseCase();
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    AppLocale locale = AppLocale.en,
    VoidCallback? onSubmit,
    ValueChanged<FeedbackTicket>? onTicketTap,
  }) async {
    await tester.runAsync(() => LocaleSettings.setLocale(locale));
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            searchFaqsUseCaseProvider.overrideWithValue(searchFaqs),
            getFeedbackTicketsUseCaseProvider.overrideWithValue(getTickets),
          ],
          child: MaterialApp(
            locale: locale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: FeedbackCenterPage.test(
              onSubmit: onSubmit,
              onTicketTap: onTicketTap,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows page loading then FAQ, CTA and history data', (
    tester,
  ) async {
    final faqs = Completer<Result<List<FaqItem>>>();
    final tickets = Completer<Result<List<FeedbackTicket>>>();
    when(() => searchFaqs('')).thenAnswer((_) => faqs.future);
    when(getTickets.call).thenAnswer((_) => tickets.future);
    var submitTapped = false;
    FeedbackTicket? tappedTicket;

    await pumpPage(
      tester,
      onSubmit: () => submitTapped = true,
      onTicketTap: (ticket) => tappedTicket = ticket,
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final ticket = _ticket();
    faqs.complete(const Result<List<FaqItem>>.success([_faq]));
    tickets.complete(Result<List<FeedbackTicket>>.success([ticket]));
    await tester.pumpAndSettle();

    expect(find.text('Help & Feedback'), findsOneWidget);
    expect(find.byKey(const Key('feedbackIntroCard')), findsOneWidget);
    expect(find.text('Frequently asked questions'), findsOneWidget);
    expect(find.byKey(const Key('feedbackFaqSection')), findsOneWidget);
    expect(find.text(_faq.question), findsOneWidget);
    expect(find.text('Send feedback'), findsOneWidget);
    expect(find.text('Your feedback'), findsOneWidget);
    expect(find.byKey(const Key('feedbackHistorySection')), findsOneWidget);
    expect(find.text(ticket.message), findsOneWidget);
    expect(
      find.byKey(const Key('feedback-status-reviewing')),
      findsOneWidget,
    );
    final searchTop =
        tester.getTopLeft(find.byKey(const Key('feedbackSearchField'))).dy;
    final faqTop =
        tester.getTopLeft(find.text('Frequently asked questions')).dy;
    final submitTop =
        tester.getTopLeft(find.byKey(const Key('feedbackSubmitCta'))).dy;
    final historyTop = tester.getTopLeft(find.text('Your feedback')).dy;
    expect(searchTop, lessThan(faqTop));
    expect(faqTop, lessThan(submitTop));
    expect(submitTop, lessThan(historyTop));

    await tester.tap(find.text(_faq.question));
    await tester.pumpAndSettle();
    expect(find.text(_faq.answer), findsOneWidget);

    await tester.tap(find.byKey(const Key('feedbackSubmitCta')));
    expect(submitTapped, isTrue);

    await Scrollable.ensureVisible(
      tester.element(find.text(ticket.message)),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(ticket.message));
    expect(tappedTicket, ticket);
  });

  testWidgets('submits the FAQ query without clearing history', (
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
      () => searchFaqs('billing'),
    ).thenAnswer((_) async => const Result<List<FaqItem>>.success([_faq]));
    await pumpPage(tester);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('feedbackSearchField')),
      'billing',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    verify(() => searchFaqs('billing')).called(1);
    expect(find.text(_faq.question), findsOneWidget);
    expect(find.text(ticket.message), findsOneWidget);
  });

  testWidgets('shows useful empty states in Chinese', (tester) async {
    when(
      () => searchFaqs(''),
    ).thenAnswer((_) async => const Result<List<FaqItem>>.success([]));
    when(
      getTickets.call,
    ).thenAnswer((_) async => const Result<List<FeedbackTicket>>.success([]));

    await pumpPage(tester, locale: AppLocale.zh);
    await tester.pumpAndSettle();

    expect(find.text('帮助与反馈'), findsOneWidget);
    expect(find.text('搜索帮助'), findsOneWidget);
    expect(find.text('没有找到相关解答'), findsOneWidget);
    expect(find.text('还没有反馈记录'), findsOneWidget);
    expect(find.text('发送反馈'), findsOneWidget);
  });

  testWidgets('shows a recoverable error and retries the full load', (
    tester,
  ) async {
    const failure = Failure(
      code: FailureCode.network,
      detail: 'offline',
    );
    when(
      () => searchFaqs(''),
    ).thenAnswer(
      (_) async => const Result<List<FaqItem>>.failure(failure),
    );
    when(
      getTickets.call,
    ).thenAnswer(
      (_) async => const Result<List<FeedbackTicket>>.failure(failure),
    );
    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('Could not load feedback'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    when(
      () => searchFaqs(''),
    ).thenAnswer((_) async => const Result<List<FaqItem>>.success([_faq]));
    when(
      getTickets.call,
    ).thenAnswer((_) async => const Result<List<FeedbackTicket>>.success([]));
    await tester.tap(find.byKey(const Key('feedbackRetryButton')));
    await tester.pumpAndSettle();

    expect(find.text(_faq.question), findsOneWidget);
    verify(() => searchFaqs('')).called(2);
    verify(getTickets.call).called(2);
  });
}
