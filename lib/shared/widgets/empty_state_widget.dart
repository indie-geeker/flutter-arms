import 'package:flutter/material.dart';

/// 空态组件。
class EmptyStateWidget extends StatelessWidget {
  /// 构造函数。
  const EmptyStateWidget({
    required this.message,
    super.key,
    this.child,
  });

  /// 提示文案。
  final String message;

  /// 自定义内容。
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Center(child: child);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.inbox_outlined, size: 40),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }
}
