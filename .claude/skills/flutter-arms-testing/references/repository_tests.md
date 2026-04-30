# Repository tests

Repositories are the boundary between Data and Domain. Tests verify:

1. Success path: remote+local calls happen in the right order, Result.success carries the mapped Entity.
2. Failure path: `AppException` from the remote (via `.asApi()`) becomes `Result.failure(Failure.fromException(e))` with the right `FailureCode`.
3. Partial-failure path (for logout-style methods): remote fails but local cleanup still runs.

## File location

`test/features/<f>/data/repositories/<f>_repository_impl_test.dart` — mirrors `lib/` exactly.

## Setup skeleton

```dart
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/features/<f>/data/datasources/<f>_local_datasource.dart';
import 'package:flutter_arms/features/<f>/data/datasources/<f>_remote_datasource.dart';
import 'package:flutter_arms/features/<f>/data/models/<f>_dto.dart';
import 'package:flutter_arms/features/<f>/data/repositories/<f>_repository_impl.dart';
import 'package:flutter_arms/features/<f>/domain/entities/<f>.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

class _MockRemote extends Mock implements <F>RemoteDataSource {}
class _MockLocal extends Mock implements <F>LocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late Talker logger;
  late <F>RepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    logger = Talker(settings: TalkerSettings(enabled: false));
    repository = <F>RepositoryImpl(remote, local, logger);
  });

  // groups follow...
}
```

Key points:

- **Mock classes are private** (leading underscore) — they never leave the test file.
- **`Talker` is real, just with `enabled: false`** — cheaper than mocking.
- **Instantiate the real Repository** — we're testing IT, not the DataSources.
- **`setUp` runs before each test**; each test gets fresh mocks.

## Happy-path test

```dart
group('getPost', () {
  const postDto = PostDto(id: '1', title: 'Hello');
  const expectedPost = Post(id: '1', title: 'Hello');

  test('should return post on successful remote fetch', () async {
    when(() => remote.getPost('1')).thenAnswer((_) async => postDto);

    final result = await repository.getPost('1');

    expect(result.isSuccess, isTrue);
    expect(result.data, expectedPost);
  });
});
```

## Failure-path tests

For each `FailureCode` the method can produce, write a test.

```dart
test('should return auth failure when remote throws AuthException', () async {
  when(() => remote.getPost('1')).thenAnswer(
    (_) => Future<PostDto>.error(
      const AuthException(detail: 'token expired'),
    ),
  );

  final result = await repository.getPost('1');

  expect(result.isFailure, isTrue);
  expect(result.failure?.code, FailureCode.auth);
  expect(result.failure?.detail, 'token expired');
});
```

For the generic "any exception becomes unknown" test — important because `.asApi()` converts non-`AppException` errors into `UnknownException`:

```dart
test('should return unknown failure when remote throws generic exception', () async {
  when(() => remote.getPost('1')).thenAnswer(
    (_) => Future<PostDto>.error(Exception('unexpected')),
  );

  final result = await repository.getPost('1');

  expect(result.isFailure, isTrue);
  expect(result.failure?.code, FailureCode.unknown);
});
```

This is the test from `auth_repository_impl_test.dart` — it exercises the `.asApi()` catch-all path.

## Partial-failure test (logout-style)

When the method tolerates remote failures but always performs local cleanup:

```dart
test('should still clear local auth when remote logout fails', () async {
  when(() => remote.logout())
      .thenAnswer((_) => Future<void>.error(Exception('network down')));
  when(() => local.clearAuth()).thenAnswer((_) async {});

  await repository.logout();

  verify(() => remote.logout()).called(1);
  verify(() => local.clearAuth()).called(1);
});
```

`verify(() => ...).called(1)` asserts the mock was invoked exactly once.

## Stubbing guidance

- `thenAnswer((_) async => value)` for successful futures.
- `thenAnswer((_) => Future<T>.error(e))` for errors. Note the explicit `Future<T>` — Dart needs the type to resolve the error future.
- `thenReturn(value)` for synchronous returns (e.g. `local.getUser()`).
- `when(s.method)` (no parens, no lambda) works for no-arg getters — `when(s.getThemeMode).thenReturn(...)`. For methods with args, use `when(() => s.method(arg))`.
- **Don't stub method calls you don't make in the test** — noise hides what matters.

## mocktail fallback values

For non-primitive argument matchers (`any()` on custom types), register in `setUpAll`:

```dart
class _FakeRequestOptions extends Fake implements RequestOptions {}

setUpAll(() {
  registerFallbackValue(_FakeRequestOptions());
  registerFallbackValue(Colors.transparent); // for Color arguments
});
```

You'll see `type 'Null' is not a subtype of type 'X'` if a fallback is missing.

## Testing the `.asApi()` unwrap directly

Usually not needed — Repository tests cover it indirectly. If you do want to test `.asApi()` in isolation, see existing tests in `test/core/network/` or `test/core/error/app_exception_mapper_test.dart` for the mapping rules.

## Coverage checklist for a Repository method

- [ ] Happy path: remote returns → Result.success with mapped Entity.
- [ ] Network failure: `NetworkException` → `FailureCode.network`.
- [ ] Timeout: `TimeoutException` → `FailureCode.timeout`.
- [ ] Bad response (e.g. 500): `BadResponseException` → `FailureCode.badResponse`, with `detail` passed through.
- [ ] Unauthorized (401): `AuthException` → `FailureCode.auth`.
- [ ] Generic exception: any `Exception` → `FailureCode.unknown` (covers `.asApi()` fallback).
- [ ] If the method also writes locally: verify local writes happen only on success (or always, for partial-failure methods).
