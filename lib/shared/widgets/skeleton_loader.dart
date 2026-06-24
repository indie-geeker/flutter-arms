import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white, // Shimmer requires a solid color to draw over
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
