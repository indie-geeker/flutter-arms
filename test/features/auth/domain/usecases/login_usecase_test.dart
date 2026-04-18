import 'package:flutter_arms/core/error/failures.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/auth/domain/entities/user.dart';
import 'package:flutter_arms/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_arms/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late LoginUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  test('should return user when repository login succeeds', () async {
    const expected = User(id: '1', name: 'Tester', email: 'tester@example.com');
    when(
      () => repository.login(username: 'tester', password: '123456'),
    ).thenAnswer((_) async => const Result.success(expected));

    final result = await useCase(username: 'tester', password: '123456');

    expect(result.isSuccess, isTrue);
    expect(result.data, expected);
  });

  test('should return failure when repository login fails', () async {
    when(
      () => repository.login(username: 'tester', password: 'wrong'),
    ).thenAnswer(
      (_) async => const Result.failure(AuthFailure('invalid credentials')),
    );

    final result = await useCase(username: 'tester', password: 'wrong');

    expect(result.isFailure, isTrue);
    expect(result.failure, isA<AuthFailure>());
    expect(result.failure?.message, 'invalid credentials');
  });
}
