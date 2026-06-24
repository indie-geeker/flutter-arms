import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class Demo2Page extends ConsumerWidget {
  const Demo2Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo2')),
      body: const Center(
        child: Text('Demo2 Page'),
      ),
    );
  }
}
