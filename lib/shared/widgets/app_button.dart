import 'package:flutter/material.dart';

/// 通用按钮。
class AppButton extends StatelessWidget {
  /// 构造函数。
  const AppButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.enabled = true,
  });

  /// 按钮文本。
  final String text;

  /// 点击回调。
  final VoidCallback? onPressed;

  /// 是否加载中。
  final bool isLoading;

  /// 是否可用。
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || !enabled;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: disabled ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(text),
      ),
    );
  }
}
