# UI 约定

## 用私有 widget 类，不用 `_buildXxx` 方法

```dart
// 好
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Text(context.t.auth.welcomeBack);
  }
}

// 坏
Widget _buildLoginHeader(BuildContext context) {
  return Text(context.t.auth.welcomeBack);
}
```

理由：可 const、rebuild 时脏子树更小、DevTools 里 widget 树更清晰、测试时能 `find.byType(_LoginHeader)`、避免意外闭包持有可变状态。

用下划线前缀命名（`_`）。放在同一文件底部，用分隔注释标明（对照 `profile_page.dart`）：

```dart
// ---------------------------------------------------------------------------
// _LoginHeader
// ---------------------------------------------------------------------------

class _LoginHeader extends StatelessWidget { ... }
```

## 跨 feature 共享的 widget 放 `lib/shared/widgets/`

以下都在这里：

- `AppButton` —— 主按钮，支持 `isLoading` 和 `enabled`。
- `AppTextField` —— 表单字段，带 label、`initialValue`、`isPassword` 切换。
- `EmptyStateWidget` —— "无数据"屏。
- `ErrorStateWidget` —— 全屏错误；与 `context.failureMessage` 搭配。
- `LoadingWidget` / `SkeletonLoader` —— 加载屏 / 占位。
- `AppDialog.showError(context, String message)` —— 本地化错误对话框。

不要内联新变体。扩展共享 widget（加一个具名构造或新属性），或在 `lib/shared/widgets/` 下新建文件。

## 错误渲染

对话框（最常见）：

```dart
ref.listen(%feature%ViewModelProvider, (previous, next) {
  final failure = next.error;
  if (failure != null && failure != previous?.error) {
    AppDialog.showError(context, context.failureMessage(failure));
  }
});
```

内联（全屏错误、表单）：

```dart
if (state.error != null)
  SelectableText.rich(
    TextSpan(
      text: context.failureMessage(state.error!),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  ),
```

为什么用 `SelectableText.rich` 而非 SnackBar：用户应能长按复制（方便提 support 工单），SnackBar 在大屏容易被忽略。

## 访问主题

用 `BuildContextExt` 扩展（`core/extensions/build_context_ext.dart`）：

```dart
context.theme   // ThemeData
context.colors  // ColorScheme
```

常见用法：

```dart
Text(
  'Hello',
  style: context.theme.textTheme.titleMedium?.copyWith(
    color: context.colors.primary,
  ),
)
```

使用 Material 3 命名：`titleLarge/titleMedium/titleSmall`、`headlineLarge/headlineMedium/headlineSmall`、`bodyLarge/bodyMedium/bodySmall`。**不要**用遗留的 `headline5/headline6/subtitle1` —— 在 Flutter 3.x 主题里已废弃且不一致。

## 响应式与平台

- 用 `LayoutBuilder` / `MediaQuery` 做响应式。
- `core/utils/platform_utils.dart` 做平台分支（桌面 vs 移动）。
- 不要在 widget 里按 `Platform.isIOS` 分支 —— 多数视觉差异已经由 `Theme` 编码。

## 图标与图片

- Material 图标：`Icons.*`。
- 静态资源：`AssetImage(...)`，在 `pubspec.yaml` 的 `flutter.assets` 下声明路径。
- 远程图片：`cached_network_image`（已在依赖里）。始终提供 `errorBuilder` 和 `placeholder`。

  ```dart
  CachedNetworkImage(
    imageUrl: url,
    placeholder: (_, __) => const SkeletonLoader(),
    errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
  )
  ```

## 表单

`AppTextField` 带合理默认。新加字段时：

- 自由文本用 `textCapitalization: TextCapitalization.sentences`。
- 视情形设置 `keyboardType: TextInputType.emailAddress` / `.number` / `.phone`。
- 非末字段 `textInputAction: TextInputAction.next`，末字段 `.done`。

除非真的需要 per-field `Validator`，不要用 HTML 风格的 `Form` + `FormField`。本项目大多数表单的校验由 ViewModel 驱动，UI 只渲染 `Failure?`。

## 避免清单

- `Widget _buildXxx()` 辅助方法。
- 内联 `TextStyle(fontSize: 16, color: Colors.red)` —— 用主题。
- 用 SnackBar 展示错误 —— 用 `AppDialog.showError` 或 `SelectableText.rich`。
- `print()` —— 用 `ref.read(appLoggerProvider).info/debug/warning/error(...)`。
- 在没有 `LayoutBuilder` / `OrientationBuilder` 的情况下裸用 `MediaQuery.of(context).size` —— 任意 metric 变化都会触发整个 widget rebuild。用 `context.size` 或 builder。
- 为持有字符串而在 StatefulWidget 里手动管理 `TextEditingController` —— 值放到 ViewModel state，字段用 `initialValue`。
