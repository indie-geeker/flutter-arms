# UI 错误展示

UI 的活儿很少：从 state 读 `Failure?`，通过 `context.failureMessage(failure)` 转成字符串，显示出来。三种常见渲染形式，以及各自的适用场景。

## 1. 全局错误提示（大多数瞬时失败）

适用：用户发起了动作（登录、保存、删除），失败了，他们应该看到消息并可选重试。

```dart
// 在 ConsumerWidget.build() 内：
ref.listen(featureViewModelProvider, (previous, next) {
  final failure = next.error;
  if (failure != null && failure != previous?.error) {
    AppDialog.showError(context.failureMessage(failure));
  }
});
```

要点：
- 用 `ref.listen`，不是 `ref.watch` —— 弹对话框是副作用，绝不能触发 rebuild。
- 用 `failure != previous?.error` 做守卫，避免同 error 重复弹出。
- `AppDialog.showError` 是共享 helper，位于 `lib/shared/dialogs/app_dialog.dart`。
- 错误不要用 `SnackBar` —— 大屏用户容易错过，也无法长按复制。

`login_form.dart` 的例子：

```dart
ref.listen(loginViewModelProvider, (previous, next) {
  final failure = next.error;
  if (failure != null) {
    AppDialog.showError(context.failureMessage(failure));
  }
  if (next.isLoginSuccess) {
    context.router.replace(const HomeRoute());
  }
});
```

## 2. 全屏错误组件（首屏加载失败且无陈旧数据可退化）

适用：某页首次加载失败，也没有旧数据可以退化显示。整个 body 变成错误界面 + 重试按钮。

```dart
if (state.error != null && state.items.isEmpty) {
  return ErrorStateWidget(
    message: context.failureMessage(state.error!),
    onRetry: () =>
        ref.read(featureViewModelProvider.notifier).load(),
  );
}
```

`ErrorStateWidget` 位于 `lib/shared/widgets/error_state_widget.dart`。对可重试的动作（通常是读请求）传 `onRetry`。

## 3. 内联错误（表单、校验）

适用：表单某个字段校验失败，或希望错误显示在输入框旁而不是模态框里。

```dart
if (state.error?.code == FailureCode.validation)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: SelectableText.rich(
      TextSpan(
        text: context.failureMessage(state.error!),
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    ),
  ),
```

为什么用 `SelectableText.rich`：
- 用户可长按复制消息——方便提工单。
- 支持主题样式（主题红色）。
- 与 `Text` 不同，不会静默截断长消息。

## 三者组合使用

同一页面常常需要用不止一种：

- 全屏 `ErrorStateWidget` 用于首屏加载失败。
- 对话框用于瞬时动作失败（保存、删除）。
- 内联 `SelectableText.rich` 用于表单校验。

三者互补，只要各自触发源正确（rebuild vs listen），就无需协调。

## 禁用清单

### 永不直接展示原始异常

```dart
// ❌ 错
Text(state.error.toString())
// 会显示：Failure(code: FailureCode.badResponse, detail: ..., cause: DioException [...])

// ❌ 错
Text(state.error!.cause.toString())
// 会泄露栈和库类名

// ✅ 对
Text(context.failureMessage(state.error!))
// 会显示："服务响应异常" 或服务端提供的 detail
```

### 永不从 UI 对 ViewModel 做 `try/catch`

```dart
// ❌ 错
onPressed: () async {
  try {
    await ref.read(vmProvider.notifier).login();
  } catch (e) {
    showDialog(...);
  }
}

// ✅ 对
onPressed: () => ref.read(vmProvider.notifier).login(),
// + ref.listen 处理错误
```

ViewModel 不抛异常，它更新 state。UI 层的 `try/catch` 是"上游错误模型没走通"的 code smell。

### 永不用 SnackBar 展示错误

SnackBar：
- 自动消失 —— 用户容易错过。
- 不适合长消息。
- 不能长按复制。
- 多个错误快速到达时堆叠很别扭。

改用 `AppDialog.showError` 或内联 `SelectableText.rich`。

### 永不硬编码字符串

```dart
// ❌ 错
AppDialog.showError('登录失败，请重试');

// ✅ 对
AppDialog.showError(context.failureMessage(failure));
```

正确版本：
- 基于当前语言显示本地化文本。
- 对 `badResponse` / `validation` 在有 `detail` 时会优先用服务端消息。
- 新增 i18n 语言时自动跟进。

## 可访问性加成

`SelectableText.rich` 与屏幕阅读器配合良好。瞬时错误消息统一用 `AppDialog.showError` helper，避免各 feature 直接依赖 overlay 实现。

## Checklist

- [ ] 错误通过 `context.failureMessage(failure)` 展示，不用 `toString()`。
- [ ] 对话框在 `ref.listen` 中触发，不在 `ref.watch` 中。
- [ ] 用 `failure != previous?.error` 做守卫避免重复。
- [ ] 内联错误用 `SelectableText.rich` + `colorScheme.error`。
- [ ] 全屏错误用 `ErrorStateWidget`，可选 `onRetry`。
- [ ] UI 层没有硬编码错误字符串。
- [ ] 没有围绕 ViewModel 调用的 `try/catch`。
