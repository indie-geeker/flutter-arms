import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/core/extensions/build_context_ext.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_draft.dart';
import 'package:flutter_arms/features/feedback/domain/entities/feedback_ticket.dart';
import 'package:flutter_arms/features/feedback/presentation/view_models/feedback_center_view_model.dart';
import 'package:flutter_arms/features/feedback/presentation/view_models/submit_feedback_view_model.dart';
import 'package:flutter_arms/features/feedback/presentation/widgets/feedback_visuals.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_arms/shared/dialogs/app_dialog.dart';
import 'package:flutter_arms/shared/widgets/app_section_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 提交反馈页面。
@RoutePage()
class SubmitFeedbackPage extends ConsumerStatefulWidget {
  /// 构造函数。
  const SubmitFeedbackPage({super.key}) : submitOverride = null;

  /// 仅供页面级测试覆盖提交 Future。
  @visibleForTesting
  const SubmitFeedbackPage.test({this.submitOverride, super.key});

  /// `.test` 构造器使用的提交函数；生产默认使用 ViewModel。
  final Future<Result<FeedbackTicket>> Function()? submitOverride;

  @override
  ConsumerState<SubmitFeedbackPage> createState() => _SubmitFeedbackPageState();
}

class _SubmitFeedbackPageState extends ConsumerState<SubmitFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _messageFocusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(submitFeedbackViewModelProvider);
    final strings = context.t.feedback;

    return Scaffold(
      appBar: AppBar(title: Text(strings.submitButton)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSectionCard(
                      key: const Key('feedbackCategoryField'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppSectionHeader(
                            icon: Icons.category_outlined,
                            title: strings.categoryLabel,
                          ),
                          const SizedBox(height: 16),
                          _FeedbackCategorySelector(
                            selected: state.category,
                            enabled: !state.isSubmitting,
                            onSelected:
                                ref
                                    .read(
                                      submitFeedbackViewModelProvider.notifier,
                                    )
                                    .setCategory,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppSectionHeader(
                            icon: Icons.chat_bubble_outline,
                            title: strings.messageLabel,
                            subtitle: strings.messageHelper,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            key: const Key('feedbackMessageField'),
                            controller: _messageController,
                            focusNode: _messageFocusNode,
                            enabled: !state.isSubmitting,
                            minLines: 6,
                            maxLines: 12,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: strings.messageHelper,
                              alignLabelWithHint: true,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return strings.messageRequired;
                              }
                              return null;
                            },
                            onChanged:
                                ref
                                    .read(
                                      submitFeedbackViewModelProvider.notifier,
                                    )
                                    .setMessage,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _messageController,
                              builder: (context, value, child) {
                                return SizedBox(
                                  key: const Key('feedbackMessageCount'),
                                  child: Text(
                                    '${value.text.runes.length}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium?.copyWith(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _SubmitBar(
        isSubmitting: state.isSubmitting,
        onSubmit: _submit,
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _messageFocusNode.requestFocus();
      return;
    }

    final strings = context.t.feedback;
    final confirmed = await AppDialog.showConfirm(
      title: strings.confirmTitle,
      message: strings.confirmMessage,
      confirmText: strings.confirmAction,
      cancelText: strings.cancelAction,
    );
    if (!confirmed || !mounted) {
      return;
    }

    AppDialog.showLoading(msg: strings.submitting);
    late final Result<FeedbackTicket> result;
    try {
      result =
          await (widget.submitOverride?.call() ??
              ref.read(submitFeedbackViewModelProvider.notifier).submit());
    } finally {
      AppDialog.hideLoading();
    }

    if (!mounted) {
      return;
    }

    switch (result) {
      case Success<FeedbackTicket>(:final data):
        ref.read(feedbackCenterViewModelProvider.notifier).addTicket(data);
        AppDialog.showInfo(strings.successMessage);
        await Navigator.of(context).maybePop();
      case FailureResult<FeedbackTicket>(:final failure):
        AppDialog.showError(context.failureMessage(failure));
    }
  }
}

class _FeedbackCategorySelector extends StatelessWidget {
  const _FeedbackCategorySelector({
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final FeedbackCategory selected;
  final bool enabled;
  final ValueChanged<FeedbackCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final itemWidth = (constraints.maxWidth - spacing * 2) / 3;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final category in FeedbackCategory.values)
              SizedBox(
                width: itemWidth,
                child: _CategoryChoice(
                  category: category,
                  selected: selected == category,
                  enabled: enabled,
                  onTap: () => onSelected(category),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryChoice extends StatelessWidget {
  const _CategoryChoice({
    required this.category,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final FeedbackCategory category;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = FeedbackCategoryVisuals.label(context, category);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      child: Material(
        color:
            selected ? colors.primaryContainer : colors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('feedback-category-${category.name}'),
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 92),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIconBadge(
                          icon: FeedbackCategoryVisuals.icon(category),
                          size: 36,
                          iconSize: 18,
                          backgroundColor:
                              FeedbackCategoryVisuals.backgroundColor(
                                context,
                                category,
                              ),
                          foregroundColor:
                              FeedbackCategoryVisuals.foregroundColor(
                                context,
                                category,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            color:
                                enabled
                                    ? colors.onSurface
                                    : colors.onSurface.withValues(alpha: 0.38),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (selected)
                  PositionedDirectional(
                    top: 7,
                    end: 7,
                    child: Icon(
                      Icons.check_circle,
                      size: 16,
                      color: colors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.isSubmitting,
    required this.onSubmit,
  });

  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final strings = context.t.feedback;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 688),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('feedbackSubmitButton'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: isSubmitting ? null : onSubmit,
                  icon:
                      isSubmitting
                          ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.send_outlined),
                  label: Text(strings.submitButton),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
