import 'package:example/l10n/app_localizations.dart';
import 'package:example/src/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Integration test: full login → home → logout flow.
///
/// This test exercises the complete authentication lifecycle through
/// the real UI, confirming navigation, form validation, and state
/// transitions work end-to-end.
///
/// Runs against the app with `enableFullStackProfile: false` so that
/// only Logger + Storage modules are loaded (no network needed).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login flow', () {
    testWidgets('shows LoginScreen on launch', (tester) async {
      await _pumpApp(tester);

      // Verify we are on the login screen
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeast(2));
    });

    testWidgets('login button is disabled when fields are empty', (
      tester,
    ) async {
      await _pumpApp(tester);

      // The login button should be disabled (onPressed == null)
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).first,
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('login succeeds and navigates to HomeScreen', (tester) async {
      await _pumpApp(tester);

      // Enter valid credentials (≥3 chars each)
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'alice',
      );
      await tester.pump();

      await tester.enterText(
        find.byType(TextFormField).at(1),
        'secret',
      );
      await tester.pump();

      // Tap the login button
      final loginButton = find.byType(ElevatedButton).first;
      await tester.tap(loginButton);

      // Wait for async login + navigation
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we navigated to HomeScreen
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('alice'), findsOneWidget);
    });

    testWidgets('logout returns to LoginScreen', (tester) async {
      await _pumpApp(tester);

      // Login first
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'alice',
      );
      await tester.pump();
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'secret',
      );
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Now on HomeScreen — tap the logout icon in AppBar
      await tester.tap(find.byIcon(Icons.logout).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should return to LoginScreen
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });
  });
}

/// Pump the app with minimal profile (no network).
Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    const ArmsApp(enableFullStackProfile: false),
  );
  // Wait for module initialization to complete
  await tester.pumpAndSettle(const Duration(seconds: 3));
}
