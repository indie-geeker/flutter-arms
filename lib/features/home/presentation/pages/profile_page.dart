import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/app/app_router.dart';
import 'package:flutter_arms/core/locale/locale_notifier.dart';
import 'package:flutter_arms/core/logger/dev_log_viewer.dart';
import 'package:flutter_arms/core/theme/app_colors.dart';
import 'package:flutter_arms/core/theme/theme_notifier.dart';
// arch-exempt: Profile 页依赖 auth 登出能力（跨切面）。
import 'package:flutter_arms/features/auth/presentation/view_models/auth_notifier.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_arms/shared/dialogs/app_dialog.dart';
import 'package:flutter_arms/shared/widgets/app_section_card.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final isDevFlavor = ref.watch(appEnvProvider).flavor == AppFlavor.dev;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              children: [
                Text(
                  t.home.profile,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                const _AccountSummaryCard(),
                const SizedBox(height: 20),
                _AppearanceSection(
                  themeState: themeState,
                  presetColors: kPresetSeedColors,
                  onThemeModeChanged:
                      (mode) => ref
                          .read(themeNotifierProvider.notifier)
                          .setThemeMode(mode),
                  onColorSelected:
                      (color) => ref
                          .read(themeNotifierProvider.notifier)
                          .setSeedColor(color),
                ),
                const SizedBox(height: 16),
                _GeneralSection(
                  currentLocale: currentLocale,
                  onLocaleChanged:
                      (locale) =>
                          ref.read(localeProvider.notifier).setLocale(locale),
                ),
                const SizedBox(height: 16),
                const _SupportSection(),
                if (isDevFlavor) ...[
                  const SizedBox(height: 16),
                  const _DeveloperSection(),
                ],
                const SizedBox(height: 24),
                _LogoutAction(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      await context.router.root.replaceAll(
                        [const LoginRoute()],
                        updateExistingRoutes: false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AccountSummaryCard
// ---------------------------------------------------------------------------

class _AccountSummaryCard extends ConsumerWidget {
  const _AccountSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);
    final displayName = user?.name ?? context.t.profile.guest;
    final email = user?.email;
    final isDevFlavor = ref.watch(appEnvProvider).flavor == AppFlavor.dev;

    return AppSectionCard(
      key: const Key('profileAccountCard'),
      child: Row(
        children: [
          GestureDetector(
            onLongPress:
                isDevFlavor
                    ? () => ref.read(devLogViewerProvider).open(context)
                    : null,
            child: CircleAvatar(
              radius: 32,
              backgroundColor: colors.primaryContainer,
              child: Icon(
                Icons.person,
                size: 32,
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (email != null && email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
    final t = context.t.profile;

    return AppSectionCard(
      key: const Key('profileAppearanceSection'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            icon: Icons.palette_outlined,
            title: t.appearance,
          ),
          const SizedBox(height: 20),
          Text(
            t.themeMode,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final showIcons = constraints.maxWidth >= 360;

              return SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(t.light),
                      icon:
                          showIcons
                              ? const Icon(Icons.light_mode_outlined)
                              : null,
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(t.system),
                      icon:
                          showIcons
                              ? const Icon(Icons.brightness_auto_outlined)
                              : null,
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(t.dark),
                      icon:
                          showIcons
                              ? const Icon(Icons.dark_mode_outlined)
                              : null,
                    ),
                  ],
                  selected: {themeState.mode},
                  style: const ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(
                      Size.fromHeight(48),
                    ),
                  ),
                  onSelectionChanged:
                      (selected) => onThemeModeChanged(selected.first),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            t.themeColor,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              ...presetColors.map(
                (color) => _ColorChoice(
                  color: color,
                  isSelected: themeState.seedColor == color,
                  semanticLabel:
                      '${t.themeColor} ${color.toARGB32().toRadixString(16)}',
                  onTap: () => onColorSelected(color),
                ),
              ),
              _CustomColorChoice(
                currentColor: themeState.seedColor,
                label: t.custom,
                onColorSelected: onColorSelected,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ColorChoice
// ---------------------------------------------------------------------------

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.isSelected,
    required this.semanticLabel,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      key: ValueKey<String>(
        'profile-theme-color-${color.toARGB32()}',
      ),
      button: true,
      selected: isSelected,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 48,
        child: Material(
          color: Colors.transparent,
          child: InkResponse(
            onTap: onTap,
            radius: 24,
            customBorder: const CircleBorder(),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? colors.onSurface : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child:
                      isSelected
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          )
                          : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CustomColorChoice
// ---------------------------------------------------------------------------

class _CustomColorChoice extends StatelessWidget {
  const _CustomColorChoice({
    required this.currentColor,
    required this.label,
    required this.onColorSelected,
  });

  final Color currentColor;
  final String label;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: label,
      child: SizedBox.square(
        dimension: 48,
        child: Material(
          color: Colors.transparent,
          child: InkResponse(
            onTap: () => unawaited(_showColorPicker(context)),
            radius: 24,
            customBorder: const CircleBorder(),
            child: Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surface,
                  border: Border.all(
                    color: colors.outline,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  size: 18,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showColorPicker(BuildContext context) async {
    var pickerColor = currentColor;
    final selectedColor = await AppDialog.showCustom<Color>(
      tag: 'profile-color-picker',
      bindToWidget: context,
      builder: (context, close) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: Text(label),
                content: SingleChildScrollView(
                  child: MaterialPicker(
                    pickerColor: pickerColor,
                    onColorChanged:
                        (color) => setState(() => pickerColor = color),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => unawaited(close()),
                    child: Text(
                      MaterialLocalizations.of(context).cancelButtonLabel,
                    ),
                  ),
                  FilledButton(
                    onPressed: () => unawaited(close(pickerColor)),
                    child: Text(
                      MaterialLocalizations.of(context).okButtonLabel,
                    ),
                  ),
                ],
              ),
        );
      },
    );

    if (selectedColor != null && context.mounted) {
      onColorSelected(selectedColor);
    }
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
    final t = context.t.profile;

    return AppSectionCard(
      key: const Key('profileGeneralSection'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            icon: Icons.language_outlined,
            title: t.general,
          ),
          const SizedBox(height: 20),
          Text(
            t.language,
            style: Theme.of(context).textTheme.labelLarge,
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
              style: const ButtonStyle(
                minimumSize: WidgetStatePropertyAll(
                  Size.fromHeight(48),
                ),
              ),
              onSelectionChanged: (selected) => onLocaleChanged(selected.first),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SupportSection
// ---------------------------------------------------------------------------

class _SupportSection extends StatelessWidget {
  const _SupportSection();

  @override
  Widget build(BuildContext context) {
    final t = context.t.profile;

    return AppSectionCard(
      key: const Key('profileSupportSection'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            icon: Icons.support_agent_outlined,
            title: t.support,
          ),
          const SizedBox(height: 8),
          _SettingsActionTile(
            icon: Icons.help_outline,
            title: t.helpFeedback,
            subtitle: t.helpFeedbackSubtitle,
            onTap: () {
              unawaited(context.router.push(const FeedbackCenterRoute()));
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DeveloperSection
// ---------------------------------------------------------------------------

class _DeveloperSection extends StatelessWidget {
  const _DeveloperSection();

  @override
  Widget build(BuildContext context) {
    final t = context.t.profile;

    return AppSectionCard(
      key: const Key('profileDeveloperSection'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            icon: Icons.code_outlined,
            title: t.developer,
          ),
          const SizedBox(height: 8),
          _SettingsActionTile(
            icon: Icons.preview_outlined,
            title: t.showcase,
            subtitle: t.showcaseSubtitle,
            onTap: () {
              unawaited(context.router.push(const ShowcaseRoute()));
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SettingsActionTile
// ---------------------------------------------------------------------------

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      minTileHeight: 72,
      contentPadding: EdgeInsets.zero,
      leading: AppIconBadge(
        icon: icon,
        backgroundColor: colors.secondaryContainer,
        foregroundColor: colors.onSecondaryContainer,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// _LogoutAction
// ---------------------------------------------------------------------------

class _LogoutAction extends StatelessWidget {
  const _LogoutAction({required this.onPressed});

  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      key: const Key('profileLogoutButton'),
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: colors.error,
          side: BorderSide(
            color: colors.error.withValues(alpha: 0.65),
          ),
        ),
        onPressed: () => unawaited(onPressed()),
        icon: const Icon(Icons.logout),
        label: Text(context.t.common.logout),
      ),
    );
  }
}
