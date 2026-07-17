import 'dart:async';

import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/application/feedback_usecases.dart';
import 'package:flutter_arms/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:flutter_arms/features/feedback/domain/entities/faq_item.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/get_feedback_ticket_usecase.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/get_feedback_tickets_usecase.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/search_faqs_usecase.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/submit_feedback_usecase.dart';
import 'package:flutter_arms/features/feedback/presentation/view_models/feedback_center_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFeedbackRepository extends Mock implements FeedbackRepository {}

class _MockSearchFaqsUseCase extends Mock implements SearchFaqsUseCase {}

class _MockGetFeedbackTicketsUseCase extends Mock
    implements GetFeedbackTicketsUseCase {}

class _MockGetFeedbackTicketUseCase extends Mock
    implements GetFeedbackTicketUseCase {}

class _MockSubmitFeedbackUseCase extends Mock
    implements SubmitFeedbackUseCase {}

const _initialFaq = FaqItem(
  id: 'faq-initial',
  question: 'How can I get help?',
  answer: 'Open the feedback center.',
);

const _searchFaq = FaqItem(
  id: 'faq-search',
  question: 'How can I reset my account?',
  answer: 'Open account settings.',
);

FeedbackTicket _ticket({String id = 'ticket-1'}) => FeedbackTicket(
  id: id,
  category: FeedbackCategory.bug,
  message: 'The page does not load.',
  status: FeedbackStatus.reviewing,
  createdAt: DateTime.utc(2026, 7, 16, 12),
);

