import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/locale_notifier.dart';
import '../notifiers/theme_notifier.dart';
import '../state/locale_state.dart';
import '../state/theme_state.dart';

/// 设置页面
///
/// 提供主题模式、配色方案和语言切换功能
@RoutePage()
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeState = ref.watch(themeProvider);
    final localeState = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // 主题模式部分
          _buildSectionHeader(context, l10n.themeMode),
          _buildThemeModeSection(context, ref, l10n, themeState),

          const Divider(),

          // 配色方案部分
          _buildSectionHeader(context, l10n.colorScheme),
          _buildColorSchemeSection(context, ref, themeState),

          const Divider(),

          // 语言部分
          _buildSectionHeader(context, l10n.language),
          _buildLanguageSection(context, ref, l10n, localeState),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildThemeModeSection(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeState themeState,
  ) {
    return RadioGroup<ThemeMode>(
      groupValue: themeState.themeMode,
      onChanged: (value) {
        if (value != null) {
          ref.read(themeProvider.notifier).setThemeMode(value);
        }
      },
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: Text(l10n.systemMode),
            subtitle: const Text('Auto'),
            value: ThemeMode.system,
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.lightMode),
            value: ThemeMode.light,
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.darkMode),
            value: ThemeMode.dark,
          ),
        ],
      ),
    );
  }

  Widget _buildColorSchemeSection(
    BuildContext context,
    WidgetRef ref,
    ThemeState themeState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: AppColorScheme.values.map((scheme) {
          final isSelected = themeState.colorScheme == scheme;
          return GestureDetector(
            onTap: () {
              ref.read(themeProvider.notifier).setColorScheme(scheme);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 3,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: scheme.color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: _getContrastColor(scheme.color),
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    LocaleState localeState,
  ) {
    return RadioGroup<AppLocale>(
      groupValue: localeState.appLocale,
      onChanged: (value) {
        if (value != null) {
          ref.read(localeProvider.notifier).setLocale(value);
        }
      },
      child: Column(
        children: [
          RadioListTile<AppLocale>(
            title: Text(l10n.english),
            subtitle: const Text('English'),
            value: AppLocale.english,
          ),
          RadioListTile<AppLocale>(
            title: Text(l10n.chinese),
            subtitle: const Text('中文'),
            value: AppLocale.chinese,
          ),
        ],
      ),
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
