import 'package:flutter_arms/core/error/app_exception.dart';
import 'package:flutter_arms/core/logger/app_log.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/auth/application/auth_token_refresher_impl.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_arms/features/auth/data/models/token_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockStorage extends Mock implements KvStorage {}

final class _LogEntry {
  const _LogEntry(this.message, this.error, this.stackTrace);

  final Object message;
  final Object? error;
  final StackTrace? stackTrace;
}

class _FakeAppLog implements AppLog {
  final warnings = <_LogEntry>[];

  @override
  void debug(Object message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void error(Object message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void handle(Object error, StackTrace? stackTrace, [String? context]) {}

  @override
  void info(Object message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void warning(Object message, [Object? error, StackTrace? stackTrace]) {
    warnings.add(_LogEntry(message, error, stackTrace));
  }
}

void main() {
  late _MockRemote remote;
  late _MockStorage storage;
  late _FakeAppLog logger;
  late AuthRemoteTokenRefresher refresher;

  setUp(() {
    remote = _MockRemote();
    storage = _MockStorage();
    logger = _FakeAppLog();
    refresher = AuthRemoteTokenRefresher(remote, storage, logger);
  });

  group('AuthRemoteTokenRefresher', () {
    const token = TokenModel(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    );

    test('saves refreshed tokens and returns true', () async {
      when(() => remote.refreshToken(any())).thenAnswer((_) async => token);
      when(
        () => storage.saveAccessToken(token.accessToken),
      ).thenAnswer((_) async {});
      when(
        () => storage.saveRefreshToken(token.refreshToken),
      ).thenAnswer((_) async {});

      final result = await refresher.refresh('old-refresh');

      expect(result, isTrue);
      expect(logger.warnings, isEmpty);
      verify(
        () => remote.refreshToken(<String, dynamic>{
          'refreshToken': 'old-refresh',
        }),
      ).called(1);
      verify(() => storage.saveAccessToken(token.accessToken)).called(1);
      verify(() => storage.saveRefreshToken(token.refreshToken)).called(1);
    });

    test('logs and returns false when remote refresh fails', () async {
      const exception = AuthException(detail: 'expired refresh token');
      when(() => remote.refreshToken(any())).thenThrow(exception);

      final result = await refresher.refresh('old-refresh');

      expect(result, isFalse);
      expect(logger.warnings, hasLength(1));
      expect(logger.warnings.single.message, 'auth token refresh failed');
      expect(logger.warnings.single.error, exception);
      verifyNever(() => storage.saveAccessToken(any()));
      verifyNever(() => storage.saveRefreshToken(any()));
    });

    test('logs and returns false when storage write fails', () async {
      final exception = StateError('storage unavailable');
      when(() => remote.refreshToken(any())).thenAnswer((_) async => token);
      when(
        () => storage.saveAccessToken(token.accessToken),
      ).thenThrow(exception);

      final result = await refresher.refresh('old-refresh');

      expect(result, isFalse);
      expect(logger.warnings, hasLength(1));
      expect(logger.warnings.single.message, 'auth token refresh failed');
      expect(logger.warnings.single.error, exception);
      verify(() => storage.saveAccessToken(token.accessToken)).called(1);
      verifyNever(() => storage.saveRefreshToken(any()));
    });

    test(
      'logs and returns false when refreshed access token is empty',
      () async {
        const emptyToken = TokenModel(
          accessToken: '',
          refreshToken: 'new-refresh',
        );
        when(
          () => remote.refreshToken(any()),
        ).thenAnswer((_) async => emptyToken);

        final result = await refresher.refresh('old-refresh');

        expect(result, isFalse);
        expect(logger.warnings, hasLength(1));
        expect(
          logger.warnings.single.message,
          'auth token refresh returned empty access token',
        );
        expect(logger.warnings.single.error, isNull);
        verifyNever(() => storage.saveAccessToken(any()));
        verifyNever(() => storage.saveRefreshToken(any()));
      },
    );
  });
}
