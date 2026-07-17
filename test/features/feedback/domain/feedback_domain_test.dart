import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/domain/entities/faq_item.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/get_feedback_ticket_usecase.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/get_feedback_tickets_usecase.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/search_faqs_usecase.dart';
import 'package:flutter_arms/features/feedback/domain/usecases/submit_feedback_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFeedbackRepository extends Mock implements FeedbackRepository {}

void main() {
  group('feedback domain entities', () {
    test('FaqItem includes every field in value equality', () {
      const item = FaqItem(
        id: 'faq-1',
        question: 'How do I send feedback?',
        answer: 'Open Help & Feedback from Profile.',
      );
      const same = FaqItem(
        id: 'faq-1',
        question: 'How do I send feedback?',
        answer: 'Open Help & Feedback from Profile.',
      );

      expect(item, same);
      expect(item.hashCode, same.hashCode);
      expect(
        item,
        isNot(
          const FaqItem(
            id: 'faq-2',
            question: 'How do I send feedback?',
            answer: 'Open Help & Feedback from Profile.',
          ),
        ),
      );
      expect(
        item,
        isNot(
          const FaqItem(
            id: 'faq-1',
            question: 'Where can I send feedback?',
            answer: 'Open Help & Feedback from Profile.',
          ),
        ),
      );
      expect(
        item,
        isNot(
          const FaqItem(
            id: 'faq-1',
            question: 'How do I send feedback?',
            answer: 'Contact support.',
          ),
        ),
      );
    });

    test('FeedbackDraft includes every field in value equality', () {
      const draft = FeedbackDraft(
        category: FeedbackCategory.suggestion,
        message: 'Please add a compact layout.',
      );
      const same = FeedbackDraft(
        category: FeedbackCategory.suggestion,
        message: 'Please add a compact layout.',
      );

      expect(draft, same);
      expect(draft.hashCode, same.hashCode);
      expect(
        draft,
        isNot(
          const FeedbackDraft(
            category: FeedbackCategory.bug,
            message: 'Please add a compact layout.',
          ),
        ),
      );
      expect(
        draft,
        isNot(
          const FeedbackDraft(
            category: FeedbackCategory.suggestion,
            message: 'Please add a spacious layout.',
          ),
        ),
      );
    });

    test('FeedbackTicket includes every field in value equality', () {
      final createdAt = DateTime.utc(2026, 7, 16, 12);
      final ticket = FeedbackTicket(
        id: 'ticket-1',
        category: FeedbackCategory.bug,
        message: 'The page does not load.',
        status: FeedbackStatus.reviewing,
        createdAt: createdAt,
        reply: 'We are investigating.',
      );
      final same = FeedbackTicket(
        id: 'ticket-1',
        category: FeedbackCategory.bug,
        message: 'The page does not load.',
        status: FeedbackStatus.reviewing,
        createdAt: DateTime.utc(2026, 7, 16, 12),
        reply: 'We are investigating.',
      );

      expect(ticket, same);
      expect(ticket.hashCode, same.hashCode);
      expect(
        ticket,
        isNot(
          FeedbackTicket(
            id: 'ticket-2',
            category: FeedbackCategory.bug,
            message: 'The page does not load.',
            status: FeedbackStatus.reviewing,
            createdAt: createdAt,
            reply: 'We are investigating.',
          ),
        ),
      );
      expect(
        ticket,
        isNot(
          FeedbackTicket(
            id: 'ticket-1',
            category: FeedbackCategory.suggestion,
            message: 'The page does not load.',
            status: FeedbackStatus.reviewing,
            createdAt: createdAt,
            reply: 'We are investigating.',
          ),
        ),
      );
      expect(
        ticket,
        isNot(
          FeedbackTicket(
            id: 'ticket-1',
            category: FeedbackCategory.bug,
            message: 'The page loads slowly.',
            status: FeedbackStatus.reviewing,
            createdAt: createdAt,
            reply: 'We are investigating.',
          ),
        ),
      );
      expect(
        ticket,
        isNot(
          FeedbackTicket(
            id: 'ticket-1',
            category: FeedbackCategory.bug,
            message: 'The page does not load.',
            status: FeedbackStatus.resolved,
            createdAt: createdAt,
            reply: 'We are investigating.',
          ),
        ),
      );
      expect(
        ticket,
        isNot(
          FeedbackTicket(
            id: 'ticket-1',
            category: FeedbackCategory.bug,
            message: 'The page does not load.',
            status: FeedbackStatus.reviewing,
            createdAt: DateTime.utc(2026, 7, 17, 12),
            reply: 'We are investigating.',
          ),
        ),
      );
      expect(
        ticket,
        isNot(
          FeedbackTicket(
            id: 'ticket-1',
            category: FeedbackCategory.bug,
            message: 'The page does not load.',
            status: FeedbackStatus.reviewing,
            createdAt: createdAt,
          ),
        ),
      );
    });

    test('feedback enums expose the supported values', () {
      expect(FeedbackCategory.values, [
        FeedbackCategory.bug,
        FeedbackCategory.suggestion,
        FeedbackCategory.other,
      ]);
      expect(FeedbackStatus.values, [
        FeedbackStatus.submitted,
        FeedbackStatus.reviewing,
        FeedbackStatus.resolved,
        FeedbackStatus.closed,
      ]);
    });
  });

  group('feedback use cases', () {
    late _MockFeedbackRepository repository;

    setUp(() {
      repository = _MockFeedbackRepository();
    });

    test('SearchFaqsUseCase trims the query before forwarding it', () async {
      const faqs = [
        FaqItem(
          id: 'faq-1',
          question: 'How do I send feedback?',
          answer: 'Open Help & Feedback from Profile.',
        ),
      ];
      const expected = Result<List<FaqItem>>.success(faqs);
      when(
        () => repository.searchFaqs('send feedback'),
      ).thenAnswer((_) async => expected);

      final result = await SearchFaqsUseCase(
        repository,
      )('  send feedback  ');

      expect(result, same(expected));
      verify(() => repository.searchFaqs('send feedback')).called(1);
    });

    test('GetFeedbackTicketsUseCase forwards to the repository', () async {
      final ticket = FeedbackTicket(
        id: 'ticket-1',
        category: FeedbackCategory.suggestion,
        message: 'Please add dark mode.',
        status: FeedbackStatus.submitted,
        createdAt: DateTime.utc(2026, 7, 16),
      );
      final expected = Result<List<FeedbackTicket>>.success([ticket]);
      when(
        () => repository.getTickets(),
      ).thenAnswer((_) async => expected);

      final result = await GetFeedbackTicketsUseCase(repository)();

      expect(result, same(expected));
      verify(() => repository.getTickets()).called(1);
    });

    test('GetFeedbackTicketUseCase forwards the ticket ID', () async {
      final ticket = FeedbackTicket(
        id: 'ticket-1',
        category: FeedbackCategory.other,
        message: 'I need help with my account.',
        status: FeedbackStatus.resolved,
        createdAt: DateTime.utc(2026, 7, 16),
        reply: 'Please sign in again.',
      );
      final expected = Result<FeedbackTicket>.success(ticket);
      when(
        () => repository.getTicket('ticket-1'),
      ).thenAnswer((_) async => expected);

      final result = await GetFeedbackTicketUseCase(repository)('ticket-1');

      expect(result, same(expected));
      verify(() => repository.getTicket('ticket-1')).called(1);
    });

    test('SubmitFeedbackUseCase forwards the draft', () async {
      const draft = FeedbackDraft(
        category: FeedbackCategory.bug,
        message: 'The save button does not respond.',
      );
      final ticket = FeedbackTicket(
        id: 'ticket-1',
        category: draft.category,
        message: draft.message,
        status: FeedbackStatus.submitted,
        createdAt: DateTime.utc(2026, 7, 16),
      );
      final expected = Result<FeedbackTicket>.success(ticket);
      when(() => repository.submit(draft)).thenAnswer((_) async => expected);

      final result = await SubmitFeedbackUseCase(repository)(draft);

      expect(result, same(expected));
      verify(() => repository.submit(draft)).called(1);
    });
  });
}
