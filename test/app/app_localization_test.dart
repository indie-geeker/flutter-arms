import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_arms/app/app.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class _MockKvStorage extends Mock implements KvStorage {}

void main() {
  late _MockKvStorage mockKvStorage;

  setUp(() {
    AppEnv.setup(flavor: AppFlavor.dev);
    LocaleSettings.setLocaleSync(AppLocale.en);
    mockKvStorage = _MockKvStorage();
    when(() => mockKvStorage.getAccessToken()).thenReturn(null);
    when(() => mockKvStorage.getRefreshToken()).thenReturn(null);
    when(() => mockKvStorage.getUserMap()).thenReturn(null);
    when(() => mockKvStorage.getThemeMode()).thenReturn(ThemeMode.system);
    when(
      () => mockKvStorage.getThemeSeedColor(),
    ).thenReturn(const Color(0xFF1D4ED8));
    when(() => mockKvStorage.isOnboardingDone()).thenReturn(true);
  });

  testWidgets('wraps the router with translation provider and locale data', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [kvStorageProvider.overrideWithValue(mockKvStorage)],
        child: const App(),
      ),
    );

    expect(find.byType(TranslationProvider), findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.locale, AppLocale.en.flutterLocale);
    expect(materialApp.supportedLocales, AppLocaleUtils.supportedLocales);
    expect(materialApp.localizationsDelegates, isNotEmpty);
  });
}
