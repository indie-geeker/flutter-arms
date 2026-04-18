import 'package:flutter/material.dart';
import 'package:flutter_arms/shared/widgets/app_button.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('should call onPressed when not loading and enabled', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            text: '登录',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('登录'));

    expect(tapped, isTrue);
  });

  testWidgets('should disable tap when loading', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            text: '登录',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(tapped, isFalse);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
