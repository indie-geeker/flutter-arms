import 'package:core/core.dart';
import 'package:interfaces/storage/i_kv_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/storage_keys.dart';
import '../state/locale_state.dart';

part 'locale_notifier.g.dart';

/// 语言状态管理器
///
/// 管理应用的语言设置，并持久化到存储
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  late final IKeyValueStorage _storage;

  @override
  LocaleState build() {
    _storage = ref.read(kvStorageProvider);
    _loadPreferences();
    return const LocaleState(isLoading: true);
  }

  /// 从存储加载语言偏好设置
  Future<void> _loadPreferences() async {
    final localeIndex = await _storage.getInt(StorageKeys.locale);

    final appLocale = localeIndex != null && localeIndex < AppLocale.values.length
        ? AppLocale.values[localeIndex]
        : AppLocale.english;

    state = LocaleState(
      isLoading: false,
      appLocale: appLocale,
    );
  }

  /// 设置语言
  Future<void> setLocale(AppLocale locale) async {
    state = state.copyWith(appLocale: locale);
    await _storage.setInt(StorageKeys.locale, locale.index);
  }
}
