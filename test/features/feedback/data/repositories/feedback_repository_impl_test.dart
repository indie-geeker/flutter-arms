import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:flutter_arms/features/feedback/data/models/faq_item_model.dart';
import 'package:flutter_arms/features/feedback/data/models/feedback_ticket_model.dart';
import 'package:flutter_arms/features/feedback/data/models/submit_feedback_request.dart';
import 'package:flutter_arms/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:flutter_arms/features/feedback/domain/entities/faq_item.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFeedbackRemoteDataSource extends Mock
    implements FeedbackRemoteDataSource {}

void main() {
  const faqModel = FaqItemModel(
    id: 'faq-1',
    question: 'How do I send feedback?',
    answer: 'Open Help & Feedback from your profile.',
  );
  final ticketModel = FeedbackTicketModel(
    id: 'ticket-1',
    category: FeedbackCategory.suggestion,
    message: 'Please add dark mode scheduling.',
    status: FeedbackStatus.submitted,
    createdAt: DateTime.utc(2026, 7, 16, 12),
  );

  late _MockFeedbackRemoteDataSource remote;
  late FeedbackRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const SubmitFeedbackRequest(
        category: FeedbackCategory.other,
        message: 'fallback',
      ),
    );
  });

  setUp(() {
    remote = _MockFeedbackRemoteDataSource();
    repository = FeedbackRepositoryImpl(remote);
  });

  group('success mapping', () {
    test('searchFaqs maps every model to a domain entity', () async {
      when(
        () => remote.searchFaqs('billing'),
      ).thenAnswer((_) async => const <FaqItemModel>[faqModel]);

      final result = await repository.searchFaqs('billing');

      expect(result.data, const <FaqItem>[
        FaqItem(
          id: 'faq-1',
          question: 'How do I send feedback?',
          answer: 'Open Help & Feedback from your profile.',
        ),
      ]);
    });

    test('getTickets maps every model to a domain entity', () async {
      when(
        () => remote.getTickets(),
      ).thenAnswer((_) async => <FeedbackTicketModel>[ticketModel]);

      final result = await repository.getTickets();

      expect(result.data, <FeedbackTicket>[ticketModel.toEntity()]);
    });

    test('getTicket maps the model to a domain entity', () async {
      when(
        () => remote.getTicket('ticket-1'),
      ).thenAnswer((_) async => ticketModel);

      final result = await repository.getTicket('ticket-1');

      expect(result.data, ticketModel.toEntity());
    });

    test('submit maps the response and passes a typed request', () async {
      when(() => remote.submit(any())).thenAnswer((_) async => ticketModel);
      const draft = FeedbackDraft(
        category: FeedbackCategory.suggestion,
        message: 'Please add dark mode scheduling.',
      );

      final result = await repository.submit(draft);

      expect(result.data, ticketModel.toEntity());
      final request =
          verify(
                () => remote.submit(captureAny()),
              ).captured.single
              as SubmitFeedbackRequest;
      expect(
        request,
        const SubmitFeedbackRequest(
          category: FeedbackCategory.suggestion,
          message: 'Please add dark mode scheduling.',
        ),
      );
    });
  });

  group('AppException mapping', () {
    test('searchFaqs maps AppException to Failure', () async {
      when(
        () => remote.searchFaqs(any()),
      ).thenAnswer(
        (_) => Future<List<FaqItemModel>>.error(
          const NetworkException(detail: 'offline'),
        ),
      );

      final result = await repository.searchFaqs('billing');

      expect(result.failure?.code, FailureCode.network);
      expect(result.failure?.detail, 'offline');
    });

    test('getTickets maps AppException to Failure', () async {
      when(
        () => remote.getTickets(),
      ).thenAnswer(
        (_) => Future<List<FeedbackTicketModel>>.error(
          const TimeoutException(detail: 'too slow'),
        ),
      );

      final result = await repository.getTickets();

      expect(result.failure?.code, FailureCode.timeout);
      expect(result.failure?.detail, 'too slow');
    });

    test('getTicket maps AppException to Failure', () async {
      when(
        () => remote.getTicket(any()),
      ).thenAnswer(
        (_) => Future<FeedbackTicketModel>.error(
          const AuthException(detail: 'signed out'),
        ),
      );

      final result = await repository.getTicket('ticket-1');

      expect(result.failure?.code, FailureCode.auth);
      expect(result.failure?.detail, 'signed out');
    });

    test('submit maps AppException to Failure', () async {
      when(
        () => remote.submit(any()),
      ).thenAnswer(
        (_) => Future<FeedbackTicketModel>.error(
          const ValidationException(detail: 'message is required'),
        ),
      );

      final result = await repository.submit(
        const FeedbackDraft(
          category: FeedbackCategory.other,
          message: '',
        ),
      );

      expect(result.failure?.code, FailureCode.validation);
      expect(result.failure?.detail, 'message is required');
    });
  });
}
