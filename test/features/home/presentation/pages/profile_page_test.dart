import 'package:flutter/material.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/home/presentation/pages/profile_page.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockKvStorage extends Mock implements KvStorage {}

/// Pumps ProfilePage with all required providers wired.
Future<void> _pumpProfilePage(
  WidgetTester tester,
  _MockKvStorage storage,
) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [kvStorageProvider.overrideWithValue(storage)],
        child: const MaterialApp(home: ProfilePage()),
      ),
    ),
  );
}

/// Returns a fully stubbed MockKvStorage for ProfilePage.
_MockKvStorage _stubStorage() {
  final s = _MockKvStorage();
  when(s.getThemeMode).thenReturn(ThemeMode.system);
  when(s.getThemeSeedColor).thenReturn(const Color(0xFF1D4ED8));
  when(s.getLocale).thenReturn(null); // defaults to AppLocale.en
  return s;
}

void main() {
  setUpAll(() {
    registerFallbackValue(Colors.transparent);
  });

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  group('ProfilePage', () {
    testWidgets('renders all sections', (tester) async {
      final storage = _stubStorage();
      await _pumpProfilePage(tester, storage);

      // User header
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('User'), findsOneWidget);

      // Appearance section
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme mode'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Theme color'), findsOneWidget);

      // General section
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('中文'), findsOneWidget);

      // Logout button
      expect(find.text('Logout'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('tapping a preset color circle calls setSeedColor', (
      tester,
    ) async {
      final storage = _stubStorage();
      Color? capturedColor;
      when(() => storage.setThemeSeedColor(any())).thenAnswer((inv) async {
        capturedColor = inv.positionalArguments.first as Color;
      });
      await _pumpProfilePage(tester, storage);

      // Find the purple color circle by its BoxDecoration color (0xFF7C3AED).
      // Each preset circle is a Container with BoxDecoration(color: ..., shape: circle).
      final purpleCircle = find.byWidgetPredicate((widget) {
        if (widget is Container) {
          final decoration = widget.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == const Color(0xFF7C3AED);
          }
        }
        return false;
      });
      expect(purpleCircle, findsOneWidget);
      await tester.tap(purpleCircle);
      await tester.pump();

      expect(capturedColor, equals(const Color(0xFF7C3AED)));
    });

    testWidgets('tapping custom color button opens color picker dialog', (
      tester,
    ) async {
      final storage = _stubStorage();
      await _pumpProfilePage(tester, storage);

      // Tap the '+' custom color circle
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Dialog should be open — MaterialPicker is in an AlertDialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('system theme mode is selected by default', (tester) async {
      final storage = _stubStorage(); // returns ThemeMode.system
      await _pumpProfilePage(tester, storage);

      final segmented = tester.widget<SegmentedButton<ThemeMode>>(
        find.byType(SegmentedButton<ThemeMode>),
      );
      expect(segmented.selected, equals({ThemeMode.system}));
    });

    testWidgets('English locale is selected by default', (tester) async {
      final storage = _stubStorage(); // getLocale returns null → AppLocale.en
      await _pumpProfilePage(tester, storage);

      final segmented = tester.widget<SegmentedButton<AppLocale>>(
        find.byType(SegmentedButton<AppLocale>),
      );
      expect(segmented.selected, equals({AppLocale.en}));
    });
  });
}
