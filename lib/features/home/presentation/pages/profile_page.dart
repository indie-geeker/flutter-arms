import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/app/app_router.dart';
import 'package:flutter_arms/core/locale/locale_notifier.dart';
import 'package:flutter_arms/core/logger/app_logger.dart';
import 'package:flutter_arms/core/theme/app_colors.dart';
import 'package:flutter_arms/core/theme/theme_notifier.dart';
// arch-exempt: Profile 页依赖 auth 登出能力（跨切面）。
import 'package:flutter_arms/features/auth/presentation/view_models/auth_notifier.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Profile Tab 页。
@RoutePage()
class ProfilePage extends ConsumerWidget {
  /// 构造函数。
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final themeState = ref.watch(themeNotifierProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            const _UserHeader(),
            const SizedBox(height: 24),
            _AppearanceSection(
              themeState: themeState,
              presetColors: kPresetSeedColors,
              onThemeModeChanged: (mode) =>
                  ref.read(themeNotifierProvider.notifier).setThemeMode(mode),
              onColorSelected: (color) =>
                  ref.read(themeNotifierProvider.notifier).setSeedColor(color),
            ),
            const SizedBox(height: 16),
            _GeneralSection(
              currentLocale: currentLocale,
              onLocaleChanged: (locale) =>
                  ref.read(localeProvider.notifier).setLocale(locale),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  await context.router.replace(const LoginRoute());
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(t.common.logout),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _UserHeader
// ---------------------------------------------------------------------------

class _UserHeader extends ConsumerWidget {
  const _UserHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);
    final displayName = user?.name ?? context.t.profile.guest;
    final email = user?.email;
    final isDevFlavor = ref.watch(appEnvProvider).flavor == AppFlavor.dev;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onLongPress: isDevFlavor
                ? () => _openTalkerScreen(context, ref)
                : null,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 40,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (email != null && email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openTalkerScreen(BuildContext context, WidgetRef ref) {
    final talker = ref.read(appLoggerProvider);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TalkerScreen(talker: talker),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AppearanceSection
// ---------------------------------------------------------------------------

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({
    required this.themeState,
    required this.presetColors,
    required this.onThemeModeChanged,
    required this.onColorSelected,
  });

  final ThemeState themeState;
  final List<Color> presetColors;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.profile.appearance,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            // 主题模式标签
            Text(
              t.profile.themeMode,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            // 主题模式分段按钮
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(t.profile.light),
                    icon: const Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(t.profile.system),
                    icon: const Icon(Icons.brightness_auto_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(t.profile.dark),
                    icon: const Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {themeState.mode},
                onSelectionChanged: (selected) =>
                    onThemeModeChanged(selected.first),
              ),
            ),
            const SizedBox(height: 16),
            // 主题色标签
            Text(
              t.profile.themeColor,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            // 预设色板 + 自定义按钮
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...presetColors.map(
                  (color) => _ColorCircle(
                    color: color,
                    isSelected: themeState.seedColor == color,
                    onTap: () => onColorSelected(color),
                  ),
                ),
                _CustomColorCircle(
                  currentColor: themeState.seedColor,
                  label: t.profile.custom,
                  onColorSelected: onColorSelected,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ColorCircle
// ---------------------------------------------------------------------------

class _ColorCircle extends StatelessWidget {
  const _ColorCircle({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CustomColorCircle
// ---------------------------------------------------------------------------

class _CustomColorCircle extends StatelessWidget {
  const _CustomColorCircle({
    required this.currentColor,
    required this.label,
    required this.onColorSelected,
  });

  final Color currentColor;
  final String label;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showColorPicker(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.add,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    var pickerColor = currentColor;
    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(label),
            content: SingleChildScrollView(
              child: MaterialPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) => setState(() => pickerColor = color),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
              ),
              FilledButton(
                onPressed: () {
                  onColorSelected(pickerColor);
                  Navigator.of(context).pop();
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _GeneralSection
// ---------------------------------------------------------------------------

class _GeneralSection extends StatelessWidget {
  const _GeneralSection({
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  final AppLocale currentLocale;
  final ValueChanged<AppLocale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.profile.general,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.profile.language,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<AppLocale>(
                segments: const [
                  ButtonSegment(
                    value: AppLocale.en,
                    label: Text('English'),
                  ),
                  ButtonSegment(
                    value: AppLocale.zh,
                    label: Text('中文'),
                  ),
                ],
                selected: {currentLocale},
                onSelectionChanged: (selected) =>
                    onLocaleChanged(selected.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
