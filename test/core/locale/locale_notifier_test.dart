import 'package:flutter_arms/core/locale/locale_notifier.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockKvStorage extends Mock implements KvStorage {}

void main() {
  late _MockKvStorage mockKvStorage;
  late ProviderContainer container;

  setUp(() {
    mockKvStorage = _MockKvStorage();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  tearDown(() {
    container.dispose();
  });

  ProviderContainer createContainer() {
    return container = ProviderContainer(
      overrides: [kvStorageProvider.overrideWithValue(mockKvStorage)],
    );
  }

  group('LocaleNotifier', () {
    test('defaults to AppLocale.en when no stored locale', () {
      when(() => mockKvStorage.getLocale()).thenReturn(null);
      final c = createContainer();

      final locale = c.read(localeNotifierProvider);
      expect(locale, equals(AppLocale.en));
    });

    test('restores stored locale on build', () {
      when(() => mockKvStorage.getLocale()).thenReturn('en');
      final c = createContainer();

      final locale = c.read(localeNotifierProvider);
      expect(locale, equals(AppLocale.en));
    });

    test('setLocale updates state and persists', () async {
      when(() => mockKvStorage.getLocale()).thenReturn(null);
      when(() => mockKvStorage.setLocale(any())).thenAnswer((_) async {});
      final c = createContainer();

      final notifier = c.read(localeNotifierProvider.notifier);
      await notifier.setLocale(AppLocale.en);

      expect(c.read(localeNotifierProvider), equals(AppLocale.en));
      verify(() => mockKvStorage.setLocale('en')).called(1);
    });
  });
}
