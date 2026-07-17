import 'package:flutter/material.dart';
import 'package:flutter_arms/features/showcase/presentation/pages/showcase_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/super_overlay_test_app.dart';

Widget _buildTestApp() {
  return const SuperOverlayTestApp(
    home: ShowcasePage(),
  );
}

Widget _buildSwitchableTestApp(ValueNotifier<bool> showPage) {
  return SuperOverlayTestApp(
    home: ValueListenableBuilder<bool>(
      valueListenable: showPage,
      builder:
          (_, visible, _) =>
              visible
                  ? const ShowcasePage()
                  : const Scaffold(body: Center(child: Text('Page left'))),
    ),
  );
}

Future<void> _finishDemoRequest(WidgetTester tester) async {
  // Advance the demo API's deterministic fake latency without a wall-clock wait.
  await tester.pump(const Duration(milliseconds: 650));
  await tester.pumpAndSettle(
    const Duration(milliseconds: 16),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 1),
  );
}

Future<void> _disposeTestApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

void main() {
  group('ShowcasePage', () {
    testWidgets('renders the network feedback demo surface', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      expect(find.text('Feature Showcase'), findsOneWidget);
      expect(find.text('Network + Global Feedback'), findsOneWidget);
      expect(find.text('Refresh data'), findsOneWidget);
      expect(find.text('Simulate failure'), findsOneWidget);
      expect(find.text('Submit action'), findsOneWidget);
      expect(find.text('Show request popup'), findsOneWidget);
    });

    testWidgets('refresh request shows loading and success toast', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());

      await tester.tap(find.text('Refresh data'));
      await tester.pump();

      expect(find.text('Requesting /api/showcase'), findsOneWidget);

      await _finishDemoRequest(tester);

      expect(find.text('Requesting /api/showcase'), findsNothing);
      expect(find.text('Loaded 3 records'), findsOneWidget);
      expect(find.text('Conversion rate'), findsOneWidget);

      await _disposeTestApp(tester);
    });

    testWidgets('failure request shows error state and toast', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      await tester.tap(find.text('Simulate failure'));
      await tester.pump();

      expect(find.text('Requesting /api/showcase'), findsOneWidget);

      await _finishDemoRequest(tester);

      expect(find.text('Requesting /api/showcase'), findsNothing);
      expect(
        find.text('Request failed and rendered an error state'),
        findsOneWidget,
      );
      expect(find.text('Service unavailable'), findsOneWidget);

      await _disposeTestApp(tester);
    });

    testWidgets('popup and confirm dialog are available from the demo', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());

      await tester.tap(find.text('Show request popup'));
      await tester.pumpAndSettle();

      expect(find.text('PopupWindow: request details'), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit action'));
      await tester.pumpAndSettle();

      expect(find.text('Submit showcase action?'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('refresh completion after leaving closes global loading', (
      tester,
    ) async {
      final showPage = ValueNotifier<bool>(true);
      addTearDown(showPage.dispose);
      await tester.pumpWidget(_buildSwitchableTestApp(showPage));

      await tester.tap(find.text('Refresh data'));
      await tester.pump();
      expect(find.text('Requesting /api/showcase'), findsOneWidget);

      showPage.value = false;
      await tester.pump();
      expect(find.byType(ShowcasePage), findsNothing);
      expect(find.text('Page left'), findsOneWidget);
      expect(find.text('Requesting /api/showcase'), findsOneWidget);

      await _finishDemoRequest(tester);

      expect(find.text('Requesting /api/showcase'), findsNothing);
      expect(find.text('Loaded 3 records'), findsNothing);
    });

    testWidgets('submit completion after leaving closes global loading', (
      tester,
    ) async {
      final showPage = ValueNotifier<bool>(true);
      addTearDown(showPage.dispose);
      await tester.pumpWidget(_buildSwitchableTestApp(showPage));

      await tester.tap(find.text('Submit action'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pump();
      expect(find.text('Submitting /api/showcase'), findsOneWidget);

      showPage.value = false;
      await tester.pump();
      expect(find.byType(ShowcasePage), findsNothing);
      expect(find.text('Page left'), findsOneWidget);
      expect(find.text('Submitting /api/showcase'), findsOneWidget);

      await _finishDemoRequest(tester);

      expect(find.text('Submitting /api/showcase'), findsNothing);
      expect(find.text('Showcase action submitted'), findsNothing);
    });
  });
}
