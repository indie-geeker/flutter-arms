import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/application/feedback_usecases.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/submit_feedback_usecase.dart';
import 'package:flutter_arms/features/feedback/presentation/pages/submit_feedback_page.dart';
import 'package:flutter_arms/features/feedback/presentation/view_models/feedback_center_view_model.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_overlay/super_overlay.dart';

import '../../../../helpers/super_overlay_test_app.dart';

class _MockSubmitFeedbackUseCase extends Mock
    implements SubmitFeedbackUseCase {}

FeedbackTicket _ticket() => FeedbackTicket(
  id: 'ticket-1',
  category: FeedbackCategory.suggestion,
  message: 'Please add a compact layout.',
  status: FeedbackStatus.submitted,
  createdAt: DateTime.utc(2026, 7, 16, 12),
);

void main() {
  late _MockSubmitFeedbackUseCase submitFeedback;

  setUpAll(() {
    registerFallbackValue(
      const FeedbackDraft(
        category: FeedbackCategory.other,
        message: 'fallback',
      ),
    );
  });

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
    submitFeedback = _MockSubmitFeedbackUseCase();
  });

  Future<ProviderContainer> pumpPage(
    WidgetTester tester, {
    Future<Result<FeedbackTicket>> Function()? submitOverride,
  }) async {
    final container = ProviderContainer(
      overrides: [
        submitFeedbackUseCaseProvider.overrideWithValue(submitFeedback),
      ],
    );
    addTearDown(container.dispose);
    container.listen(feedbackCenterViewModelProvider, (_, _) {});
    await tester.pumpWidget(
      TranslationProvider(
        child: UncontrolledProviderScope(
          container: container,
          child: SuperOverlayTestApp(
            home: SubmitFeedbackPage.test(submitOverride: submitOverride),
          ),
        ),
      ),
    );
    return container;
  }

  Future<void> enterMessageAndConfirm(
    WidgetTester tester,
    String message,
  ) async {
    await tester.enterText(
      find.byKey(const Key('feedbackMessageField')),
      message,
    );
    await tester.tap(find.byKey(const Key('feedbackSubmitButton')));
    await tester.pumpAndSettle();
    expect(find.text('Send feedback?'), findsOneWidget);
    await tester.tap(find.text('Send'));
    await tester.pump();
  }

  testWidgets('confirm shows loading then success toast and adds the ticket', (
    tester,
  ) async {
    final completer = Completer<Result<FeedbackTicket>>();
    when(() => submitFeedback(any())).thenAnswer((_) => completer.future);
    final ticket = _ticket();
    final container = await pumpPage(tester);

    await tester.tap(find.byKey(const Key('feedback-category-suggestion')));
    await enterMessageAndConfirm(tester, '  Please add a compact layout.  ');

    expect(find.text('Sending feedback...'), findsOneWidget);
    final submitButton = tester.widget<FilledButton>(
      find.byKey(const Key('feedbackSubmitButton')),
    );
    expect(submitButton.onPressed, isNull);
    final draft =
        verify(
              () => submitFeedback(captureAny()),
            ).captured.single
            as FeedbackDraft;
    expect(draft.category, FeedbackCategory.suggestion);
    expect(draft.message, 'Please add a compact layout.');

    completer.complete(Result<FeedbackTicket>.success(ticket));
    await tester.pumpAndSettle();

    expect(find.text('Sending feedback...'), findsNothing);
    expect(find.text('Thanks — your feedback was sent.'), findsOneWidget);
    expect(
      container.read(feedbackCenterViewModelProvider).tickets,
      [ticket],
    );

    await SuperOverlay.close<void>(target: OverlayCloseTarget.allToasts);
    await tester.pumpAndSettle();
  });

  testWidgets('shows visual category choices and a live character count', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.byKey(const Key('feedbackCategoryField')), findsOneWidget);
    expect(find.byKey(const Key('feedback-category-bug')), findsOneWidget);
    expect(
      find.byKey(const Key('feedback-category-suggestion')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('feedback-category-other')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('feedbackMessageCount')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('feedbackMessageField')),
      'Useful feedback',
    );
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const Key('feedbackMessageCount')),
        matching: find.text('15'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('failure closes loading, keeps input and shows error toast', (
    tester,
  ) async {
    const failure = Failure(code: FailureCode.network);
    when(
      () => submitFeedback(any()),
    ).thenAnswer(
      (_) async => const Result<FeedbackTicket>.failure(failure),
    );
    await pumpPage(tester);

    await enterMessageAndConfirm(tester, 'Keep this feedback text');
    await tester.pumpAndSettle();

    expect(find.text('Sending feedback...'), findsNothing);
    expect(
      find.text(
        'Network connection failed. Please check your network settings.',
      ),
      findsOneWidget,
    );
    final field = tester.widget<TextFormField>(
      find.byKey(const Key('feedbackMessageField')),
    );
    expect(field.controller?.text, 'Keep this feedback text');

    await SuperOverlay.close<void>(target: OverlayCloseTarget.allToasts);
    await tester.pumpAndSettle();
  });

  testWidgets('blank input focuses the field without dialog or request', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.byKey(const Key('feedbackSubmitButton')));
    await tester.pump();

    expect(find.text('Please enter your feedback.'), findsOneWidget);
    expect(find.text('Send feedback?'), findsNothing);
    final editable = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('feedbackMessageField')),
        matching: find.byType(EditableText),
      ),
    );
    expect(editable.focusNode.hasFocus, isTrue);
    verifyNever(() => submitFeedback(any()));
  });

  testWidgets('leaving during a request still closes global loading', (
    tester,
  ) async {
    final completer = Completer<Result<FeedbackTicket>>();
    final showSubmitPage = ValueNotifier<bool>(true);
    addTearDown(showSubmitPage.dispose);
    final container = ProviderContainer(
      overrides: [
        submitFeedbackUseCaseProvider.overrideWithValue(submitFeedback),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      TranslationProvider(
        child: UncontrolledProviderScope(
          container: container,
          child: SuperOverlayTestApp(
            home: ValueListenableBuilder<bool>(
              valueListenable: showSubmitPage,
              builder:
                  (_, visible, _) =>
                      visible
                          ? SubmitFeedbackPage.test(
                            submitOverride: () => completer.future,
                          )
                          : const Scaffold(
                            body: Center(child: Text('Page left')),
                          ),
            ),
          ),
        ),
      ),
    );

    await enterMessageAndConfirm(tester, 'Request completes after pop');
    expect(find.text('Sending feedback...'), findsOneWidget);

    showSubmitPage.value = false;
    await tester.pump();
    expect(find.byType(SubmitFeedbackPage), findsNothing);
    expect(find.text('Page left'), findsOneWidget);
    expect(find.text('Sending feedback...'), findsOneWidget);

    completer.complete(Result<FeedbackTicket>.success(_ticket()));
    await tester.pumpAndSettle();

    expect(find.text('Sending feedback...'), findsNothing);
  });
}
