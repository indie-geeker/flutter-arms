import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('should hold data when success', () {
      const result = Result<int>.success(10);

      expect(result.isSuccess, isTrue);
      expect(result.data, 10);
      expect(result.failure, isNull);
    });

    test('should hold failure when failure', () {
      const result = Result<int>.failure(
        Failure(code: FailureCode.network, detail: 'network error'),
      );

      expect(result.isFailure, isTrue);
      expect(result.data, isNull);
      expect(result.failure, isA<Failure>());
      expect(result.failure?.code, FailureCode.network);
      expect(result.failure?.detail, 'network error');
    });
  });
}
