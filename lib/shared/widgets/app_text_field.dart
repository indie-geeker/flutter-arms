import 'package:flutter/material.dart';

/// 通用输入框。
class AppTextField extends StatefulWidget {
  /// 构造函数。
  const AppTextField({
    required this.label,
    required this.onChanged,
    super.key,
    this.initialValue,
    this.isPassword = false,
    this.keyboardType,
    this.errorText,
  });

  /// 标签文案。
  final String label;

  /// 内容变化回调。
  final ValueChanged<String> onChanged;

  /// 初始值。
  final String? initialValue;

  /// 是否密码输入。
  final bool isPassword;

  /// 键盘类型。
  final TextInputType? keyboardType;

  /// 错误文案。
  final String? errorText;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword ? _obscureText : false,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        border: const OutlineInputBorder(),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
              )
            : null,
      ),
    );
  }
}
