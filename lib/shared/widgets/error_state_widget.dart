import 'package:flutter/material.dart';

/// 错误态组件。
class ErrorStateWidget extends StatelessWidget {
  /// 构造函数。
  const ErrorStateWidget({
    required this.message,
    super.key,
    this.onRetry,
    this.child,
  });

  /// 错误文案。
  final String message;

  /// 重试回调。
  final VoidCallback? onRetry;

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
          const Icon(Icons.error_outline, size: 40),
          const SizedBox(height: 8),
          Text(message),
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ],
      ),
    );
  }
}
