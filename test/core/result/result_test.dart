import 'package:flutter_arms/core/error/failures.dart';
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
        NetworkFailure('network error'),
      );

      expect(result.isFailure, isTrue);
      expect(result.data, isNull);
      expect(result.failure, isA<NetworkFailure>());
      expect(result.failure?.message, 'network error');
    });
  });
}
