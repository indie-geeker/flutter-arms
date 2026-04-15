import 'package:flutter_arms/core/error/failures.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_arms/features/auth/domain/entities/user.dart';
import 'package:flutter_arms/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_arms/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_arms/features/auth/presentation/states/login_state.dart';
import 'package:flutter_arms/features/auth/presentation/view_models/auth_notifier.dart';
import 'package:flutter_arms/features/auth/presentation/view_models/login_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}
class _MockLogoutUseCase extends Mock implements LogoutUseCase {}
class _MockKvStorage extends Mock implements KvStorage {}

void main() {
  late _MockLoginUseCase mockLoginUseCase;
  late _MockLogoutUseCase mockLogoutUseCase;
  late _MockKvStorage mockKvStorage;

  setUp(() {
    mockLoginUseCase = _MockLoginUseCase();
    mockLogoutUseCase = _MockLogoutUseCase();
    mockKvStorage = _MockKvStorage();
    when(() => mockKvStorage.getAccessToken()).thenReturn(null);
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
    ).thenAnswer((_) async => const Result.failure(AuthFailure('invalid credentials')));

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
    expect(state.error, isA<AuthFailure>());
    expect(state.error?.message, 'invalid credentials');
  });

  test('should reset login state and auth flag when logout succeeds', () async {
    when(() => mockLogoutUseCase()).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        kvStorageProvider.overrideWithValue(mockKvStorage),
        logoutUseCaseProvider.overrideWithValue(mockLogoutUseCase),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(loginViewModelProvider.notifier);
    notifier.updateUsername('tester');
    notifier.updatePassword('123456');

    await notifier.logout();

    verify(() => mockLogoutUseCase()).called(1);
    expect(container.read(loginViewModelProvider), const LoginState());
    expect(container.read(authNotifierProvider), isFalse);
  });
}
