import 'package:dio/dio.dart';
import 'package:flutter_arms/core/network/api_interceptor.dart';
import 'package:flutter_arms/core/network/mock_api_interceptor.dart';
import 'package:flutter_arms/features/feedback/data/datasources/retrofit_feedback_remote_datasource.dart';
import 'package:flutter_arms/features/feedback/data/models/submit_feedback_request.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'submit sends a typed request through Retrofit, Dio and the mock API',
    () async {
      final dio =
          Dio(BaseOptions(baseUrl: 'https://example.invalid'))
            ..interceptors.add(
              MockApiInterceptor(latency: Duration.zero),
            )
            ..interceptors.add(const ApiInterceptor());
      addTearDown(() => dio.close(force: true));
      final remote = RetrofitFeedbackRemoteDataSource(
        RetrofitFeedbackApi(dio),
      );

      final ticket = await remote.submit(
        const SubmitFeedbackRequest(
          category: FeedbackCategory.suggestion,
          message: '  Please add a compact list layout.  ',
        ),
      );

      expect(ticket.id, 'feedback-1003');
      expect(ticket.category, FeedbackCategory.suggestion);
      expect(ticket.message, 'Please add a compact list layout.');
      expect(ticket.status, FeedbackStatus.submitted);
      expect(ticket.createdAt.isUtc, isTrue);
      expect(ticket.reply, isNull);
    },
  );
}
