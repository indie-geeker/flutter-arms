import 'package:flutter/material.dart';

/// 加载态组件。
class LoadingWidget extends StatelessWidget {
  /// 构造函数。
  const LoadingWidget({super.key, this.child});

  /// 自定义内容。
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Center(child: child ?? const CircularProgressIndicator());
  }
}
