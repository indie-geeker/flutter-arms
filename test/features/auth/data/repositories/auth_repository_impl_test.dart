import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_arms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_arms/features/auth/data/models/token_model.dart';
import 'package:flutter_arms/features/auth/data/models/user_model.dart';
import 'package:flutter_arms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_arms/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockLocal extends Mock implements AuthLocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late Talker logger;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    logger = Talker(settings: TalkerSettings(enabled: false));
    repository = AuthRepositoryImpl(remote, local, logger);
  });

  group('login', () {
    const token = TokenModel(
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    const userModel = UserModel(
      id: '1',
      name: 'Alice',
      email: 'alice@example.com',
    );
    const expectedUser = User(
      id: '1',
      name: 'Alice',
      email: 'alice@example.com',
    );

    test('should return user on successful remote login', () async {
      when(() => remote.login(any())).thenAnswer((_) async => token);
      when(() => local.saveToken(token)).thenAnswer((_) async {});
      when(() => remote.me()).thenAnswer((_) async => userModel);
      when(() => local.saveUser(userModel)).thenAnswer((_) async {});

      final result = await repository.login(
        username: 'alice',
        password: 'secret',
      );

      expect(result.isSuccess, isTrue);
      expect(result.data, expectedUser);
    });

    test(
      'should return unknown failure when remote throws generic exception',
      () async {
        when(
          () => remote.login(any()),
        ).thenAnswer((_) => Future<TokenModel>.error(Exception('unexpected')));

        final result = await repository.login(
          username: 'alice',
          password: 'wrong',
        );

        expect(result.isFailure, isTrue);
        expect(result.failure?.code, FailureCode.unknown);
      },
    );
  });

  group('logout', () {
    test('should call remote logout then clear local auth', () async {
      when(() => remote.logout()).thenAnswer((_) async {});
      when(() => local.clearAuth()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => remote.logout()).called(1);
      verify(() => local.clearAuth()).called(1);
    });

    test('should still clear local auth when remote logout fails', () async {
      when(
        () => remote.logout(),
      ).thenAnswer((_) => Future<void>.error(Exception('network down')));
      when(() => local.clearAuth()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => remote.logout()).called(1);
      verify(() => local.clearAuth()).called(1);
    });
  });

  group('getCurrentUser', () {
    test('should return user from local cache', () async {
      const userModel = UserModel(
        id: '2',
        name: 'Bob',
        email: 'bob@example.com',
      );
      when(() => local.getUser()).thenReturn(userModel);

      final result = await repository.getCurrentUser();

      expect(result.isSuccess, isTrue);
      expect(
        result.data,
        const User(id: '2', name: 'Bob', email: 'bob@example.com'),
      );
    });

    test('should return auth failure when no local user', () async {
      when(() => local.getUser()).thenReturn(null);

      final result = await repository.getCurrentUser();

      expect(result.isFailure, isTrue);
      expect(result.failure?.code, FailureCode.auth);
    });
  });

  group('refreshToken', () {
    const newToken = TokenModel(
      accessToken: 'new_access',
      refreshToken: 'new_refresh',
    );

    test('should return new access token on success', () async {
      when(() => remote.refreshToken(any())).thenAnswer((_) async => newToken);
      when(() => local.saveToken(newToken)).thenAnswer((_) async {});

      final result = await repository.refreshToken('old_refresh');

      expect(result.isSuccess, isTrue);
      expect(result.data, 'new_access');
    });

    test(
      'should return unknown failure when refresh throws generic exception',
      () async {
        when(
          () => remote.refreshToken(any()),
        ).thenAnswer((_) => Future<TokenModel>.error(Exception('expired')));

        final result = await repository.refreshToken('old_refresh');

        expect(result.isFailure, isTrue);
        expect(result.failure?.code, FailureCode.unknown);
      },
    );
  });
}
