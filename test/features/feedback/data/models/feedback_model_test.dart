import 'package:flutter_arms/features/feedback/data/models/faq_item_model.dart';
import 'package:flutter_arms/features/feedback/data/models/feedback_ticket_model.dart';
import 'package:flutter_arms/features/feedback/data/models/submit_feedback_request.dart';
import 'package:flutter_arms/features/feedback/domain/entities/faq_item.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FaqItemModel', () {
    test('round-trips exact JSON and maps to the domain entity', () {
      final json = <String, dynamic>{
        'id': 'faq-1',
        'question': 'How do I send feedback?',
        'answer': 'Open Help & Feedback from your profile.',
      };

      final model = FaqItemModel.fromJson(json);

      expect(model.toJson(), json);
      expect(
        model.toEntity(),
        const FaqItem(
          id: 'faq-1',
          question: 'How do I send feedback?',
          answer: 'Open Help & Feedback from your profile.',
        ),
      );
    });
  });

  group('FeedbackTicketModel', () {
    test('round-trips typed enums, date and reply and maps to entity', () {
      final json = <String, dynamic>{
        'id': 'ticket-1',
        'category': 'suggestion',
        'message': 'Please add dark mode scheduling.',
        'status': 'reviewing',
        'createdAt': '2026-07-16T12:34:56.000Z',
        'reply': 'Thanks, we are reviewing it.',
      };

      final model = FeedbackTicketModel.fromJson(json);

      expect(model.category, FeedbackCategory.suggestion);
      expect(model.status, FeedbackStatus.reviewing);
      expect(model.createdAt, DateTime.utc(2026, 7, 16, 12, 34, 56));
      expect(model.reply, 'Thanks, we are reviewing it.');
      expect(model.toJson(), json);
      expect(
        model.toEntity(),
        FeedbackTicket(
          id: 'ticket-1',
          category: FeedbackCategory.suggestion,
          message: 'Please add dark mode scheduling.',
          status: FeedbackStatus.reviewing,
          createdAt: DateTime.utc(2026, 7, 16, 12, 34, 56),
          reply: 'Thanks, we are reviewing it.',
        ),
      );
    });

    test('serializes every category and status by enum name', () {
      for (final category in FeedbackCategory.values) {
        for (final status in FeedbackStatus.values) {
          final json = <String, dynamic>{
            'id': 'ticket-enum',
            'category': category.name,
            'message': 'Enum contract',
            'status': status.name,
            'createdAt': '2026-07-16T00:00:00.000Z',
            'reply': null,
          };

          final model = FeedbackTicketModel.fromJson(json);

          expect(model.category, category);
          expect(model.status, status);
          expect(model.reply, isNull);
          expect(model.toJson(), json);
        }
      }
    });
  });

  group('SubmitFeedbackRequest', () {
    test('is created from a domain draft and emits exact JSON', () {
      const draft = FeedbackDraft(
        category: FeedbackCategory.bug,
        message: 'The save button does not respond.',
      );

      final request = SubmitFeedbackRequest.fromDomain(draft);

      expect(request.category, FeedbackCategory.bug);
      expect(request.message, 'The save button does not respond.');
      expect(request.toJson(), <String, dynamic>{
        'category': 'bug',
        'message': 'The save button does not respond.',
      });
      expect(
        SubmitFeedbackRequest.fromJson(request.toJson()),
        request,
      );
    });
  });
}
