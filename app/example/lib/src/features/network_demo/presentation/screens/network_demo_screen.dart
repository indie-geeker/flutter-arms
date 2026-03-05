import 'package:auto_route/auto_route.dart';
import 'package:example/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:example/src/features/network_demo/domain/repositories/i_network_demo_repository.dart';
import '../notifiers/network_demo_notifier.dart';

@RoutePage()
class NetworkDemoScreen extends ConsumerStatefulWidget {
  const NetworkDemoScreen({super.key});

  @override
  ConsumerState<NetworkDemoScreen> createState() => _NetworkDemoScreenState();
}

class _NetworkDemoScreenState extends ConsumerState<NetworkDemoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(networkDemoProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(networkDemoProvider);
    final notifier = ref.read(networkDemoProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.networkDemo),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: state.isLoading ? null : () => notifier.fetch(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _NetworkDemoBody(
          state: state,
          onFetch: notifier.fetch,
          l10n: l10n,
        ),
      ),
    );
  }
}

class _NetworkDemoBody extends StatelessWidget {
  final NetworkDemoState state;
  final Future<void> Function({DemoCacheMode? cacheMode}) onFetch;
  final AppLocalizations l10n;

  const _NetworkDemoBody({
    required this.state,
    required this.onFetch,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (!state.available) {
      return Center(
        child: Text(
          l10n.fullStackProfileDisabled,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('${l10n.mode}:'),
            const SizedBox(width: 12),
            DropdownButton<DemoCacheMode>(
              value: state.cacheMode,
              onChanged: state.isLoading
                  ? null
                  : (DemoCacheMode? mode) {
                      if (mode != null) {
                        onFetch(cacheMode: mode);
                      }
                    },
              items: DemoCacheMode.values
                  .map((mode) {
                    return DropdownMenuItem<DemoCacheMode>(
                      value: mode,
                      child: Text(_labelForMode(mode, l10n)),
                    );
                  })
                  .toList(growable: false),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.posts.isNotEmpty)
          Chip(
            avatar: Icon(
              state.fromCache ? Icons.inventory_2_outlined : Icons.public,
              size: 18,
            ),
            label: Text(
              state.fromCache ? l10n.sourceCache : l10n.sourceNetwork,
            ),
          ),
        const SizedBox(height: 12),
        if (state.errorMessage != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => onFetch(cacheMode: state.cacheMode),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        if (state.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        Expanded(
          child: state.posts.isEmpty
              ? Center(child: Text(l10n.noPostsYet))
              : ListView.separated(
                  itemCount: state.posts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final post = state.posts[index];
                    return Card(
                      child: ListTile(
                        title: Text(post.title),
                        subtitle: Text(post.body),
                        leading: CircleAvatar(child: Text(post.id.toString())),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _labelForMode(DemoCacheMode mode, AppLocalizations l10n) {
    switch (mode) {
      case DemoCacheMode.cacheFirst:
        return l10n.cacheModeCacheFirst;
      case DemoCacheMode.networkFirst:
        return l10n.cacheModeNetworkFirst;
      case DemoCacheMode.disabled:
        return l10n.cacheModeDisabled;
    }
  }
}
