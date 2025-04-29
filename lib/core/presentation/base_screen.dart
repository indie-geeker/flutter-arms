// 共性行为:
// 通用UI组件（加载中、错误显示）
// 权限处理
// 主题配置
// 响应式布局逻辑

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/failures.dart';
import '../errors/result.dart';

abstract class BaseScreen extends ConsumerStatefulWidget {
  const BaseScreen({super.key});
}

abstract class BaseScreenState<T extends BaseScreen> extends ConsumerState<T> {
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  // 处理Result类型的通用方法
  void handleResult<T>(Result<T>? result, {
    required Function(T) onSuccess,
    required Function(Failure) onFailure,
  }) {
    if (result == null) return;
    
    result.fold(
      onSuccess: (success) => onSuccess(success),
      onFailure: (failure) {
        showErrorSnackBar(failure.message);
        onFailure(failure);
      },
    );
  }
}