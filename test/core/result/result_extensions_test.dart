import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const successResult = Result<int>.success(10);
  const failureResult = Result<int>.failure(Failure(code: FailureCode.network));

  group('Result.when', () {
    test('invokes success branch', () {
      final value = successResult.when(
        success: (d) => 'ok: $d',
        failure: (f) => 'err: ${f.code}',
      );
      expect(value, 'ok: 10');
    });

    test('invokes failure branch', () {
      final value = failureResult.when(
        success: (d) => 'ok',
        failure: (f) => 'err: ${f.code}',
      );
      expect(value, 'err: FailureCode.network');
    });
  });

  group('Result.map', () {
    test('transforms success data', () {
      final mapped = successResult.map((d) => d * 2);
      expect(mapped.data, 20);
    });

    test('passes failure through unchanged', () {
      final mapped = failureResult.map((d) => d * 2);
      expect(mapped.failure?.code, FailureCode.network);
    });
  });

  group('Result.mapFailure', () {
    test('transforms failure', () {
      final mapped = failureResult.mapFailure(
        (f) => const Failure(code: FailureCode.auth),
      );
      expect(mapped.failure?.code, FailureCode.auth);
    });

    test('passes success through unchanged', () {
      final mapped = successResult.mapFailure(
        (f) => const Failure(code: FailureCode.auth),
      );
      expect(mapped.data, 10);
    });
  });

  group('Result.getOrElse / getOrNull', () {
    test('getOrElse returns data on success', () {
      expect(successResult.getOrElse(-1), 10);
    });

    test('getOrElse returns fallback on failure', () {
      expect(failureResult.getOrElse(-1), -1);
    });

    test('getOrNull returns data on success', () {
      expect(successResult.getOrNull(), 10);
    });

    test('getOrNull returns null on failure', () {
      expect(failureResult.getOrNull(), isNull);
    });
  });
}
