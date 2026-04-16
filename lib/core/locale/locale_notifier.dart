import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_notifier.g.dart';

/// 全局语言状态管理。
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  AppLocale build() {
    final stored = ref.read(kvStorageProvider).getLocale();
    if (stored != null) {
      return AppLocaleUtils.parse(stored);
    }
    return AppLocale.en;
  }

  /// 切换语言。
  Future<void> setLocale(AppLocale locale) async {
    await LocaleSettings.setLocale(locale);
    state = locale;
    await ref.read(kvStorageProvider).setLocale(locale.languageCode);
  }
}

/// 兼容命名：语言状态 Provider。
const localeNotifierProvider = localeProvider;
