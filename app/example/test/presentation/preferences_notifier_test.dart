import 'dart:async';

import 'package:core/core.dart';
import 'package:example/src/core/constants/storage_keys.dart';
import 'package:example/src/presentation/notifiers/locale_notifier.dart';
import 'package:example/src/presentation/notifiers/theme_notifier.dart';
import 'package:example/src/presentation/state/locale_state.dart';
import 'package:example/src/presentation/state/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_doubles.dart';

Future<LocaleState> _waitForLocaleLoaded(
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 1),
}) async {
  final current = container.read(localeNotifierProvider);
  if (!current.isLoading) {
    return current;
  }

  final completer = Completer<LocaleState>();
  final subscription = container.listen<LocaleState>(localeNotifierProvider, (_, next) {
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
  final current = container.read(themeNotifierProvider);
  if (!current.isLoading) {
    return current;
  }

  final completer = Completer<ThemeState>();
  final subscription = container.listen<ThemeState>(themeNotifierProvider, (_, next) {
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

      container.read(localeNotifierProvider.notifier);
      final loaded = await _waitForLocaleLoaded(container);

      expect(loaded.isLoading, isFalse);
      expect(loaded.appLocale, AppLocale.chinese);

      await container
          .read(localeNotifierProvider.notifier)
          .setLocale(AppLocale.english);

      expect(container.read(localeNotifierProvider).appLocale, AppLocale.english);
      expect(await storage.getInt(StorageKeys.locale), AppLocale.english.index);
    });
  });

  group('ThemeNotifier', () {
    test('loads theme preferences and persists theme updates', () async {
      final storage = InMemoryKeyValueStorage();
      await storage.setInt(StorageKeys.themeMode, ThemeMode.dark.index);
      await storage.setInt(StorageKeys.colorScheme, AppColorScheme.green.index);

      final container = ProviderContainer(
        overrides: [kvStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      container.read(themeNotifierProvider.notifier);
      final loaded = await _waitForThemeLoaded(container);
      expect(loaded.isLoading, isFalse);
      expect(loaded.themeMode, ThemeMode.dark);
      expect(loaded.colorScheme, AppColorScheme.green);

      await container
          .read(themeNotifierProvider.notifier)
          .setThemeMode(ThemeMode.light);
      await container
          .read(themeNotifierProvider.notifier)
          .setColorScheme(AppColorScheme.orange);

      final updated = container.read(themeNotifierProvider);
      expect(updated.themeMode, ThemeMode.light);
      expect(updated.colorScheme, AppColorScheme.orange);
      expect(
        await storage.getInt(StorageKeys.themeMode),
        ThemeMode.light.index,
      );
      expect(
        await storage.getInt(StorageKeys.colorScheme),
        AppColorScheme.orange.index,
      );
    });
  });
}
