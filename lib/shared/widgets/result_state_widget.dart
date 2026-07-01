import 'package:flutter/material.dart';
import 'package:flutter_arms/core/extensions/build_context_ext.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/shared/widgets/empty_state_widget.dart';
import 'package:flutter_arms/shared/widgets/error_state_widget.dart';
import 'package:flutter_arms/shared/widgets/loading_widget.dart';

/// 统一的 Result 状态处理包装器，自动根据 Result 类型切换 UI。
/// 当 result 为 null 时，默认展示 LoadingWidget。
class ResultStateWidget<T> extends StatelessWidget {
  /// 构造函数。
  const ResultStateWidget({
    required this.result,
    required this.dataBuilder,
    super.key,
    this.onRetry,
    this.loadingWidget,
    this.errorBuilder,
    this.emptyBuilder,
    this.isEmpty,
    this.emptyMessage = '暂无数据',
  });

  /// 当前的异步结果。传入 null 表示正在加载。
  final Result<T>? result;

  /// 加载成功时的数据构建器。
  final Widget Function(BuildContext context, T data) dataBuilder;

  /// 失败重试的回调。
  final VoidCallback? onRetry;

  /// 自定义的加载组件。
  final Widget? loadingWidget;

  /// 自定义的错误构建器。
  final Widget Function(BuildContext context, String message)? errorBuilder;

  /// 自定义的空视图构建器。
  final WidgetBuilder? emptyBuilder;

  /// 默认空态文案。
  final String emptyMessage;

  /// 用于判断数据是否为空的回调。如果不提供，默认行为是：
  /// - 数据是 List 且 isEmpty 为 true 时视为空
  /// - 其他类型不判定为空（直接调用 dataBuilder）
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return loadingWidget ?? const Center(child: LoadingWidget());
    }

    return result!.when(
      success: (data) {
        final dataIsEmpty =
            isEmpty?.call(data) ?? (data is Iterable && data.isEmpty);

        if (dataIsEmpty) {
          return emptyBuilder?.call(context) ??
              Center(child: EmptyStateWidget(message: emptyMessage));
        }

        return dataBuilder(context, data);
      },
      failure: (failure) {
        final message = context.failureMessage(failure);
        if (errorBuilder != null) {
          return errorBuilder!(context, message);
        }
        return Center(
          child: ErrorStateWidget(
            message: message,
            onRetry: onRetry,
          ),
        );
      },
    );
  }
}
