import 'package:example/src/core/constants/storage_keys.dart';
import 'package:example/src/core/theme/app_color_scheme.dart';
import 'package:example/src/features/settings/data/repositories/theme_preferences_repository_impl.dart';
import 'package:example/src/features/settings/domain/repositories/theme_preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/test_doubles.dart';

void main() {
  group('ThemePreferencesRepositoryImpl', () {
    test('loads defaults when storage is empty', () async {
      final storage = InMemoryKeyValueStorage();
      final ThemePreferencesRepository repository =
          ThemePreferencesRepositoryImpl(storage);

      final preferences = await repository.load();

      expect(preferences.themeMode, ThemeMode.system);
      expect(preferences.colorScheme, AppColorScheme.blue);
    });

    test('loads persisted values and writes updates', () async {
      final storage = InMemoryKeyValueStorage();
      await storage.setJson(StorageKeys.themePreferences, {
        'themeMode': ThemeMode.dark.name,
        'colorScheme': AppColorScheme.green.name,
      });

      final ThemePreferencesRepository repository =
          ThemePreferencesRepositoryImpl(storage);

      final loaded = await repository.load();
      expect(loaded.themeMode, ThemeMode.dark);
      expect(loaded.colorScheme, AppColorScheme.green);

      await repository.saveThemeMode(ThemeMode.light);
      await repository.saveColorScheme(AppColorScheme.orange);

      expect(await storage.getJson(StorageKeys.themePreferences), {
        'themeMode': ThemeMode.light.name,
        'colorScheme': AppColorScheme.orange.name,
      });
    });

    test('falls back to defaults on invalid persisted payload', () async {
      final storage = InMemoryKeyValueStorage();
      await storage.setJson(StorageKeys.themePreferences, {
        'themeMode': 'invalid-mode',
        'colorScheme': 'invalid-scheme',
      });

      final ThemePreferencesRepository repository =
          ThemePreferencesRepositoryImpl(storage);

      final loaded = await repository.load();
      expect(loaded.themeMode, ThemeMode.system);
      expect(loaded.colorScheme, AppColorScheme.blue);
    });
  });
}
