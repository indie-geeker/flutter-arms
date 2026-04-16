import 'package:flutter/material.dart';

/// 骨架屏组件。
class SkeletonLoader extends StatelessWidget {
  /// 构造函数。
  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  /// 宽度。
  final double width;

  /// 高度。
  final double height;

  /// 圆角。
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
