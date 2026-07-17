import 'dart:async';

import 'package:flutter/material.dart';
import 'package:super_overlay/super_overlay.dart';

/// 自定义弹窗内容构建器。
typedef AppDialogBuilder<T> =
    Widget Function(
      BuildContext context,
      Future<void> Function([T? result]) close,
    );

/// 统一弹窗工具。
class AppDialog {
  AppDialog._();

  static const _confirmDialogTag = 'app-confirm-dialog';
  static const _popupTag = 'app-popup-window';

  /// 展示错误提示。
  static void showError(String message) {
    SuperOverlay.toast(message);
  }

  /// 展示普通提示。
  static void showInfo(String message) {
    SuperOverlay.toast(message);
  }

  /// 展示全局 Loading。
  static void showLoading({String msg = 'Loading...'}) {
    SuperOverlay.loading.show(message: msg);
  }

  /// 隐藏全局 Loading。
  static void hideLoading() {
    unawaited(SuperOverlay.loading.close());
  }

  /// 展示确认弹窗。
  static Future<bool> showConfirm({
    required String title,
    required String message,
    String confirmText = '确认',
    String cancelText = '取消',
    String tag = _confirmDialogTag,
  }) async {
    final result = await showCustom<bool>(
      tag: tag,
      builder:
          (context, close) => _ConfirmDialog(
            title: title,
            message: message,
            confirmText: confirmText,
            cancelText: cancelText,
            onDecision: ({required bool confirmed}) => close(confirmed),
          ),
    );

    return result ?? false;
  }

  /// 展示自定义弹窗，并返回关闭时携带的 typed result。
  ///
  /// [builder] 获得的 `close` 只关闭当前弹窗对应的 [OverlayHandle]，不会发送
  /// 全局关闭命令或影响其它 overlay。
  static Future<T?> showCustom<T>({
    required AppDialogBuilder<T> builder,
    String? tag,
    bool dismissOnMaskTap = true,
    BuildContext? bindToWidget,
  }) {
    late final OverlayHandle<T> handle;
    handle = SuperOverlay.dialog.show<T>(
      builder: (context) => builder(context, handle.close),
      options: OverlayDialogOptions(
        tag: tag,
        strategy:
            tag == null
                ? OverlayStrategy.stack
                : OverlayStrategy.replaceExisting,
        dismissOnMaskTap: dismissOnMaskTap,
        bindToWidget: bindToWidget,
        barrierColor: Colors.black54,
      ),
    );
    return handle.closed;
  }

  /// 展示绑定在目标控件旁的 PopupWindow。
  static void showPopup({
    required BuildContext targetContext,
    required WidgetBuilder builder,
    String tag = _popupTag,
  }) {
    SuperOverlay.popup.show<void>(
      targetContext: targetContext,
      builder: builder,
      options: OverlayPopupOptions(
        tag: tag,
        strategy: OverlayStrategy.replaceExisting,
      ),
    );
  }

  /// 关闭 PopupWindow。
  static void dismissPopup({
    String tag = _popupTag,
    bool force = false,
  }) {
    unawaited(
      SuperOverlay.close<void>(
        target: OverlayCloseTarget.popup,
        tag: tag,
        force: force,
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.onDecision,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Future<void> Function({required bool confirmed}) onDecision;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      unawaited(onDecision(confirmed: false));
                    },
                    child: Text(cancelText),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      unawaited(onDecision(confirmed: true));
                    },
                    child: Text(confirmText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
