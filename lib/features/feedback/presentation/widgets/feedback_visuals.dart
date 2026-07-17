import 'package:flutter/material.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/i18n/strings.g.dart';

/// 反馈分类的统一视觉和本地化映射。
abstract final class FeedbackCategoryVisuals {
  /// 分类图标。
  static IconData icon(FeedbackCategory category) => switch (category) {
    FeedbackCategory.bug => Icons.bug_report_outlined,
    FeedbackCategory.suggestion => Icons.lightbulb_outline,
    FeedbackCategory.other => Icons.chat_bubble_outline,
  };

  /// 分类文案。
  static String label(
    BuildContext context,
    FeedbackCategory category,
  ) {
    final strings = context.t.feedback.categories;
    return switch (category) {
      FeedbackCategory.bug => strings.bug,
      FeedbackCategory.suggestion => strings.suggestion,
      FeedbackCategory.other => strings.other,
    };
  }

  /// 分类图标底色。
  static Color backgroundColor(
    BuildContext context,
    FeedbackCategory category,
  ) {
    final colors = Theme.of(context).colorScheme;
    return switch (category) {
      FeedbackCategory.bug => colors.errorContainer,
      FeedbackCategory.suggestion => colors.tertiaryContainer,
      FeedbackCategory.other => colors.secondaryContainer,
    };
  }

  /// 分类图标前景色。
  static Color foregroundColor(
    BuildContext context,
    FeedbackCategory category,
  ) {
    final colors = Theme.of(context).colorScheme;
    return switch (category) {
      FeedbackCategory.bug => colors.onErrorContainer,
      FeedbackCategory.suggestion => colors.onTertiaryContainer,
      FeedbackCategory.other => colors.onSecondaryContainer,
    };
  }
}

/// 带图标的反馈状态胶囊。
class FeedbackStatusBadge extends StatelessWidget {
  /// 构造函数。
  const FeedbackStatusBadge({
    required this.status,
    super.key,
  });

  /// 反馈状态。
  final FeedbackStatus status;

  @override
  Widget build(BuildContext context) {
    final background = _backgroundColor(context);
    final foreground = _foregroundColor(context);
    final label = _label(context);

    return Semantics(
      label: label,
      child: Container(
        key: Key('feedback-status-${status.name}'),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon(),
              size: 14,
              color: foreground,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon() => switch (status) {
    FeedbackStatus.submitted => Icons.schedule_outlined,
    FeedbackStatus.reviewing => Icons.sync_outlined,
    FeedbackStatus.resolved => Icons.check_circle_outline,
    FeedbackStatus.closed => Icons.block_outlined,
  };

  String _label(BuildContext context) {
    final strings = context.t.feedback.statuses;
    return switch (status) {
      FeedbackStatus.submitted => strings.submitted,
      FeedbackStatus.reviewing => strings.reviewing,
      FeedbackStatus.resolved => strings.resolved,
      FeedbackStatus.closed => strings.closed,
    };
  }

  Color _backgroundColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return switch (status) {
      FeedbackStatus.submitted => colors.primaryContainer,
      FeedbackStatus.reviewing => colors.tertiaryContainer,
      FeedbackStatus.resolved => colors.secondaryContainer,
      FeedbackStatus.closed => colors.surfaceContainerHighest,
    };
  }

  Color _foregroundColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return switch (status) {
      FeedbackStatus.submitted => colors.onPrimaryContainer,
      FeedbackStatus.reviewing => colors.onTertiaryContainer,
      FeedbackStatus.resolved => colors.onSecondaryContainer,
      FeedbackStatus.closed => colors.onSurfaceVariant,
    };
  }
}
