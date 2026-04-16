import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Feed Tab 页。
@RoutePage()
class FeedPage extends StatelessWidget {
  /// 构造函数。
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Feed Page')),
    );
  }
}
