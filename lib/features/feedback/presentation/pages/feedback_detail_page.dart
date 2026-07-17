import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/core/extensions/build_context_ext.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/presentation/view_models/feedback_detail_view_model.dart';
import 'package:flutter_arms/features/feedback/presentation/widgets/feedback_visuals.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_arms/shared/widgets/app_section_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 反馈详情页面。
@RoutePage()
class FeedbackDetailPage extends ConsumerStatefulWidget {
  /// 构造函数。
  const FeedbackDetailPage({required this.ticketId, super.key});

  /// 反馈工单 ID。
  final String ticketId;

  @override
  ConsumerState<FeedbackDetailPage> createState() => _FeedbackDetailPageState();
}

class _FeedbackDetailPageState extends ConsumerState<FeedbackDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(
          ref
              .read(
                feedbackDetailViewModelProvider(widget.ticketId).notifier,
              )
              .load(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = feedbackDetailViewModelProvider(widget.ticketId);
    final state = ref.watch(provider);
    final strings = context.t.feedback;

    return Scaffold(
      appBar: AppBar(title: Text(strings.detailTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: switch ((state.ticket, state.isLoading, state.error)) {
              (null, true, _) => const Center(
                child: CircularProgressIndicator(),
              ),
              (null, false, final failure?) => _DetailError(
                message: context.failureMessage(failure),
                onRetry: () => unawaited(ref.read(provider.notifier).retry()),
              ),
              (null, false, null) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(strings.ticketUnavailable),
                ),
              ),
              (final ticket?, _, _) => _TicketDetails(
                ticket: ticket,
                isLoading: state.isLoading,
                errorMessage:
                    state.error == null
                        ? null
                        : context.failureMessage(state.error!),
                onRetry: () => unawaited(ref.read(provider.notifier).retry()),
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = context.t;
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppSectionCard(
          color: colors.errorContainer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIconBadge(
                icon: Icons.error_outline,
                size: 52,
                iconSize: 26,
                backgroundColor: colors.onErrorContainer.withValues(
                  alpha: 0.12,
                ),
                foregroundColor: colors.onErrorContainer,
              ),
              const SizedBox(height: 16),
              Text(
                strings.feedback.detailLoadError,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onErrorContainer),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('feedbackDetailRetryButton'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  backgroundColor: colors.onErrorContainer,
                  foregroundColor: colors.errorContainer,
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(strings.common.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketDetails extends StatelessWidget {
  const _TicketDetails({
    required this.ticket,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final FeedbackTicket ticket;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        if (isLoading) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
        ],
        if (errorMessage case final message?) ...[
          _InlineDetailError(
            message: message,
            onRetry: onRetry,
          ),
          const SizedBox(height: 16),
        ],
        _TicketSummaryCard(ticket: ticket),
        const SizedBox(height: 16),
        _MessageCard(ticket: ticket),
        const SizedBox(height: 16),
        _ReplyCard(ticket: ticket),
      ],
    );
  }
}

class _InlineDetailError extends StatelessWidget {
  const _InlineDetailError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppSectionCard(
      color: colors.errorContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: colors.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t.feedback.detailLoadError,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: colors.onErrorContainer),
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: colors.onErrorContainer,
                  ),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.t.common.retry),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketSummaryCard extends StatelessWidget {
  const _TicketSummaryCard({required this.ticket});

  final FeedbackTicket ticket;

  @override
  Widget build(BuildContext context) {
    final strings = context.t.feedback;
    final material = MaterialLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return AppSectionCard(
      key: const Key('feedbackDetailSummaryCard'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${ticket.id}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FeedbackStatusBadge(status: ticket.status),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: FeedbackCategoryVisuals.icon(ticket.category),
                  label: strings.categoryLabel,
                  value: FeedbackCategoryVisuals.label(
                    context,
                    ticket.category,
                  ),
                  backgroundColor: FeedbackCategoryVisuals.backgroundColor(
                    context,
                    ticket.category,
                  ),
                  foregroundColor: FeedbackCategoryVisuals.foregroundColor(
                    context,
                    ticket.category,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.calendar_today_outlined,
                  label: strings.submittedAtLabel,
                  value: material.formatMediumDate(
                    ticket.createdAt.toLocal(),
                  ),
                  backgroundColor: colors.secondaryContainer,
                  foregroundColor: colors.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(
          icon: icon,
          size: 36,
          iconSize: 18,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.ticket});

  final FeedbackTicket ticket;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      key: const Key('feedbackDetailMessageCard'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            icon: Icons.chat_bubble_outline,
            title: context.t.feedback.messageLabel,
          ),
          const SizedBox(height: 16),
          Text(
            ticket.message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyCard extends StatelessWidget {
  const _ReplyCard({required this.ticket});

  final FeedbackTicket ticket;

  @override
  Widget build(BuildContext context) {
    final reply = ticket.reply;

    return AppSectionCard(
      key: const Key('feedbackDetailReplyCard'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            icon: Icons.support_agent_outlined,
            title: context.t.feedback.replyLabel,
          ),
          const SizedBox(height: 16),
          if (reply == null || reply.isEmpty)
            const _ReplyWaitingState()
          else
            Text(
              reply,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.55,
              ),
            ),
        ],
      ),
    );
  }
}

class _ReplyWaitingState extends StatelessWidget {
  const _ReplyWaitingState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      key: const Key('feedbackReplyWaitingState'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          AppIconBadge(
            icon: Icons.hourglass_empty_outlined,
            backgroundColor: colors.secondaryContainer,
            foregroundColor: colors.onSecondaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.t.feedback.noReply,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
