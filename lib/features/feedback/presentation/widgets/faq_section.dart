import 'package:flutter/material.dart';
import 'package:flutter_arms/features/feedback/domain/entities/faq_item.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_arms/shared/widgets/app_section_card.dart';

/// 常见问题分区。
class FaqSection extends StatelessWidget {
  /// 构造函数。
  const FaqSection({required this.faqs, super.key});

  /// 常见问题列表。
  final List<FaqItem> faqs;

  @override
  Widget build(BuildContext context) {
    final t = context.t.feedback;
    final colors = Theme.of(context).colorScheme;

    return AppSectionCard(
      key: const Key('feedbackFaqSection'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: AppSectionHeader(
              icon: Icons.quiz_outlined,
              title: t.faqTitle,
            ),
          ),
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.7),
          ),
          if (faqs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: _FaqEmptyState(
                title: t.noFaqs,
                subtitle: t.noFaqsHint,
              ),
            )
          else
            for (var index = 0; index < faqs.length; index++) ...[
              _FaqTile(faq: faqs[index]),
              if (index != faqs.length - 1)
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: colors.outlineVariant.withValues(alpha: 0.55),
                ),
            ],
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final FaqItem faq;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        key: ValueKey('faq-${faq.id}'),
        minTileHeight: 64,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20),
        childrenPadding: const EdgeInsets.fromLTRB(64, 0, 20, 20),
        leading: AppIconBadge(
          icon: Icons.help_outline,
          size: 36,
          iconSize: 18,
          backgroundColor: colors.secondaryContainer,
          foregroundColor: colors.onSecondaryContainer,
        ),
        title: Text(
          faq.question,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              faq.answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqEmptyState extends StatelessWidget {
  const _FaqEmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(
          icon: Icons.search_off_outlined,
          backgroundColor: colors.surfaceContainerHighest,
          foregroundColor: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
