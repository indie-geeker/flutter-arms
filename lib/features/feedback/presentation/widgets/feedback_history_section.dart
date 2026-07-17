import 'package:flutter/material.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/presentation/widgets/feedback_visuals.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_arms/shared/widgets/app_section_card.dart';

/// 反馈历史分区。
class FeedbackHistorySection extends StatelessWidget {
  /// 构造函数。
  const FeedbackHistorySection({
    required this.tickets,
    required this.onTicketTap,
    super.key,
  });

  /// 反馈工单列表。
  final List<FeedbackTicket> tickets;

  /// 点击反馈工单。
  final ValueChanged<FeedbackTicket> onTicketTap;

  @override
  Widget build(BuildContext context) {
    final strings = context.t.feedback;
    final colors = Theme.of(context).colorScheme;

    return AppSectionCard(
      key: const Key('feedbackHistorySection'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: AppSectionHeader(
              icon: Icons.forum_outlined,
              title: strings.historyTitle,
            ),
          ),
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.7),
          ),
          if (tickets.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: _HistoryEmptyState(
                title: strings.noTickets,
                subtitle: strings.noTicketsHint,
              ),
            )
          else
            for (var index = 0; index < tickets.length; index++) ...[
              _TicketTile(
                ticket: tickets[index],
                onTap: () => onTicketTap(tickets[index]),
              ),
              if (index != tickets.length - 1)
                Divider(
                  height: 1,
                  indent: 76,
                  color: colors.outlineVariant.withValues(alpha: 0.55),
                ),
            ],
        ],
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  const _TicketTile({required this.ticket, required this.onTap});

  final FeedbackTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      key: ValueKey('feedback-ticket-${ticket.id}'),
      minTileHeight: 96,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      leading: AppIconBadge(
        icon: FeedbackCategoryVisuals.icon(ticket.category),
        backgroundColor: FeedbackCategoryVisuals.backgroundColor(
          context,
          ticket.category,
        ),
        foregroundColor: FeedbackCategoryVisuals.foregroundColor(
          context,
          ticket.category,
        ),
      ),
      title: Text(
        ticket.message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FeedbackStatusBadge(status: ticket.status),
            Text(
              FeedbackCategoryVisuals.label(context, ticket.category),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            Text(
              material.formatMediumDate(ticket.createdAt.toLocal()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState({
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
          icon: Icons.inbox_outlined,
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
