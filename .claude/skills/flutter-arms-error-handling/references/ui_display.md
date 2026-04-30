# UI error display

The UI's job is tiny: read `Failure?` from state, convert to a string via `context.failureMessage(failure)`, show it. Three common render shapes and when to use each.

## 1. Error dialog (most transient failures)

Use when: the user tried an action (login, save, delete), it failed, and they should acknowledge the message and optionally retry.

```dart
// Inside ConsumerWidget.build():
ref.listen(featureViewModelProvider, (previous, next) {
  final failure = next.error;
  if (failure != null && failure != previous?.error) {
    AppDialog.showError(context, context.failureMessage(failure));
  }
});
```

Key points:
- `ref.listen`, not `ref.watch` — showing a dialog is a side effect, must not trigger a rebuild.
- Guard with `failure != previous?.error` so identical rebuilds don't re-fire the dialog.
- `AppDialog.showError` is the shared helper at `lib/shared/dialogs/app_dialog.dart`.
- Don't use `SnackBar` for errors — users miss them on larger screens and can't copy-paste.

Example from `login_form.dart`:

```dart
ref.listen(loginViewModelProvider, (previous, next) {
  final failure = next.error;
  if (failure != null) {
    AppDialog.showError(context, context.failureMessage(failure));
  }
  if (next.isLoginSuccess) {
    context.router.replace(const HomeRoute());
  }
});
```

## 2. Full-screen error widget (initial load fails, nothing to show)

Use when: a page's first load failed and there's no stale data to fall back to. The whole body becomes an error screen with a retry button.

```dart
if (state.error != null && state.items.isEmpty) {
  return ErrorStateWidget(
    message: context.failureMessage(state.error!),
    onRetry: () =>
        ref.read(featureViewModelProvider.notifier).load(),
  );
}
```

`ErrorStateWidget` lives at `lib/shared/widgets/error_state_widget.dart`. Pass `onRetry` if the action is safely retryable (reads usually are).

## 3. Inline error (forms, validation)

Use when: validation failed on a specific form field, or you want the error visible alongside the input rather than in a modal.

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

Why `SelectableText.rich`:
- Users can long-press and copy the message — helpful for support tickets.
- Supports styling (red color from theme).
- Unlike `Text`, doesn't clip long messages silently.

## Combining the three

It's common to use more than one shape per page:

- Full-screen `ErrorStateWidget` for the initial-load-failed case.
- Dialog for transient action failures (save, delete).
- Inline `SelectableText.rich` for form validation.

They're complementary — no coordination needed as long as each uses the appropriate trigger (rebuild vs listen).

## What NOT to do

### Never display raw exceptions

```dart
// ❌ WRONG
Text(state.error.toString())
// shows: Failure(code: FailureCode.badResponse, detail: ..., cause: DioException [...])

// ❌ WRONG
Text(state.error!.cause.toString())
// leaks stack trace and library class names

// ✅ RIGHT
Text(context.failureMessage(state.error!))
// shows: "服务响应异常" or the server-provided detail
```

### Never `try/catch` the ViewModel from the UI

```dart
// ❌ WRONG
onPressed: () async {
  try {
    await ref.read(vmProvider.notifier).login();
  } catch (e) {
    showDialog(...);
  }
}

// ✅ RIGHT
onPressed: () => ref.read(vmProvider.notifier).login(),
// + ref.listen for the error
```

The ViewModel doesn't throw; it updates state. `try/catch` in the UI is a code smell meaning the error model wasn't followed upstream.

### Never use SnackBars for errors

Snackbars:
- Auto-dismiss — users can miss them.
- Don't support long messages well.
- Can't be long-pressed to copy.
- Stack awkwardly if multiple errors arrive fast.

Use `AppDialog.showError` or inline `SelectableText.rich`.

### Never hardcode strings

```dart
// ❌ WRONG
AppDialog.showError(context, '登录失败，请重试');

// ✅ RIGHT
AppDialog.showError(context, context.failureMessage(failure));
```

The right version:
- Shows localized text based on the current locale.
- Falls back to server-provided `detail` for `badResponse` / `validation` when available.
- Evolves automatically as you add i18n locales.

## Accessibility bonus

`SelectableText.rich` works well with screen readers. For dialog messages, use the `AppDialog.showError` helper which wraps the content in an accessible `AlertDialog`.

## Checklist

- [ ] Error displayed via `context.failureMessage(failure)`, never `toString()`.
- [ ] Dialog shown in `ref.listen`, not `ref.watch`.
- [ ] Guarded with `failure != previous?.error` to avoid duplicate dialogs.
- [ ] Inline errors use `SelectableText.rich` with `colorScheme.error`.
- [ ] Full-screen errors use `ErrorStateWidget` with optional `onRetry`.
- [ ] No hardcoded error strings in the UI layer.
- [ ] No `try/catch` around ViewModel calls.
