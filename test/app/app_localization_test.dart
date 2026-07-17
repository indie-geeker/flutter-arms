import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockKvStorage extends Mock implements KvStorage {}

void main() {
  late _MockKvStorage mockKvStorage;

  setUp(() {
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
    when(() => mockKvStorage.getLocale()).thenReturn(null);
  });

  testWidgets('wraps the router with translation provider and locale data', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(AppEnv.fromFlavor(AppFlavor.dev)),
          kvStorageProvider.overrideWithValue(mockKvStorage),
        ],
        child: const App(),
      ),
    );

    expect(find.byType(TranslationProvider), findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.locale, AppLocale.en.flutterLocale);
    expect(materialApp.supportedLocales, AppLocaleUtils.supportedLocales);
    expect(materialApp.localizationsDelegates, isNotEmpty);
  });

  test('home tabs and feedback flow are fully localized', () async {
    LocaleSettings.setLocaleSync(AppLocale.en);

    expect(t.home.home, 'Home');
    expect(t.home.profile, 'Profile');
    expect(t.profile.support, 'Support');
    expect(t.profile.helpFeedback, 'Help & Feedback');
    expect(t.profile.developer, 'Developer');
    expect(t.feedback.title, 'Help & Feedback');
    expect(t.feedback.searchLabel, 'Search help');
    expect(t.feedback.submitButton, 'Send feedback');
    expect(t.feedback.categories.bug, 'Bug report');
    expect(t.feedback.statuses.reviewing, 'In review');
    expect(t.feedback.messageRequired, 'Please enter your feedback.');

    await LocaleSettings.setLocale(AppLocale.zh);

    expect(t.home.home, '首页');
    expect(t.home.profile, '我的');
    expect(t.profile.support, '支持');
    expect(t.profile.helpFeedback, '帮助与反馈');
    expect(t.profile.developer, '开发者');
    expect(t.feedback.title, '帮助与反馈');
    expect(t.feedback.searchLabel, '搜索帮助');
    expect(t.feedback.submitButton, '发送反馈');
    expect(t.feedback.categories.bug, '问题反馈');
    expect(t.feedback.statuses.reviewing, '处理中');
    expect(t.feedback.messageRequired, '请输入反馈内容');
  });
}
