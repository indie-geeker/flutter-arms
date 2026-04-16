import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Explore Tab 页。
@RoutePage()
class ExplorePage extends StatelessWidget {
  /// 构造函数。
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Explore Page')),
    );
  }
}
