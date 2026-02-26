import 'package:dartz/dartz.dart';
import 'package:example/src/domain/failures/auth_failure.dart';
import 'package:example/src/domain/value_objects/password.dart';
import 'package:example/src/domain/value_objects/username.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Username', () {
    test('returns emptyUsername failure for empty input', () {
      final result = Username.create('').validate();

      expect(result, left(const AuthFailure.emptyUsername()));
    });

    test('returns invalidUsername failure for short input', () {
      final result = Username.create('ab').validate();

      expect(
        result,
        left(
          const AuthFailure.invalidUsername(
            'Username must be at least 3 characters',
          ),
        ),
      );
    });

    test('returns validated username for valid input', () {
      final result = Username.create('alice').validate();

      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse(() => Username.create('')),
        Username.create('alice'),
      );
    });
  });

  group('Password', () {
    test('returns emptyPassword failure for empty input', () {
      final result = Password.create('').validate();

      expect(result, left(const AuthFailure.emptyPassword()));
    });

    test('returns invalidPassword failure for short input', () {
      final result = Password.create('12').validate();

      expect(
        result,
        left(
          const AuthFailure.invalidPassword(
            'Password must be at least 3 characters',
          ),
        ),
      );
    });

    test('returns validated password for valid input', () {
      final password = Password.create('secret');
      final result = password.validate();

      expect(result.isRight(), isTrue);
      expect(password.toString(), '***');
    });
  });
}
