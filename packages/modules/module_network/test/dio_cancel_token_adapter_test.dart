import 'dart:async';

import 'package:module_network/src/impl/dio_cancel_token_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DioCancelTokenAdapter', () {
    test('starts as not cancelled', () {
      final token = DioCancelTokenAdapter();

      expect(token.isCancelled, isFalse);
    });

    test('cancel marks token as cancelled and notifies listeners', () async {
      final token = DioCancelTokenAdapter();
      String? reason;
      final completer = Completer<void>();
      token.addListener((value) {
        reason = value;
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      token.cancel('manual-stop');

      await completer.future.timeout(const Duration(seconds: 1));

      expect(token.isCancelled, isTrue);
      expect(reason, 'manual-stop');
      expect(token.dioToken.isCancelled, isTrue);
    });

    test('listener added after cancel is invoked immediately', () {
      final token = DioCancelTokenAdapter();
      token.cancel('late-subscriber');

      String? reason;
      token.addListener((value) => reason = value);

      expect(reason, 'late-subscriber');
    });
  });
}
