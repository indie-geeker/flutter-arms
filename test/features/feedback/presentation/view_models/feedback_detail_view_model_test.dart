import 'dart:async';

import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/application/feedback_usecases.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/get_feedback_ticket_usecase.dart';
import 'package:flutter_arms/features/feedback/presentation/view_models/feedback_detail_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetFeedbackTicketUseCase extends Mock
    implements GetFeedbackTicketUseCase {}

FeedbackTicket _ticket({
  String id = 'ticket-1',
  String message = 'The save button does not respond.',
}) => FeedbackTicket(
  id: id,
  category: FeedbackCategory.bug,
  message: message,
  status: FeedbackStatus.reviewing,
  createdAt: DateTime.utc(2026, 7, 16, 12),
);

void main() {
  late _MockGetFeedbackTicketUseCase getTicket;

  setUp(() {
    getTicket = _MockGetFeedbackTicketUseCase();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        getFeedbackTicketUseCaseProvider.overrideWithValue(getTicket),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('build is idle and has no loading side effect', () {
    final container = createContainer();
    final provider = feedbackDetailViewModelProvider('ticket-1');

    final state = container.read(provider);

    expect(state.ticket, isNull);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    verifyNever(() => getTicket(any()));
  });

  test('load exposes loading then the requested ticket', () async {
    final completer = Completer<Result<FeedbackTicket>>();
    when(() => getTicket('ticket-1')).thenAnswer((_) => completer.future);
    final ticket = _ticket();
    final container = createContainer();
    final provider = feedbackDetailViewModelProvider('ticket-1');
    container.listen(provider, (_, _) {}, fireImmediately: true);
    final notifier = container.read(provider.notifier);

    final loadFuture = notifier.load();

    expect(container.read(provider).isLoading, isTrue);
    expect(container.read(provider).error, isNull);
    verify(() => getTicket('ticket-1')).called(1);

    completer.complete(Result<FeedbackTicket>.success(ticket));
    await loadFuture;

    final state = container.read(provider);
    expect(state.ticket, ticket);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
  });

  test('failure preserves the ticket and retry reloads it', () async {
    final existing = _ticket(message: 'Original ticket');
    final refreshed = _ticket(message: 'Refreshed ticket');
    const failure = Failure(
      code: FailureCode.network,
      detail: 'Feedback service unavailable',
    );
    when(
      () => getTicket('ticket-1'),
    ).thenAnswer(
      (_) async => Result<FeedbackTicket>.success(existing),
    );
    final container = createContainer();
    final provider = feedbackDetailViewModelProvider('ticket-1');
    container.listen(provider, (_, _) {}, fireImmediately: true);
    final notifier = container.read(provider.notifier);
    await notifier.load();

    when(
      () => getTicket('ticket-1'),
    ).thenAnswer(
      (_) async => const Result<FeedbackTicket>.failure(failure),
    );
    await notifier.load();

    var state = container.read(provider);
    expect(state.ticket, existing);
    expect(state.isLoading, isFalse);
    expect(state.error, same(failure));

    when(
      () => getTicket('ticket-1'),
    ).thenAnswer(
      (_) async => Result<FeedbackTicket>.success(refreshed),
    );
    await notifier.retry();

    state = container.read(provider);
    expect(state.ticket, refreshed);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    verify(() => getTicket('ticket-1')).called(3);
  });

  test('an older load cannot overwrite a newer retry', () async {
    final first = Completer<Result<FeedbackTicket>>();
    final second = Completer<Result<FeedbackTicket>>();
    var requestCount = 0;
    when(() => getTicket('ticket-1')).thenAnswer((_) {
      requestCount += 1;
      return requestCount == 1 ? first.future : second.future;
    });
    final staleTicket = _ticket(message: 'Stale ticket');
    final latestTicket = _ticket(message: 'Latest ticket');
    final container = createContainer();
    final provider = feedbackDetailViewModelProvider('ticket-1');
    container.listen(provider, (_, _) {}, fireImmediately: true);
    final notifier = container.read(provider.notifier);

    final firstLoad = notifier.load();
    final latestLoad = notifier.retry();

    second.complete(Result<FeedbackTicket>.success(latestTicket));
    await latestLoad;
    first.complete(Result<FeedbackTicket>.success(staleTicket));
    await firstLoad;

    final state = container.read(provider);
    expect(state.ticket, latestTicket);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
    verify(() => getTicket('ticket-1')).called(2);
  });

  test('completion after auto-dispose does not access state or ref', () async {
    final completer = Completer<Result<FeedbackTicket>>();
    when(() => getTicket('ticket-1')).thenAnswer((_) => completer.future);
    final container = createContainer();
    final provider = feedbackDetailViewModelProvider('ticket-1');
    final subscription = container.listen(
      provider,
      (_, _) {},
      fireImmediately: true,
    );
    final notifier = container.read(provider.notifier);

    final loadFuture = notifier.load();
    expect(container.read(provider).isLoading, isTrue);

    subscription.close();
    await container.pump();
    expect(container.exists(provider), isFalse);

    completer.complete(Result<FeedbackTicket>.success(_ticket()));
    await expectLater(loadFuture, completes);
  });
}