void main() {
  group('feedback use case providers', () {
    test(
      'resolve all four use cases from feedbackRepositoryProvider',
      () async {
        final repository = _MockFeedbackRepository();
        const draft = FeedbackDraft(
          category: FeedbackCategory.suggestion,
          message: 'Please add a compact layout.',
        );
        final ticket = _ticket();
        const faqResult = Result<List<FaqItem>>.success([_initialFaq]);
        final ticketsResult = Result<List<FeedbackTicket>>.success([ticket]);
        final ticketResult = Result<FeedbackTicket>.success(ticket);

        when(
          () => repository.searchFaqs('help'),
        ).thenAnswer((_) async => faqResult);
        when(
          repository.getTickets,
        ).thenAnswer((_) async => ticketsResult);
        when(
          () => repository.getTicket('ticket-1'),
        ).thenAnswer((_) async => ticketResult);
        when(
          () => repository.submit(draft),
        ).thenAnswer((_) async => ticketResult);

        final container = ProviderContainer(
          overrides: [
            feedbackRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        expect(
          await container.read(searchFaqsUseCaseProvider)('  help  '),
          same(faqResult),
        );
        expect(
          await container.read(getFeedbackTicketsUseCaseProvider)(),
          same(ticketsResult),
        );
        expect(
          await container.read(getFeedbackTicketUseCaseProvider)('ticket-1'),
          same(ticketResult),
        );
        expect(
          await container.read(submitFeedbackUseCaseProvider)(draft),
          same(ticketResult),
        );

        verify(() => repository.searchFaqs('help')).called(1);
        verify(repository.getTickets).called(1);
        verify(() => repository.getTicket('ticket-1')).called(1);
        verify(() => repository.submit(draft)).called(1);
      },
    );
  });

  group('FeedbackCenterViewModel', () {
    late _MockSearchFaqsUseCase searchFaqs;
    late _MockGetFeedbackTicketsUseCase getTickets;
    late _MockGetFeedbackTicketUseCase getTicket;
    late _MockSubmitFeedbackUseCase submitFeedback;

    setUp(() {
      searchFaqs = _MockSearchFaqsUseCase();
      getTickets = _MockGetFeedbackTicketsUseCase();
      getTicket = _MockGetFeedbackTicketUseCase();
      submitFeedback = _MockSubmitFeedbackUseCase();
    });

    ProviderContainer createContainer() {
      final container = ProviderContainer(
        overrides: [
          searchFaqsUseCaseProvider.overrideWithValue(searchFaqs),
          getFeedbackTicketsUseCaseProvider.overrideWithValue(getTickets),
          getFeedbackTicketUseCaseProvider.overrideWithValue(getTicket),
          submitFeedbackUseCaseProvider.overrideWithValue(submitFeedback),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('starts with an empty idle state without side effects', () {
      final container = createContainer();

      final state = container.read(feedbackCenterViewModelProvider);

      expect(state.faqs, isEmpty);
      expect(state.tickets, isEmpty);
      expect(state.query, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      verifyNever(() => searchFaqs(any()));
      verifyNever(getTickets.call);
    });

    test(
      'load starts FAQ and ticket requests together then exposes both',
      () async {
        final faqCompleter = Completer<Result<List<FaqItem>>>();
        final ticketCompleter = Completer<Result<List<FeedbackTicket>>>();
        final ticket = _ticket();
        when(() => searchFaqs('')).thenAnswer((_) => faqCompleter.future);
        when(getTickets.call).thenAnswer((_) => ticketCompleter.future);
        final container = createContainer();
        final notifier = container.read(
          feedbackCenterViewModelProvider.notifier,
        );

        final loadFuture = notifier.load();

        expect(
          container.read(feedbackCenterViewModelProvider).isLoading,
          isTrue,
        );
        verify(() => searchFaqs('')).called(1);
        verify(getTickets.call).called(1);

        faqCompleter.complete(
          const Result<List<FaqItem>>.success([_initialFaq]),
        );
        ticketCompleter.complete(
          Result<List<FeedbackTicket>>.success([ticket]),
        );
        await loadFuture;

        final state = container.read(feedbackCenterViewModelProvider);
        expect(state.faqs, const [_initialFaq]);
        expect(state.tickets, [ticket]);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      },
    );

    test('search updates FAQs and query without clearing tickets', () async {
      final ticket = _ticket();
      when(
        () => searchFaqs(''),
      ).thenAnswer(
        (_) async => const Result<List<FaqItem>>.success([_initialFaq]),
      );
      when(
        getTickets.call,
      ).thenAnswer(
        (_) async => Result<List<FeedbackTicket>>.success([ticket]),
      );
      when(
        () => searchFaqs('account'),
      ).thenAnswer(
        (_) async => const Result<List<FaqItem>>.success([_searchFaq]),
      );
      final container = createContainer();
      final notifier = container.read(feedbackCenterViewModelProvider.notifier);
      await notifier.load();

      final searchFuture = notifier.search('account');

      expect(container.read(feedbackCenterViewModelProvider).tickets, [ticket]);
      await searchFuture;
      final state = container.read(feedbackCenterViewModelProvider);
      expect(state.query, 'account');
      expect(state.faqs, const [_searchFaq]);
      expect(state.tickets, [ticket]);
      expect(state.error, isNull);
    });

    test(
      'addTicket deduplicates by id and prepends without changing other state',
      () async {
        const searchFailure = Failure(
          code: FailureCode.network,
          detail: 'Search unavailable',
        );
        final previousTicket = _ticket();
        final otherTicket = _ticket(id: 'ticket-2');
        final updatedTicket = FeedbackTicket(
          id: previousTicket.id,
          category: FeedbackCategory.suggestion,
          message: 'Updated ticket',
          status: FeedbackStatus.submitted,
          createdAt: DateTime.utc(2026, 7, 16, 13),
        );
        when(
          () => searchFaqs(''),
        ).thenAnswer(
          (_) async => const Result<List<FaqItem>>.success([_initialFaq]),
        );
        when(
          getTickets.call,
        ).thenAnswer(
          (_) async => Result<List<FeedbackTicket>>.success([
            previousTicket,
            otherTicket,
          ]),
        );
        when(
          () => searchFaqs('unavailable'),
        ).thenAnswer(
          (_) async => const Result<List<FaqItem>>.failure(searchFailure),
        );
        final container = createContainer();
        final notifier = container.read(
          feedbackCenterViewModelProvider.notifier,
        );
        await notifier.load();
        await notifier.search('unavailable');

        notifier.addTicket(updatedTicket);

        final state = container.read(feedbackCenterViewModelProvider);
        expect(state.tickets, [updatedTicket, otherTicket]);
        expect(state.query, 'unavailable');
        expect(state.faqs, const [_initialFaq]);
        expect(state.error, same(searchFailure));
        expect(state.isLoading, isFalse);
      },
    );

    test('load keeps successful tickets when FAQ search fails', () async {
      const failure = Failure(
        code: FailureCode.network,
        detail: 'FAQ unavailable',
      );
      final ticket = _ticket();
      when(
        () => searchFaqs(''),
      ).thenAnswer(
        (_) async => const Result<List<FaqItem>>.failure(failure),
      );
      when(
        getTickets.call,
      ).thenAnswer(
        (_) async => Result<List<FeedbackTicket>>.success([ticket]),
      );
      final container = createContainer();

      await container.read(feedbackCenterViewModelProvider.notifier).load();

      final state = container.read(feedbackCenterViewModelProvider);
      expect(state.faqs, isEmpty);
      expect(state.tickets, [ticket]);
      expect(state.faqError, same(failure));
      expect(state.ticketError, isNull);
      expect(state.error, same(failure));
      expect(state.isLoading, isFalse);
    });

    test('load keeps successful FAQs when ticket loading fails', () async {
      const failure = Failure(
        code: FailureCode.timeout,
        detail: 'Ticket history unavailable',
      );
      when(
        () => searchFaqs(''),
      ).thenAnswer(
        (_) async => const Result<List<FaqItem>>.success([_initialFaq]),
      );
      when(
        getTickets.call,
      ).thenAnswer(
        (_) async => const Result<List<FeedbackTicket>>.failure(failure),
      );
      final container = createContainer();

      await container.read(feedbackCenterViewModelProvider.notifier).load();

      final state = container.read(feedbackCenterViewModelProvider);
      expect(state.faqs, const [_initialFaq]);
      expect(state.tickets, isEmpty);
      expect(state.faqError, isNull);
      expect(state.ticketError, same(failure));
      expect(state.error, same(failure));
      expect(state.isLoading, isFalse);
    });

    test('load preserves both FAQ and ticket failure sources', () async {
      const faqFailure = Failure(
        code: FailureCode.network,
        detail: 'FAQ unavailable',
      );
      const ticketFailure = Failure(
        code: FailureCode.timeout,
        detail: 'Ticket history unavailable',
      );
      when(
        () => searchFaqs(''),
      ).thenAnswer(
        (_) async => const Result<List<FaqItem>>.failure(faqFailure),
      );
      when(
        getTickets.call,
      ).thenAnswer(
        (_) async => const Result<List<FeedbackTicket>>.failure(ticketFailure),
      );
      final container = createContainer();

      await container.read(feedbackCenterViewModelProvider.notifier).load();

      final state = container.read(feedbackCenterViewModelProvider);
      expect(state.faqError, same(faqFailure));
      expect(state.ticketError, same(ticketFailure));
      expect(state.error, same(faqFailure));
      expect(state.isLoading, isFalse);
    });

    test(
      'successful FAQ search preserves an existing ticket failure',
      () async {
        const ticketFailure = Failure(
          code: FailureCode.timeout,
          detail: 'Ticket history unavailable',
        );
        when(
          () => searchFaqs(''),
        ).thenAnswer(
          (_) async => const Result<List<FaqItem>>.success([_initialFaq]),
        );
        when(
          getTickets.call,
        ).thenAnswer(
          (_) async =>
              const Result<List<FeedbackTicket>>.failure(ticketFailure),
        );
        when(
          () => searchFaqs('account'),
        ).thenAnswer(
          (_) async => const Result<List<FaqItem>>.success([_searchFaq]),
        );
        final container = createContainer();
        final notifier = container.read(
          feedbackCenterViewModelProvider.notifier,
        );
        await notifier.load();

        await notifier.search('account');

        final state = container.read(feedbackCenterViewModelProvider);
        expect(state.faqs, const [_searchFaq]);
        expect(state.faqError, isNull);
        expect(state.ticketError, same(ticketFailure));
        expect(state.error, same(ticketFailure));
      },
    );

    test('successful retry clears both failure sources', () async {
      const faqFailure = Failure(code: FailureCode.network);
      const ticketFailure = Failure(code: FailureCode.timeout);
      var faqCalls = 0;
      var ticketCalls = 0;
      final ticket = _ticket(id: 'ticket-recovered');
      when(() => searchFaqs('')).thenAnswer((_) async {
        faqCalls += 1;
        return faqCalls == 1
            ? const Result<List<FaqItem>>.failure(faqFailure)
            : const Result<List<FaqItem>>.success([_initialFaq]);
      });
      when(getTickets.call).thenAnswer((_) async {
        ticketCalls += 1;
        return ticketCalls == 1
            ? const Result<List<FeedbackTicket>>.failure(ticketFailure)
            : Result<List<FeedbackTicket>>.success([ticket]);
      });
      final container = createContainer();
      final notifier = container.read(feedbackCenterViewModelProvider.notifier);
      await notifier.load();
      expect(
        container.read(feedbackCenterViewModelProvider).error,
        same(faqFailure),
      );

      await notifier.retry();

      final state = container.read(feedbackCenterViewModelProvider);
      expect(state.faqs, const [_initialFaq]);
      expect(state.tickets, [ticket]);
      expect(state.faqError, isNull);
      expect(state.ticketError, isNull);
      expect(state.error, isNull);
    });

    test('retry reloads both sides using the current query', () async {
      var faqCalls = 0;
      final ticket = _ticket(id: 'ticket-retry');
      when(() => searchFaqs('account')).thenAnswer((_) async {
        faqCalls += 1;
        return Result<List<FaqItem>>.success(
          faqCalls == 1 ? const [_initialFaq] : const [_searchFaq],
        );
      });
      when(
        getTickets.call,
      ).thenAnswer(
        (_) async => Result<List<FeedbackTicket>>.success([ticket]),
      );
      final container = createContainer();
      final notifier = container.read(feedbackCenterViewModelProvider.notifier);
      await notifier.search('account');

      await notifier.retry();

      final state = container.read(feedbackCenterViewModelProvider);
      expect(state.query, 'account');
      expect(state.faqs, const [_searchFaq]);
      expect(state.tickets, [ticket]);
      verify(() => searchFaqs('account')).called(2);
      verify(getTickets.call).called(1);
    });

    test('a stale FAQ result cannot overwrite a newer search', () async {
      final firstCompleter = Completer<Result<List<FaqItem>>>();
      final secondCompleter = Completer<Result<List<FaqItem>>>();
      const firstFaq = FaqItem(
        id: 'faq-first',
        question: 'First result',
        answer: 'Old answer',
      );
      const secondFaq = FaqItem(
        id: 'faq-second',
        question: 'Second result',
        answer: 'Current answer',
      );
      when(
        () => searchFaqs('first'),
      ).thenAnswer((_) => firstCompleter.future);
      when(
        () => searchFaqs('second'),
      ).thenAnswer((_) => secondCompleter.future);
      final container = createContainer();
      final notifier = container.read(feedbackCenterViewModelProvider.notifier);

      final firstSearch = notifier.search('first');
      final secondSearch = notifier.search('second');
      secondCompleter.complete(
        const Result<List<FaqItem>>.success([secondFaq]),
      );
      await secondSearch;

      var state = container.read(feedbackCenterViewModelProvider);
      expect(state.query, 'second');
      expect(state.faqs, const [secondFaq]);
      expect(state.isLoading, isTrue);

      firstCompleter.complete(
        const Result<List<FaqItem>>.success([firstFaq]),
      );
      await firstSearch;

      state = container.read(feedbackCenterViewModelProvider);
      expect(state.query, 'second');
      expect(state.faqs, const [secondFaq]);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test(
      'a newer search keeps loading until pending load tickets complete',
      () async {
        final loadFaqCompleter = Completer<Result<List<FaqItem>>>();
        final loadTicketsCompleter = Completer<Result<List<FeedbackTicket>>>();
        final searchCompleter = Completer<Result<List<FaqItem>>>();
        final ticket = _ticket(id: 'ticket-from-load');
        when(
          () => searchFaqs(''),
        ).thenAnswer((_) => loadFaqCompleter.future);
        when(
          getTickets.call,
        ).thenAnswer((_) => loadTicketsCompleter.future);
        when(
          () => searchFaqs('account'),
        ).thenAnswer((_) => searchCompleter.future);
        final container = createContainer();
        final subscription = container.listen(
          feedbackCenterViewModelProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        final notifier = container.read(
          feedbackCenterViewModelProvider.notifier,
        );

        final loadFuture = notifier.load();
        final searchFuture = notifier.search('account');
        searchCompleter.complete(
          const Result<List<FaqItem>>.success([_searchFaq]),
        );
        await searchFuture;

        var state = container.read(feedbackCenterViewModelProvider);
        expect(state.query, 'account');
        expect(state.faqs, const [_searchFaq]);
        expect(state.tickets, isEmpty);
        expect(state.isLoading, isTrue);

        loadTicketsCompleter.complete(
          Result<List<FeedbackTicket>>.success([ticket]),
        );
        await Future<void>.delayed(Duration.zero);

        state = container.read(feedbackCenterViewModelProvider);
        expect(state.faqs, const [_searchFaq]);
        expect(state.tickets, [ticket]);
        expect(state.isLoading, isTrue);

        loadFaqCompleter.complete(
          const Result<List<FaqItem>>.success([_initialFaq]),
        );
        await loadFuture;

        state = container.read(feedbackCenterViewModelProvider);
        expect(state.query, 'account');
        expect(state.faqs, const [_searchFaq]);
        expect(state.tickets, [ticket]);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      },
    );

    test(
      'pending ticket load keeps a local ticket until the server confirms it',
      () async {
        final firstTickets = Completer<Result<List<FeedbackTicket>>>();
        final serverHistory = _ticket(id: 'ticket-history');
        final localTicket = FeedbackTicket(
          id: 'ticket-local',
          category: FeedbackCategory.suggestion,
          message: 'Local pending ticket',
          status: FeedbackStatus.submitted,
          createdAt: DateTime.utc(2026, 7, 16, 13),
        );
        final serverVersion = FeedbackTicket(
          id: localTicket.id,
          category: localTicket.category,
          message: 'Server-confirmed ticket',
          status: FeedbackStatus.reviewing,
          createdAt: DateTime.utc(2026, 7, 16, 13, 1),
          reply: 'We are reviewing this.',
        );
        var ticketCalls = 0;
        when(
          () => searchFaqs(''),
        ).thenAnswer(
          (_) async => const Result<List<FaqItem>>.success([_initialFaq]),
        );
        when(getTickets.call).thenAnswer((_) {
          ticketCalls += 1;
          return switch (ticketCalls) {
            1 => firstTickets.future,
            2 => Future.value(
              Result<List<FeedbackTicket>>.success([
                serverVersion,
                serverHistory,
              ]),
            ),
            _ => Future.value(
              Result<List<FeedbackTicket>>.success([serverHistory]),
            ),
          };
        });
        final container = createContainer();
        final subscription = container.listen(
          feedbackCenterViewModelProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        final notifier = container.read(
          feedbackCenterViewModelProvider.notifier,
        );

        final firstLoad = notifier.load();
        notifier.addTicket(localTicket);
        firstTickets.complete(
          Result<List<FeedbackTicket>>.success([serverHistory]),
        );
        await firstLoad;

        expect(
          container.read(feedbackCenterViewModelProvider).tickets,
          [localTicket, serverHistory],
        );

        await notifier.load();
        expect(
          container.read(feedbackCenterViewModelProvider).tickets,
          [serverVersion, serverHistory],
        );

        await notifier.load();
        expect(
          container.read(feedbackCenterViewModelProvider).tickets,
          [serverHistory],
        );
      },
    );

    test('a stale load cannot overwrite a newer load', () async {
      final firstFaqs = Completer<Result<List<FaqItem>>>();
      final secondFaqs = Completer<Result<List<FaqItem>>>();
      final firstTickets = Completer<Result<List<FeedbackTicket>>>();
      final secondTickets = Completer<Result<List<FeedbackTicket>>>();
      final staleTicket = _ticket(id: 'ticket-stale');
      final latestTicket = _ticket(id: 'ticket-latest');
      var faqCalls = 0;
      var ticketCalls = 0;
      when(() => searchFaqs('')).thenAnswer((_) {
        faqCalls += 1;
        return faqCalls == 1 ? firstFaqs.future : secondFaqs.future;
      });
      when(getTickets.call).thenAnswer((_) {
        ticketCalls += 1;
        return ticketCalls == 1 ? firstTickets.future : secondTickets.future;
      });
      final container = createContainer();
      final subscription = container.listen(
        feedbackCenterViewModelProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final notifier = container.read(feedbackCenterViewModelProvider.notifier);

      final staleLoad = notifier.load();
      final latestLoad = notifier.load();
      secondFaqs.complete(
        const Result<List<FaqItem>>.success([_searchFaq]),
      );
      secondTickets.complete(
        Result<List<FeedbackTicket>>.success([latestTicket]),
      );
      await latestLoad;

      var state = container.read(feedbackCenterViewModelProvider);
      expect(state.faqs, const [_searchFaq]);
      expect(state.tickets, [latestTicket]);
      expect(state.isLoading, isTrue);

      firstFaqs.complete(
        const Result<List<FaqItem>>.success([_initialFaq]),
      );
      firstTickets.complete(
        Result<List<FeedbackTicket>>.success([staleTicket]),
      );
      await staleLoad;

      state = container.read(feedbackCenterViewModelProvider);
      expect(state.faqs, const [_searchFaq]);
      expect(state.tickets, [latestTicket]);
      expect(state.isLoading, isFalse);
    });

    test(
      'pending load and search complete safely after auto-dispose',
      () async {
        final loadFaqCompleter = Completer<Result<List<FaqItem>>>();
        final loadTicketsCompleter = Completer<Result<List<FeedbackTicket>>>();
        when(
          () => searchFaqs(''),
        ).thenAnswer((_) => loadFaqCompleter.future);
        when(
          getTickets.call,
        ).thenAnswer((_) => loadTicketsCompleter.future);
        final loadContainer = createContainer();
        final loadSubscription = loadContainer.listen(
          feedbackCenterViewModelProvider,
          (_, _) {},
          fireImmediately: true,
        );
        final loadFuture =
            loadContainer.read(feedbackCenterViewModelProvider.notifier).load();

        loadSubscription.close();
        await loadContainer.pump();
        expect(loadContainer.exists(feedbackCenterViewModelProvider), isFalse);
        loadFaqCompleter.complete(
          const Result<List<FaqItem>>.success([_initialFaq]),
        );
        loadTicketsCompleter.complete(
          Result<List<FeedbackTicket>>.success([_ticket()]),
        );
        await expectLater(loadFuture, completes);

        final searchCompleter = Completer<Result<List<FaqItem>>>();
        when(
          () => searchFaqs('disposed'),
        ).thenAnswer((_) => searchCompleter.future);
        final searchContainer = createContainer();
        final searchSubscription = searchContainer.listen(
          feedbackCenterViewModelProvider,
          (_, _) {},
          fireImmediately: true,
        );
        final searchFuture = searchContainer
            .read(feedbackCenterViewModelProvider.notifier)
            .search('disposed');

        searchSubscription.close();
        await searchContainer.pump();
        expect(
          searchContainer.exists(feedbackCenterViewModelProvider),
          isFalse,
        );
        searchCompleter.complete(
          const Result<List<FaqItem>>.success([_searchFaq]),
        );
        await expectLater(searchFuture, completes);
      },
    );
  });
}
