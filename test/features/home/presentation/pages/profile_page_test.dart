import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/home/presentation/pages/profile_page.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/super_overlay_test_app.dart';

class _MockKvStorage extends Mock implements KvStorage {}

/// Pumps ProfilePage with all required providers wired.
Future<void> _pumpProfilePage(
  WidgetTester tester,
  _MockKvStorage storage, {
  AppFlavor flavor = AppFlavor.dev,
}) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          kvStorageProvider.overrideWithValue(storage),
          appEnvProvider.overrideWithValue(AppEnv.fromFlavor(flavor)),
        ],
        child: const SuperOverlayTestApp(home: ProfilePage()),
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
  when(s.getAccessToken).thenReturn(null);
  when(s.getUserMap).thenReturn(null);
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

      // Commercial account summary (未登录 → 显示 Guest)
      expect(find.byKey(const Key('profileAccountCard')), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Guest'), findsOneWidget);

      // Appearance section
      expect(
        find.byKey(const Key('profileAppearanceSection')),
        findsOneWidget,
      );
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme mode'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Theme color'), findsOneWidget);

      // General section
      expect(find.byKey(const Key('profileGeneralSection')), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('中文'), findsOneWidget);

      // Support section is available in every flavor.
      await tester.scrollUntilVisible(
        find.text('Help & Feedback'),
        120,
        scrollable: find.byType(Scrollable),
      );
      expect(find.byKey(const Key('profileSupportSection')), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Help & Feedback'), findsOneWidget);

      // Dev-only section
      await tester.scrollUntilVisible(
        find.text('Developer'),
        120,
        scrollable: find.byType(Scrollable),
      );
      expect(
        find.byKey(const Key('profileDeveloperSection')),
        findsOneWidget,
      );
      expect(find.text('Developer'), findsOneWidget);
      expect(find.text('Feature Showcase'), findsOneWidget);

      // Logout button
      await tester.scrollUntilVisible(
        find.text('Logout'),
        120,
        scrollable: find.byType(Scrollable),
      );
      expect(find.byKey(const Key('profileLogoutButton')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('profileLogoutButton')),
          matching: find.byType(OutlinedButton),
        ),
        findsOneWidget,
      );
      expect(find.text('Logout'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('theme colors expose 48dp touch targets', (tester) async {
      final storage = _stubStorage();
      await _pumpProfilePage(tester, storage);

      final purpleTarget = find.byKey(
        ValueKey<String>(
          'profile-theme-color-${const Color(0xFF7C3AED).toARGB32()}',
        ),
      );
      expect(purpleTarget, findsOneWidget);
      expect(tester.getSize(purpleTarget), const Size.square(48));

      final semantics = tester.getSemantics(purpleTarget);
      final flags = semantics.getSemanticsData().flagsCollection;
      expect(flags.isButton, isTrue);
      expect(flags.isSelected, ui.Tristate.isFalse);
    });

    testWidgets('hides showcase entry outside dev flavor', (tester) async {
      final storage = _stubStorage();
      await _pumpProfilePage(tester, storage, flavor: AppFlavor.prod);

      expect(find.text('Developer'), findsNothing);
      expect(find.text('Feature Showcase'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Help & Feedback'),
        120,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Help & Feedback'), findsOneWidget);
    });

    testWidgets('localizes the support and developer sections in Chinese', (
      tester,
    ) async {
      final storage = _stubStorage();
      when(storage.getLocale).thenReturn('zh');
      await tester.runAsync(() => LocaleSettings.setLocale(AppLocale.zh));

      await _pumpProfilePage(tester, storage);

      await tester.scrollUntilVisible(
        find.text('帮助与反馈'),
        120,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('支持'), findsOneWidget);
      expect(find.text('帮助与反馈'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('开发者'),
        120,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('功能展示'), findsOneWidget);
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

    testWidgets('custom color cancel does not update the theme color', (
      tester,
    ) async {
      final storage = _stubStorage();
      await _pumpProfilePage(tester, storage);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);

      tester
          .widget<MaterialPicker>(find.byType(MaterialPicker))
          .onColorChanged(const Color(0xFFEF4444));
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => storage.setThemeSeedColor(any()));
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('custom color confirm returns and applies the selected color', (
      tester,
    ) async {
      final storage = _stubStorage();
      const selectedColor = Color(0xFFEF4444);
      when(
        () => storage.setThemeSeedColor(any()),
      ).thenAnswer((_) async {});
      await _pumpProfilePage(tester, storage);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      tester
          .widget<MaterialPicker>(find.byType(MaterialPicker))
          .onColorChanged(selectedColor);
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      verify(() => storage.setThemeSeedColor(selectedColor)).called(1);
      expect(find.byType(AlertDialog), findsNothing);
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
