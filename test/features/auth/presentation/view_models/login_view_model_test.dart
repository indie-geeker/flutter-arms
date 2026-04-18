import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_arms/features/auth/domain/entities/user.dart';
import 'package:flutter_arms/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_arms/features/auth/presentation/view_models/login_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late _MockLoginUseCase mockLoginUseCase;

  setUp(() {
    mockLoginUseCase = _MockLoginUseCase();
  });

  test('should update state to success when login succeeds', () async {
    when(
      () => mockLoginUseCase(username: 'tester', password: '123456'),
    ).thenAnswer(
      (_) async => const Result.success(
        User(id: '1', name: 'Tester', email: 'tester@example.com'),
      ),
    );

    final container = ProviderContainer(
      overrides: [loginUseCaseProvider.overrideWithValue(mockLoginUseCase)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(loginViewModelProvider.notifier);
    notifier.updateUsername('tester');
    notifier.updatePassword('123456');

    await notifier.login();

    final state = container.read(loginViewModelProvider);
    expect(state.isLoading, isFalse);
    expect(state.isLoginSuccess, isTrue);
    expect(state.error, isNull);
  });

  test('should set typed failure when login fails', () async {
    when(
      () => mockLoginUseCase(username: 'tester', password: 'wrong'),
    ).thenAnswer(
      (_) async => const Result.failure(
        Failure(code: FailureCode.auth, detail: 'invalid credentials'),
      ),
    );

    final container = ProviderContainer(
      overrides: [loginUseCaseProvider.overrideWithValue(mockLoginUseCase)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(loginViewModelProvider.notifier);
    notifier.updateUsername('tester');
    notifier.updatePassword('wrong');

    await notifier.login();

    final state = container.read(loginViewModelProvider);
    expect(state.isLoading, isFalse);
    expect(state.isLoginSuccess, isFalse);
    expect(state.error?.code, FailureCode.auth);
    expect(state.error?.detail, 'invalid credentials');
  });

  test(
    'should set validation failure when username or password is empty',
    () async {
      final container = ProviderContainer(
        overrides: [loginUseCaseProvider.overrideWithValue(mockLoginUseCase)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(loginViewModelProvider.notifier);
      await notifier.login();

      final state = container.read(loginViewModelProvider);
      expect(state.error?.code, FailureCode.validation);
      verifyNever(
        () => mockLoginUseCase(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      );
    },
  );
}
