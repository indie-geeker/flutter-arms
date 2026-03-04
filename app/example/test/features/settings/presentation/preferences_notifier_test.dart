import 'dart:async';

import 'package:example/src/di/providers.dart';
import 'package:example/src/shared/constants/storage_keys.dart';
import 'package:example/src/shared/theme/app_color_scheme.dart';
import 'package:example/src/features/settings/presentation/notifiers/locale_notifier.dart';
import 'package:example/src/features/settings/presentation/notifiers/theme_notifier.dart';
import 'package:example/src/features/settings/presentation/state/locale_state.dart';
import 'package:example/src/features/settings/presentation/state/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_doubles.dart';

Future<LocaleState> _waitForLocaleLoaded(
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 1),
}) async {
  final current = container.read(localeProvider);
  if (!current.isLoading) {
    return current;
  }

  final completer = Completer<LocaleState>();
  final subscription = container.listen<LocaleState>(localeProvider, (_, next) {
    if (!next.isLoading && !completer.isCompleted) {
      completer.complete(next);
    }
  }, fireImmediately: true);

  try {
    return await completer.future.timeout(timeout);
  } finally {
    subscription.close();
  }
}

Future<ThemeState> _waitForThemeLoaded(
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 1),
}) async {
  final current = container.read(themeProvider);
  if (!current.isLoading) {
    return current;
  }

  final completer = Completer<ThemeState>();
  final subscription = container.listen<ThemeState>(themeProvider, (_, next) {
    if (!next.isLoading && !completer.isCompleted) {
      completer.complete(next);
    }
  }, fireImmediately: true);

  try {
    return await completer.future.timeout(timeout);
  } finally {
    subscription.close();
  }
}

void main() {
  group('LocaleNotifier', () {
    test('loads locale from storage and persists updates', () async {
      final storage = InMemoryKeyValueStorage();
      await storage.setInt(StorageKeys.locale, AppLocale.chinese.index);

      final container = ProviderContainer(
        overrides: [kvStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      container.read(localeProvider.notifier);
      final loaded = await _waitForLocaleLoaded(container);

      expect(loaded.isLoading, isFalse);
      expect(loaded.appLocale, AppLocale.chinese);

      await container
          .read(localeProvider.notifier)
          .setLocale(AppLocale.english);

      expect(container.read(localeProvider).appLocale, AppLocale.english);
      expect(await storage.getInt(StorageKeys.locale), AppLocale.english.index);
    });
  });

  group('ThemeNotifier', () {
    test('loads theme preferences and persists theme updates', () async {
      final storage = InMemoryKeyValueStorage();
      await storage.setJson(StorageKeys.themePreferences, {
        'themeMode': ThemeMode.dark.name,
        'colorScheme': AppColorScheme.green.name,
      });

      final container = ProviderContainer(
        overrides: [kvStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      container.read(themeProvider.notifier);
      final loaded = await _waitForThemeLoaded(container);
      expect(loaded.isLoading, isFalse);
      expect(loaded.themeMode, ThemeMode.dark);
      expect(loaded.colorScheme, AppColorScheme.green);

      await container
          .read(themeProvider.notifier)
          .setThemeMode(ThemeMode.light);
      await container
          .read(themeProvider.notifier)
          .setColorScheme(AppColorScheme.orange);

      final updated = container.read(themeProvider);
      expect(updated.themeMode, ThemeMode.light);
      expect(updated.colorScheme, AppColorScheme.orange);
      expect(await storage.getJson(StorageKeys.themePreferences), {
        'themeMode': ThemeMode.light.name,
        'colorScheme': AppColorScheme.orange.name,
      });
    });
  });
}
