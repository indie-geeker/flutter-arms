import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_arms/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_arms/features/auth/presentation/view_models/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogoutUseCase extends Mock implements LogoutUseCase {}

class _MockKvStorage extends Mock implements KvStorage {}

void main() {
  late _MockLogoutUseCase mockLogoutUseCase;
  late _MockKvStorage mockKvStorage;

  setUp(() {
    mockLogoutUseCase = _MockLogoutUseCase();
    mockKvStorage = _MockKvStorage();
  });

  test('build returns true when access token is present', () {
    when(() => mockKvStorage.getAccessToken()).thenReturn('some-token');

    final container = ProviderContainer(
      overrides: [kvStorageProvider.overrideWithValue(mockKvStorage)],
    );
    addTearDown(container.dispose);

    expect(container.read(authProvider), isTrue);
  });

  test('build returns false when access token is missing', () {
    when(() => mockKvStorage.getAccessToken()).thenReturn(null);

    final container = ProviderContainer(
      overrides: [kvStorageProvider.overrideWithValue(mockKvStorage)],
    );
    addTearDown(container.dispose);

    expect(container.read(authProvider), isFalse);
  });

  test('logout calls use case and clears auth flag', () async {
    when(() => mockKvStorage.getAccessToken()).thenReturn('some-token');
    when(() => mockLogoutUseCase()).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        kvStorageProvider.overrideWithValue(mockKvStorage),
        logoutUseCaseProvider.overrideWithValue(mockLogoutUseCase),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(authProvider), isTrue);

    await container.read(authProvider.notifier).logout();

    verify(() => mockLogoutUseCase()).called(1);
    expect(container.read(authProvider), isFalse);
  });
}
