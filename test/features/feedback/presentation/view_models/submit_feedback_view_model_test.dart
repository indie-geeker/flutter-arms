import 'dart:async';

import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/application/feedback_usecases.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/submit_feedback_usecase.dart';
import 'package:flutter_arms/features/feedback/presentation/view_models/submit_feedback_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
    submitFeedback = _MockSubmitFeedbackUseCase();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        submitFeedbackUseCaseProvider.overrideWithValue(submitFeedback),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('starts with the documented form defaults', () {
    final container = createContainer();

    final state = container.read(submitFeedbackViewModelProvider);

    expect(state.category, FeedbackCategory.other);
    expect(state.message, isEmpty);
    expect(state.isSubmitting, isFalse);
    expect(state.error, isNull);
  });

  test('setCategory and setMessage clear the current error', () async {
    final container = createContainer();
    final notifier = container.read(submitFeedbackViewModelProvider.notifier);
    await notifier.submit();
    expect(
      container.read(submitFeedbackViewModelProvider).error?.code,
      FailureCode.validation,
    );

    notifier.setCategory(FeedbackCategory.bug);

    var state = container.read(submitFeedbackViewModelProvider);
    expect(state.category, FeedbackCategory.bug);
    expect(state.error, isNull);

    await notifier.submit();
    notifier.setMessage('The save button does not respond.');

    state = container.read(submitFeedbackViewModelProvider);
    expect(state.message, 'The save button does not respond.');
    expect(state.error, isNull);
  });

  test(
    'rejects a blank trimmed message without calling the use case',
    () async {
      final container = createContainer();
      final notifier = container.read(submitFeedbackViewModelProvider.notifier);
      notifier.setMessage('  \n  ');

      final result = await notifier.submit();

      expect(result.failure?.code, FailureCode.validation);
      final state = container.read(submitFeedbackViewModelProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.error?.code, FailureCode.validation);
      verifyNever(() => submitFeedback(any()));
    },
  );

  test('submits a trimmed draft and exposes the pending lifecycle', () async {
    final completer = Completer<Result<FeedbackTicket>>();
    when(() => submitFeedback(any())).thenAnswer((_) => completer.future);
    final ticket = _ticket();
    final container = createContainer();
    final notifier = container.read(submitFeedbackViewModelProvider.notifier);
    notifier
      ..setCategory(FeedbackCategory.suggestion)
      ..setMessage('  Please add a compact layout.  ');

    final submitFuture = notifier.submit();

    expect(
      container.read(submitFeedbackViewModelProvider).isSubmitting,
      isTrue,
    );
    final draft =
        verify(
              () => submitFeedback(captureAny()),
            ).captured.single
            as FeedbackDraft;
    expect(
      draft,
      const FeedbackDraft(
        category: FeedbackCategory.suggestion,
        message: 'Please add a compact layout.',
      ),
    );

    completer.complete(Result<FeedbackTicket>.success(ticket));
    final result = await submitFuture;

    expect(result.data, ticket);
    final state = container.read(submitFeedbackViewModelProvider);
    expect(state.isSubmitting, isFalse);
    expect(state.error, isNull);
  });

  test('failure preserves the form and exposes the typed failure', () async {
    const failure = Failure(
      code: FailureCode.network,
      detail: 'Feedback service unavailable',
    );
    when(
      () => submitFeedback(any()),
    ).thenAnswer(
      (_) async => const Result<FeedbackTicket>.failure(failure),
    );
    final container = createContainer();
    final notifier = container.read(submitFeedbackViewModelProvider.notifier);
    notifier
      ..setCategory(FeedbackCategory.bug)
      ..setMessage('  The save button does not respond.  ');

    final result = await notifier.submit();

    expect(result.failure, same(failure));
    final state = container.read(submitFeedbackViewModelProvider);
    expect(state.category, FeedbackCategory.bug);
    expect(state.message, '  The save button does not respond.  ');
    expect(state.isSubmitting, isFalse);
    expect(state.error, same(failure));
  });

  test('duplicate submit reuses the same in-flight result', () async {
    final completer = Completer<Result<FeedbackTicket>>();
    when(() => submitFeedback(any())).thenAnswer((_) => completer.future);
    final ticket = _ticket();
    final container = createContainer();
    final notifier = container.read(submitFeedbackViewModelProvider.notifier);
    notifier.setMessage('Please add a compact layout.');

    final first = notifier.submit();
    final second = notifier.submit();

    expect(identical(first, second), isTrue);
    verify(() => submitFeedback(any())).called(1);

    completer.complete(Result<FeedbackTicket>.success(ticket));
    expect((await first).data, ticket);
    expect((await second).data, ticket);
  });

  test('pending submit completes safely after auto-dispose', () async {
    final completer = Completer<Result<FeedbackTicket>>();
    when(() => submitFeedback(any())).thenAnswer((_) => completer.future);
    final ticket = _ticket();
    final expected = Result<FeedbackTicket>.success(ticket);
    final container = createContainer();
    final subscription = container.listen(
      submitFeedbackViewModelProvider,
      (_, _) {},
      fireImmediately: true,
    );
    final notifier = container.read(submitFeedbackViewModelProvider.notifier);
    notifier.setMessage('Please add a compact layout.');

    final submitFuture = notifier.submit();
    expect(
      container.read(submitFeedbackViewModelProvider).isSubmitting,
      isTrue,
    );

    subscription.close();
    await container.pump();
    expect(container.exists(submitFeedbackViewModelProvider), isFalse);

    completer.complete(expected);
    await expectLater(submitFuture, completion(same(expected)));
  });

  test('unexpected exceptions cannot leave submission stuck pending', () async {
    final completer = Completer<Result<FeedbackTicket>>();
    when(() => submitFeedback(any())).thenAnswer((_) => completer.future);
    final container = createContainer();
    final notifier = container.read(submitFeedbackViewModelProvider.notifier);
    notifier.setMessage('Please add a compact layout.');

    final submitFuture = notifier.submit();

    expect(
      container.read(submitFeedbackViewModelProvider).isSubmitting,
      isTrue,
    );
    completer.completeError(StateError('unexpected'));
    await expectLater(submitFuture, throwsStateError);
    expect(
      container.read(submitFeedbackViewModelProvider).isSubmitting,
      isFalse,
    );
  });
}
