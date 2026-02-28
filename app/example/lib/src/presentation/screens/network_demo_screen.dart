import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/i_network_demo_repository.dart';
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
      ref.read(networkDemoNotifierProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(networkDemoNotifierProvider);
    final notifier = ref.read(networkDemoNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: state.isLoading ? null : () => notifier.fetch(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _NetworkDemoBody(state: state, onFetch: notifier.fetch),
      ),
    );
  }
}

class _NetworkDemoBody extends StatelessWidget {
  final NetworkDemoState state;
  final Future<void> Function({DemoCacheMode? cacheMode}) onFetch;

  const _NetworkDemoBody({required this.state, required this.onFetch});

  @override
  Widget build(BuildContext context) {
    if (!state.available) {
      return const Center(
        child: Text(
          'Full-stack profile is disabled.\nRun with ARMS_EXAMPLE_FULL_STACK=true.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Mode:'),
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
              items: DemoCacheMode.values.map((mode) {
                return DropdownMenuItem<DemoCacheMode>(
                  value: mode,
                  child: Text(_labelForMode(mode)),
                );
              }).toList(growable: false),
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
              state.fromCache ? 'Source: cache' : 'Source: network',
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
                    child: const Text('Retry'),
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
              ? const Center(child: Text('No posts yet.'))
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

  String _labelForMode(DemoCacheMode mode) {
    switch (mode) {
      case DemoCacheMode.cacheFirst:
        return 'cacheFirst';
      case DemoCacheMode.networkFirst:
        return 'networkFirst';
      case DemoCacheMode.disabled:
        return 'disabled';
    }
  }
}
