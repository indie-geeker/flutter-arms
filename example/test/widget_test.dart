// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:app_core/app_core.dart';
import 'package:example/config/base_app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final appManager = AppManager();

    // Create a test configuration with all required parameters
    final testConfig = BaseAppConfig(
      appName: 'Test App',
      apiBaseUrl: 'https://test.example.com/api',
      apiVersion: 'v1',
      webSocketUrl: 'wss://test.example.com/ws',
      environment: EnvironmentType.development,
      channel: 'test',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      enableVerboseLogging: false,
      enableCrashReporting: false,
      enablePerformanceMonitoring: false,
      enableAnalytics: false,
      cacheMaxSizeMB: 100,
      enableEncryption: false,
      debugMode: false,
      showPerformanceOverlay: false,
    );

    await tester.pumpWidget(MyApp(
      appManager: appManager,
      appConfig: testConfig,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
