import 'package:flutter/material.dart';

/// 商业化页面使用的统一分区卡片。
class AppSectionCard extends StatelessWidget {
  /// 构造函数。
  const AppSectionCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  /// 卡片内容。
  final Widget child;

  /// 内容边距。
  final EdgeInsetsGeometry padding;

  /// 可选背景色；默认使用主题语义表面色。
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: color ?? colors.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

/// 分区标题，统一图标、标题、说明和尾部操作的层级。
class AppSectionHeader extends StatelessWidget {
  /// 构造函数。
  const AppSectionHeader({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
  });

  /// 分区图标。
  final IconData icon;

  /// 分区标题。
  final String title;

  /// 可选说明。
  final String? subtitle;

  /// 可选尾部内容。
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(icon: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              if (subtitle case final value?) ...[
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.4,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing case final value?) ...[
          const SizedBox(width: 12),
          value,
        ],
      ],
    );
  }
}

/// 统一的语义图标底板。
class AppIconBadge extends StatelessWidget {
  /// 构造函数。
  const AppIconBadge({
    required this.icon,
    super.key,
    this.size = 40,
    this.iconSize = 20,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// 图标。
  final IconData icon;

  /// 底板尺寸。
  final double size;

  /// 图标尺寸。
  final double iconSize;

  /// 可选底板颜色。
  final Color? backgroundColor;

  /// 可选图标颜色。
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: iconSize,
        color: foregroundColor ?? colors.onPrimaryContainer,
      ),
    );
  }
}
