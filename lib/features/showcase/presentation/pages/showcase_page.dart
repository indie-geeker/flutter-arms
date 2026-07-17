import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/shared/dialogs/app_dialog.dart';
import 'package:flutter_arms/shared/widgets/result_state_widget.dart';

/// Optional feature showcase for template capabilities.
@RoutePage()
class ShowcasePage extends StatefulWidget {
  /// Creates a showcase page.
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  static const _popupTag = 'showcase-request-popup';

  final _client = const _ShowcaseDemoApi();

  Result<List<_ShowcaseMetric>> _result = const Result.success(
    _ShowcaseDemoApi.seedMetrics,
  );
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Feature Showcase')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _ShowcaseHeader(colorScheme: colorScheme),
            const SizedBox(height: 16),
            _RequestActionPanel(
              isRequesting: _isRequesting,
              onRefresh: _loadShowcaseData,
              onFailure: () => _loadShowcaseData(shouldFail: true),
              onSubmit: _submitAction,
              onPopup: _showRequestPopup,
            ),
            const SizedBox(height: 16),
            _ResultPanel(result: _result, onRetry: _loadShowcaseData),
            const SizedBox(height: 16),
            const _FlowPanel(),
          ],
        ),
      ),
    );
  }

  Future<void> _loadShowcaseData({bool shouldFail = false}) async {
    if (_isRequesting) {
      return;
    }

    setState(() => _isRequesting = true);
    AppDialog.showLoading(msg: 'Requesting /api/showcase');

    late final Result<List<_ShowcaseMetric>> result;
    try {
      result = await _client.fetchShowcaseData(shouldFail: shouldFail);
    } finally {
      AppDialog.hideLoading();
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _isRequesting = false;
      _result = result;
    });

    result.when(
      success:
          (metrics) => AppDialog.showInfo(
            'Loaded ${metrics.length} records',
          ),
      failure:
          (_) => AppDialog.showError(
            'Request failed and rendered an error state',
          ),
    );
  }

  Future<void> _submitAction() async {
    final confirmed = await AppDialog.showConfirm(
      title: 'Submit showcase action?',
      message: 'This simulates a POST request and then shows global feedback.',
      confirmText: 'Confirm',
      cancelText: 'Cancel',
    );
    if (!confirmed || !mounted) {
      return;
    }

    AppDialog.showLoading(msg: 'Submitting /api/showcase');
    try {
      await _client.submitAction();
    } finally {
      AppDialog.hideLoading();
    }
    if (!mounted) {
      return;
    }

    AppDialog.showInfo('Showcase action submitted');
  }

  void _showRequestPopup(BuildContext targetContext) {
    AppDialog.showPopup(
      targetContext: targetContext,
      tag: _popupTag,
      builder: (_) => const _RequestDetailsPopup(tag: _popupTag),
    );
  }
}

class _ShowcaseHeader extends StatelessWidget {
  const _ShowcaseHeader({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.route_outlined, color: colorScheme.onPrimaryContainer),
            const SizedBox(height: 12),
            Text(
              'Capability Demos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Network + Global Feedback',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestActionPanel extends StatelessWidget {
  const _RequestActionPanel({
    required this.isRequesting,
    required this.onRefresh,
    required this.onFailure,
    required this.onSubmit,
    required this.onPopup,
  });

  final bool isRequesting;
  final VoidCallback onRefresh;
  final VoidCallback onFailure;
  final VoidCallback onSubmit;
  final ValueChanged<BuildContext> onPopup;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.http_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Request flow',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This isolated feature demonstrates request loading, toast, '
              'confirm dialog, popup window, and Result state rendering.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: isRequesting ? null : onRefresh,
                  icon: const Icon(Icons.sync),
                  label: const Text('Refresh data'),
                ),
                OutlinedButton.icon(
                  onPressed: isRequesting ? null : onFailure,
                  icon: const Icon(Icons.report_gmailerrorred_outlined),
                  label: const Text('Simulate failure'),
                ),
                FilledButton.tonalIcon(
                  onPressed: isRequesting ? null : onSubmit,
                  icon: const Icon(Icons.upload_outlined),
                  label: const Text('Submit action'),
                ),
                Builder(
                  builder: (buttonContext) {
                    return OutlinedButton.icon(
                      onPressed: () => onPopup(buttonContext),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Show request popup'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.result, required this.onRetry});

  final Result<List<_ShowcaseMetric>> result;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data state',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ResultStateWidget<List<_ShowcaseMetric>>(
              result: result,
              onRetry: onRetry,
              dataBuilder: (context, metrics) {
                return Column(
                  children: [
                    for (final metric in metrics) ...[
                      _MetricTile(metric: metric),
                      if (metric != metrics.last) const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final _ShowcaseMetric metric;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(metric.icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              metric.value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowPanel extends StatelessWidget {
  const _FlowPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Covered capabilities',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _FlowStep(
              icon: Icons.hourglass_top,
              title: 'loading',
              body: 'Global loading appears while fake requests are pending.',
              color: colorScheme.primary,
            ),
            const SizedBox(height: 10),
            _FlowStep(
              icon: Icons.notifications_active_outlined,
              title: 'toast',
              body: 'Success and failure branches show global feedback.',
              color: colorScheme.tertiary,
            ),
            const SizedBox(height: 10),
            _FlowStep(
              icon: Icons.help_outline,
              title: 'dialog',
              body: 'A confirm dialog gates the submit action.',
              color: colorScheme.secondary,
            ),
            const SizedBox(height: 10),
            _FlowStep(
              icon: Icons.call_to_action_outlined,
              title: 'popup window',
              body: 'A popup is attached to the triggering button.',
              color: colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestDetailsPopup extends StatelessWidget {
  const _RequestDetailsPopup({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      color: colorScheme.surface,
      child: SizedBox(
        width: 280,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics_outlined, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'PopupWindow: request details',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => AppDialog.dismissPopup(tag: tag),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const _PopupLine(label: 'Endpoint', value: '/api/showcase'),
              const _PopupLine(label: 'Retry', value: '0 / 2'),
              const _PopupLine(label: 'Timeout', value: '800 ms'),
              const _PopupLine(label: 'Cache', value: 'memory fallback'),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopupLine extends StatelessWidget {
  const _PopupLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

final class _ShowcaseMetric {
  const _ShowcaseMetric({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
}

final class _ShowcaseDemoApi {
  const _ShowcaseDemoApi();

  static const seedMetrics = [
    _ShowcaseMetric(
      label: 'Conversion rate',
      value: '18.6%',
      subtitle: 'GET /api/showcase/conversion',
      icon: Icons.trending_up,
    ),
    _ShowcaseMetric(
      label: 'Pending items',
      value: '24',
      subtitle: 'GET /api/showcase/items',
      icon: Icons.assignment_late_outlined,
    ),
    _ShowcaseMetric(
      label: 'Daily volume',
      value: '12.8k',
      subtitle: 'GET /api/showcase/volume',
      icon: Icons.stacked_line_chart,
    ),
  ];

  Future<Result<List<_ShowcaseMetric>>> fetchShowcaseData({
    required bool shouldFail,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    if (shouldFail) {
      return const Result.failure(
        Failure(
          code: FailureCode.badResponse,
          detail: 'Service unavailable',
        ),
      );
    }

    return const Result.success(seedMetrics);
  }

  Future<void> submitAction() {
    return Future<void>.delayed(const Duration(milliseconds: 650));
  }
}
