import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/application/feedback_usecases.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/get_feedback_ticket_usecase.dart';
import 'package:flutter_arms/features/feedback/presentation/pages/feedback_detail_page.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetFeedbackTicketUseCase extends Mock
    implements GetFeedbackTicketUseCase {}

FeedbackTicket _ticket() => FeedbackTicket(
  id: 'ticket-1',
  category: FeedbackCategory.bug,
  message: 'The save button does not respond.',
  status: FeedbackStatus.reviewing,
  createdAt: DateTime.utc(2026, 7, 16, 12),
  reply: 'We are investigating this issue.',
);

void main() {
  late _MockGetFeedbackTicketUseCase getTicket;

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
    getTicket = _MockGetFeedbackTicketUseCase();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            getFeedbackTicketUseCaseProvider.overrideWithValue(getTicket),
          ],
          child: MaterialApp(
            locale: AppLocale.en.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: const FeedbackDetailPage(ticketId: 'ticket-1'),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('loads and renders localized ticket details', (tester) async {
    final completer = Completer<Result<FeedbackTicket>>();
    when(() => getTicket('ticket-1')).thenAnswer((_) => completer.future);
    final ticket = _ticket();

    await pumpPage(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completer.complete(Result<FeedbackTicket>.success(ticket));
    await tester.pumpAndSettle();

    expect(find.text('Feedback details'), findsOneWidget);
    expect(
      find.byKey(const Key('feedbackDetailSummaryCard')),
      findsOneWidget,
    );
    expect(find.text('#ticket-1'), findsOneWidget);
    expect(
      find.byKey(const Key('feedback-status-reviewing')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('feedbackDetailMessageCard')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('feedbackDetailReplyCard')),
      findsOneWidget,
    );
    expect(find.text(ticket.message), findsOneWidget);
    expect(find.text('Bug report'), findsOneWidget);
    expect(find.text('In review'), findsOneWidget);
    final context = tester.element(find.byType(FeedbackDetailPage));
    final expectedDate = MaterialLocalizations.of(
      context,
    ).formatMediumDate(ticket.createdAt.toLocal());
    expect(find.text(expectedDate), findsOneWidget);
    expect(find.text(ticket.reply!), findsOneWidget);
  });

  testWidgets('shows a clear waiting state when no reply is available', (
    tester,
  ) async {
    final ticket = FeedbackTicket(
      id: 'ticket-1',
      category: FeedbackCategory.suggestion,
      message: 'Please add a compact layout.',
      status: FeedbackStatus.submitted,
      createdAt: DateTime.utc(2026, 7, 16, 12),
    );
    when(
      () => getTicket('ticket-1'),
    ).thenAnswer((_) async => Result<FeedbackTicket>.success(ticket));

    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('feedbackReplyWaitingState')),
      findsOneWidget,
    );
    expect(find.text('No reply yet'), findsOneWidget);
  });

  testWidgets('shows an error with retry recovery', (tester) async {
    const failure = Failure(code: FailureCode.network);
    when(
      () => getTicket('ticket-1'),
    ).thenAnswer(
      (_) async => const Result<FeedbackTicket>.failure(failure),
    );
    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(find.text('Could not load feedback details'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    final ticket = _ticket();
    when(
      () => getTicket('ticket-1'),
    ).thenAnswer((_) async => Result<FeedbackTicket>.success(ticket));
    await tester.tap(find.byKey(const Key('feedbackDetailRetryButton')));
    await tester.pumpAndSettle();

    expect(find.text(ticket.message), findsOneWidget);
    verify(() => getTicket('ticket-1')).called(2);
  });
}
