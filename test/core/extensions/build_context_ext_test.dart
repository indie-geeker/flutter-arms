import 'package:flutter/material.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/extensions/build_context_ext.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('auth failure uses server detail when provided', (tester) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(
      capturedContext.failureMessage(
        const Failure(
          code: FailureCode.auth,
          detail: 'Invalid username or password',
        ),
      ),
      'Invalid username or password',
    );
  });
}
