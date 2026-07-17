import 'package:dio/dio.dart';
import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/network/api_interceptor.dart';
import 'package:flutter_arms/core/network/dio_ext.dart';
import 'package:flutter_arms/core/network/mock_api_interceptor.dart';
import 'package:flutter_arms/features/feedback/data/models/faq_item_model.dart';
import 'package:flutter_arms/features/feedback/data/models/feedback_ticket_model.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio dio;

  setUp(() {
    dio =
        Dio(BaseOptions(baseUrl: 'https://example.invalid'))
          // Mock 首位 -> reject(err, true) 触发 ApiInterceptor.onError；
          // 否则 "following" 为空，DioException 不会被映射成 AppException。
          ..interceptors.add(
            // 覆盖生产默认的 300ms，消除测试等待时间。
            MockApiInterceptor(latency: Duration.zero),
          )
          ..interceptors.add(const ApiInterceptor());
  });

  group('MockApiInterceptor', () {
    test('/auth/login with admin/admin returns 200 + tokens', () async {
      final res = await dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: <String, dynamic>{'username': 'admin', 'password': 'admin'},
      );

      expect(res.statusCode, 200);
      expect(res.data, isNotNull);
      expect(res.data!['accessToken'], isA<String>());
      expect(res.data!['refreshToken'], isA<String>());
    });

    test(
      '/auth/login with wrong creds -> 401 -> AuthException after .asApi()',
      () async {
        Object? caught;
        try {
          await dio
              .post<Map<String, dynamic>>(
                '/auth/login',
                data: <String, dynamic>{'username': 'wrong', 'password': 'x'},
              )
              .asApi();
        } on Object catch (e) {
          caught = e;
        }

        expect(caught, isA<AuthException>());
        final ex = caught! as AuthException;
        expect(ex.code, FailureCode.auth);
        expect(ex.detail, 'Invalid username or password');
      },
    );

    test('/auth/me returns canned user', () async {
      final res = await dio.get<Map<String, dynamic>>('/auth/me');

      expect(res.statusCode, 200);
      expect(res.data!['id'], 'mock-user-1');
      expect(res.data!['name'], 'Admin');
      expect(res.data!['email'], 'admin@example.com');
    });

    test('/auth/refresh with empty token -> 401', () async {
      Object? caught;
      try {
        await dio
            .post<Map<String, dynamic>>(
              '/auth/refresh',
              data: <String, dynamic>{'refreshToken': ''},
            )
            .asApi();
      } on Object catch (e) {
        caught = e;
      }

      expect(caught, isA<AuthException>());
    });

    test('/auth/refresh with valid token -> 200 + new tokens', () async {
      final res = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: <String, dynamic>{'refreshToken': 'any-non-empty'},
      );

      expect(res.statusCode, 200);
      expect(res.data!['accessToken'], isA<String>());
    });

    test('/auth/logout returns 204', () async {
      final res = await dio.post<dynamic>('/auth/logout');
      expect(res.statusCode, 204);
    });

    group('feedback', () {
      test('GET /feedback/faqs without a query returns every FAQ', () async {
        final response = await dio.get<List<dynamic>>('/feedback/faqs');

        expect(response.statusCode, 200);
        final faqs =
            response.data!
                .map(
                  (json) => FaqItemModel.fromJson(
                    Map<String, dynamic>.from(json as Map),
                  ),
                )
                .toList();
        expect(
          faqs.map((faq) => faq.id),
          <String>['faq-submit', 'faq-history', 'faq-data'],
        );
        expect(
          faqs.singleWhere((faq) => faq.id == 'faq-data').answer,
          'The feedback request body contains only the selected category '
          'and your message.',
        );
      });

      test(
        'GET /feedback/faqs filters question, answer and tags '
        'case-insensitively',
        () async {
          final expectations = <String, String>{
            'INFORMATION': 'faq-data',
            'PROFILE': 'faq-history',
            'PRIVACY': 'faq-data',
          };

          for (final entry in expectations.entries) {
            final response = await dio.get<List<dynamic>>(
              '/feedback/faqs',
              queryParameters: <String, dynamic>{'q': entry.key},
            );

            expect(
              response.data!.map((json) => (json as Map)['id']),
              <String>[entry.value],
              reason: 'query=${entry.key}',
            );
          }
        },
      );

      test('GET /feedback returns deterministic parseable tickets', () async {
        final response = await dio.get<List<dynamic>>('/feedback');

        expect(response.statusCode, 200);
        final tickets =
            response.data!
                .map(
                  (json) => FeedbackTicketModel.fromJson(
                    Map<String, dynamic>.from(json as Map),
                  ),
                )
                .toList();
        expect(tickets.map((ticket) => ticket.id), <String>[
          'feedback-1002',
          'feedback-1001',
        ]);
        expect(tickets.first.category, FeedbackCategory.suggestion);
        expect(tickets.first.status, FeedbackStatus.reviewing);
        expect(tickets.first.createdAt.isUtc, isTrue);
        expect(tickets.last.reply, isNotNull);
      });

      test('GET /feedback/{id} returns a parseable ticket', () async {
        final response = await dio.get<Map<String, dynamic>>(
          '/feedback/feedback-1001',
        );

        expect(response.statusCode, 200);
        final ticket = FeedbackTicketModel.fromJson(response.data!);
        expect(ticket.id, 'feedback-1001');
        expect(ticket.category, FeedbackCategory.bug);
        expect(ticket.status, FeedbackStatus.resolved);
        expect(ticket.createdAt.isUtc, isTrue);
        expect(ticket.reply, isNotNull);
      });

      test(
        'GET /feedback/{id} missing -> 404 -> BadResponseException after '
        '.asApi()',
        () async {
          await expectLater(
            dio.get<Map<String, dynamic>>('/feedback/missing-ticket').asApi(),
            throwsA(
              isA<BadResponseException>()
                  .having(
                    (exception) => exception.code,
                    'code',
                    FailureCode.badResponse,
                  )
                  .having(
                    (exception) => exception.detail,
                    'detail',
                    'Feedback ticket not found',
                  ),
            ),
          );
        },
      );

      test('POST /feedback accepts and echoes every valid category', () async {
        for (final category in FeedbackCategory.values) {
          final response = await dio.post<Map<String, dynamic>>(
            '/feedback',
            data: <String, dynamic>{
              'category': category.name,
              'message': '  Message for ${category.name}.  ',
            },
          );

          expect(response.statusCode, 201, reason: 'category=$category');
          final ticket = FeedbackTicketModel.fromJson(response.data!);
          expect(ticket.id, startsWith('feedback-'));
          expect(ticket.category, category);
          expect(ticket.message, 'Message for ${category.name}.');
          expect(ticket.status, FeedbackStatus.submitted);
          expect(ticket.createdAt.isUtc, isTrue);
          expect(ticket.reply, isNull);
        }
      });

      test(
        'consecutive submissions use deterministic unique IDs per interceptor',
        () async {
          Future<String> submit(Dio client, String message) async {
            final response = await client.post<Map<String, dynamic>>(
              '/feedback',
              data: <String, dynamic>{
                'category': 'other',
                'message': message,
              },
            );
            return response.data!['id']! as String;
          }

          final firstId = await submit(dio, 'First report');
          final secondId = await submit(dio, 'Second report');

          final otherDio =
              Dio(BaseOptions(baseUrl: 'https://example.invalid'))
                ..interceptors.add(
                  MockApiInterceptor(latency: Duration.zero),
                )
                ..interceptors.add(const ApiInterceptor());
          addTearDown(() => otherDio.close(force: true));
          final otherFirstId = await submit(otherDio, 'Independent report');

          expect(
            <String>[firstId, secondId],
            <String>[
              'feedback-1003',
              'feedback-1004',
            ],
          );
          expect(otherFirstId, 'feedback-1003');

          final originalList = await dio.get<List<dynamic>>('/feedback');
          final otherList = await otherDio.get<List<dynamic>>('/feedback');
          expect(
            originalList.data!.map((json) => (json as Map)['id']),
            <String>[
              'feedback-1004',
              'feedback-1003',
              'feedback-1002',
              'feedback-1001',
            ],
          );
          expect(
            otherList.data!.map((json) => (json as Map)['id']),
            <String>['feedback-1003', 'feedback-1002', 'feedback-1001'],
          );
        },
      );

      test(
        'submitted feedback is readable from the list and detail endpoints',
        () async {
          final submitResponse = await dio.post<Map<String, dynamic>>(
            '/feedback',
            data: <String, dynamic>{
              'category': 'bug',
              'message': '  The save button is unresponsive.  ',
            },
          );
          final submitted = FeedbackTicketModel.fromJson(
            submitResponse.data!,
          );

          final listResponse = await dio.get<List<dynamic>>('/feedback');
          final tickets =
              listResponse.data!
                  .map(
                    (json) => FeedbackTicketModel.fromJson(
                      Map<String, dynamic>.from(json as Map),
                    ),
                  )
                  .toList();

          expect(tickets, hasLength(3));
          expect(tickets.first, submitted);

          final detailResponse = await dio.get<Map<String, dynamic>>(
            '/feedback/${submitted.id}',
          );
          final detail = FeedbackTicketModel.fromJson(detailResponse.data!);
          expect(detail, submitted);
        },
      );

      test(
        'POST /feedback with a blank message -> 400 -> '
        'BadResponseException after .asApi()',
        () async {
          await expectLater(
            dio
                .post<Map<String, dynamic>>(
                  '/feedback',
                  data: <String, dynamic>{
                    'category': 'other',
                    'message': '  \n  ',
                  },
                )
                .asApi(),
            throwsA(
              isA<BadResponseException>()
                  .having(
                    (exception) => exception.code,
                    'code',
                    FailureCode.badResponse,
                  )
                  .having(
                    (exception) => exception.detail,
                    'detail',
                    'Feedback message is required',
                  ),
            ),
          );
        },
      );

      test(
        'POST /feedback with an unknown category -> 400 -> '
        'BadResponseException after .asApi()',
        () async {
          await expectLater(
            dio
                .post<Map<String, dynamic>>(
                  '/feedback',
                  data: <String, dynamic>{
                    'category': 'unknown',
                    'message': 'A valid message',
                  },
                )
                .asApi(),
            throwsA(
              isA<BadResponseException>().having(
                (exception) => exception.detail,
                'detail',
                'Invalid feedback category',
              ),
            ),
          );
        },
      );

      test(
        'body-reading endpoints reject unencodable JSON with a clear 400',
        () async {
          for (final path in <String>[
            '/feedback',
            '/auth/login',
            '/auth/refresh',
          ]) {
            await expectLater(
              dio.post<Map<String, dynamic>>(path, data: Object()).asApi(),
              throwsA(
                isA<BadResponseException>()
                    .having(
                      (exception) => exception.code,
                      'code',
                      FailureCode.badResponse,
                    )
                    .having(
                      (exception) => exception.detail,
                      'detail',
                      'Invalid JSON request body',
                    ),
              ),
              reason: 'path=$path',
            );
          }
        },
      );

      test(
        'POST /feedback still treats null and an empty map as empty',
        () async {
          for (final body in <Object?>[null, <String, dynamic>{}]) {
            await expectLater(
              dio.post<Map<String, dynamic>>('/feedback', data: body).asApi(),
              throwsA(
                isA<BadResponseException>().having(
                  (exception) => exception.detail,
                  'detail',
                  'Feedback message is required',
                ),
              ),
            );
          }
        },
      );
    });

    test('non-auth path falls through (would hit network)', () async {
      // 我们通过 BaseUrl 指向 invalid 域名 + connectTimeout 极短来证明
      // 非 auth 路径不会被短路。直接断言抛 DioException。
      dio.options.connectTimeout = const Duration(milliseconds: 200);
      await expectLater(
        dio.get<dynamic>('/users/42'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
