import 'package:example/src/shared/constants/storage_keys.dart';
import 'package:example/src/shared/theme/app_color_scheme.dart';
import 'package:example/src/features/settings/domain/repositories/theme_preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:interfaces/storage/i_kv_storage.dart';

class ThemePreferencesRepositoryImpl implements ThemePreferencesRepository {
  ThemePreferencesRepositoryImpl(this._storage);

  final IKeyValueStorage _storage;

  @override
  Future<ThemePreferences> load() async {
    final payload = await _storage.getJson(StorageKeys.themePreferences);
    final themeModeName = payload?['themeMode'];
    final colorSchemeName = payload?['colorScheme'];

    final themeMode = ThemeMode.values.firstWhere(
      (value) => value.name == themeModeName,
      orElse: () => ThemeMode.system,
    );

    final colorScheme = AppColorScheme.values.firstWhere(
      (value) => value.name == colorSchemeName,
      orElse: () => AppColorScheme.blue,
    );

    return ThemePreferences(themeMode: themeMode, colorScheme: colorScheme);
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    final current = await load();
    await _storage.setJson(StorageKeys.themePreferences, {
      'themeMode': mode.name,
      'colorScheme': current.colorScheme.name,
    });
  }

  @override
  Future<void> saveColorScheme(AppColorScheme scheme) async {
    final current = await load();
    await _storage.setJson(StorageKeys.themePreferences, {
      'themeMode': current.themeMode.name,
      'colorScheme': scheme.name,
    });
  }
}
