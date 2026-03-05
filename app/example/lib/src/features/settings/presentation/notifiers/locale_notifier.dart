import 'package:example/src/di/providers.dart';
import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:example/src/shared/constants/storage_keys.dart';
import 'package:example/src/features/settings/presentation/state/locale_state.dart';

part 'locale_notifier.g.dart';

/// Locale state manager.
///
/// Manages the app locale setting, persisted to storage.
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  late final IKeyValueStorage _storage;

  @override
  LocaleState build() {
    _storage = ref.read(kvStorageProvider);
    _loadPreferences();
    return const LocaleState(isLoading: true);
  }

  /// Loads locale preferences from storage.
  Future<void> _loadPreferences() async {
    try {
      final localeIndex = await _storage.getInt(StorageKeys.locale);

      final appLocale =
          localeIndex != null &&
              localeIndex >= 0 &&
              localeIndex < AppLocale.values.length
          ? AppLocale.values[localeIndex]
          : AppLocale.english;

      state = LocaleState(isLoading: false, appLocale: appLocale);
    } catch (_) {
      state = const LocaleState(isLoading: false);
    }
  }

  /// Sets the locale.
  Future<void> setLocale(AppLocale locale) async {
    state = state.copyWith(appLocale: locale);
    await _storage.setInt(StorageKeys.locale, locale.index);
  }
}
