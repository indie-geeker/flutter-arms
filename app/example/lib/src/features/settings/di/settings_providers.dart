import 'package:core/core.dart';
import 'package:example/src/features/settings/data/repositories/theme_preferences_repository_impl.dart';
import 'package:example/src/features/settings/domain/repositories/theme_preferences_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themePreferencesRepositoryProvider = Provider<ThemePreferencesRepository>(
  (ref) {
    final storage = ref.watch(kvStorageProvider);
    return ThemePreferencesRepositoryImpl(storage);
  },
);
