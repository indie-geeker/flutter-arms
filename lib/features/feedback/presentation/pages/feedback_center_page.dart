import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/app/app_router.dart';
import 'package:flutter_arms/core/extensions/build_context_ext.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/presentation/view_models/feedback_center_view_model.dart';
import 'package:flutter_arms/features/feedback/presentation/widgets/faq_section.dart';
import 'package:flutter_arms/features/feedback/presentation/widgets/feedback_history_section.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_arms/shared/widgets/app_section_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 帮助与反馈中心页面。
@RoutePage()
class FeedbackCenterPage extends ConsumerStatefulWidget {
  /// 构造函数。
  const FeedbackCenterPage({super.key}) : onSubmit = null, onTicketTap = null;

  /// 仅供页面级测试注入导航动作。
  @visibleForTesting
  const FeedbackCenterPage.test({
    this.onSubmit,
    this.onTicketTap,
    super.key,
  });

  /// `.test` 构造器使用的提交入口；生产默认使用 typed route。
  final VoidCallback? onSubmit;

  /// `.test` 构造器使用的详情入口；生产默认使用 typed route。
  final ValueChanged<FeedbackTicket>? onTicketTap;

  @override
  ConsumerState<FeedbackCenterPage> createState() => _FeedbackCenterPageState();
}

class _FeedbackCenterPageState extends ConsumerState<FeedbackCenterPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(feedbackCenterViewModelProvider.notifier).load());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedbackCenterViewModelProvider);
    final strings = context.t.feedback;
    final hasData = state.faqs.isNotEmpty || state.tickets.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(strings.title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child:
                state.isLoading && !hasData
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      children: [
                        if (state.isLoading) ...[
                          const LinearProgressIndicator(),
                          const SizedBox(height: 16),
                        ],
                        if (state.error case final failure?) ...[
                          _ErrorBanner(
                            message: context.failureMessage(failure),
                            onRetry:
                                () => unawaited(
                                  ref
                                      .read(
                                        feedbackCenterViewModelProvider
                                            .notifier,
                                      )
                                      .retry(),
                                ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        _FeedbackIntro(
                          controller: _searchController,
                          onSearch: _search,
                        ),
                        const SizedBox(height: 20),
                        FaqSection(faqs: state.faqs),
                        const SizedBox(height: 20),
                        _SubmitFeedbackAction(onTap: _openSubmit),
                        const SizedBox(height: 20),
                        FeedbackHistorySection(
                          tickets: state.tickets,
                          onTicketTap: _openTicket,
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  void _search() {
    unawaited(
      ref
          .read(feedbackCenterViewModelProvider.notifier)
          .search(_searchController.text.trim()),
    );
  }

  void _openSubmit() {
    final callback = widget.onSubmit;
    if (callback != null) {
      callback();
      return;
    }
    unawaited(context.router.push(const SubmitFeedbackRoute()));
  }

  void _openTicket(FeedbackTicket ticket) {
    final callback = widget.onTicketTap;
    if (callback != null) {
      callback(ticket);
      return;
    }
    unawaited(
      context.router.push(FeedbackDetailRoute(ticketId: ticket.id)),
    );
  }
}

class _FeedbackIntro extends StatelessWidget {
  const _FeedbackIntro({
    required this.controller,
    required this.onSearch,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final strings = context.t.feedback;
    final colors = Theme.of(context).colorScheme;

    return AppSectionCard(
      key: const Key('feedbackIntroCard'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            icon: Icons.manage_search_outlined,
            title: strings.searchHint,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('feedbackSearchField'),
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: strings.searchLabel,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: strings.searchLabel,
                onPressed: onSearch,
                icon: const Icon(Icons.arrow_forward),
              ),
              filled: true,
              fillColor: colors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colors.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colors.primary,
                  width: 2,
                ),
              ),
            ),
            onSubmitted: (_) => onSearch(),
          ),
        ],
      ),
    );
  }
}

class _SubmitFeedbackAction extends StatelessWidget {
  const _SubmitFeedbackAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = context.t.feedback;
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: strings.submitCta,
      child: Material(
        key: const Key('feedbackSubmitCta'),
        color: colors.primary,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 84),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              child: Row(
                children: [
                  AppIconBadge(
                    icon: Icons.edit_outlined,
                    size: 44,
                    iconSize: 22,
                    backgroundColor: colors.onPrimary.withValues(alpha: 0.14),
                    foregroundColor: colors.onPrimary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.submitCta,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          strings.submitCtaSubtitle,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            height: 1.35,
                            color: colors.onPrimary.withValues(alpha: 0.82),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: colors.onPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = context.t;
    final colors = Theme.of(context).colorScheme;

    return AppSectionCard(
      color: colors.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: colors.onErrorContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.feedback.loadError,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: colors.onErrorContainer),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              key: const Key('feedbackRetryButton'),
              style: TextButton.styleFrom(
                foregroundColor: colors.onErrorContainer,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(strings.common.retry),
            ),
          ),
        ],
      ),
    );
  }
}
