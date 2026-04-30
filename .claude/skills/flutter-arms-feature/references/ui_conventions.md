# UI conventions

## Private widget classes, not `_buildXxx` methods

```dart
// GOOD
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Text(context.t.auth.welcomeBack);
  }
}

// BAD
Widget _buildLoginHeader(BuildContext context) {
  return Text(context.t.auth.welcomeBack);
}
```

Reasons: const-ability, smaller dirty subtrees on rebuild, clearer widget tree in DevTools, easier to test with `find.byType(_LoginHeader)`, avoids accidental closures over mutable state.

Name with leading underscore (`_`). Place at the bottom of the same file with a separator comment (matches `profile_page.dart`):

```dart
// ---------------------------------------------------------------------------
// _LoginHeader
// ---------------------------------------------------------------------------

class _LoginHeader extends StatelessWidget { ... }
```

## Shared widgets in `lib/shared/widgets/`

Use these for anything that appears across features:

- `AppButton` — primary filled button with `isLoading` and `enabled` props.
- `AppTextField` — form field with label, `initialValue`, `isPassword` toggle.
- `EmptyStateWidget` — for "no data" screens.
- `ErrorStateWidget` — for full-screen error; pair with `context.failureMessage`.
- `LoadingWidget` / `SkeletonLoader` — for loading screens / placeholders.
- `AppDialog.showError(context, String message)` — localized error dialog.

Don't inline new variants. Extend the shared widget (add a named constructor or extra prop) or create a new file under `lib/shared/widgets/`.

## Error rendering

Dialog-style (most common):

```dart
ref.listen(%feature%ViewModelProvider, (previous, next) {
  final failure = next.error;
  if (failure != null && failure != previous?.error) {
    AppDialog.showError(context, context.failureMessage(failure));
  }
});
```

Inline (full-page errors, forms):

```dart
if (state.error != null)
  SelectableText.rich(
    TextSpan(
      text: context.failureMessage(state.error!),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  ),
```

Why `SelectableText.rich` not SnackBar: users should be able to long-press and copy errors (useful for support), and SnackBar is easily missed on larger screens.

## Theme access

Use the `BuildContextExt` extension (`core/extensions/build_context_ext.dart`):

```dart
context.theme   // ThemeData
context.colors  // ColorScheme
```

Typical usage:

```dart
Text(
  'Hello',
  style: context.theme.textTheme.titleMedium?.copyWith(
    color: context.colors.primary,
  ),
)
```

Use the Material 3 names: `titleLarge/titleMedium/titleSmall`, `headlineLarge/headlineMedium/headlineSmall`, `bodyLarge/bodyMedium/bodySmall`. Do NOT use the legacy `headline5/headline6/subtitle1` names — they're deprecated and inconsistent in the Flutter 3.x theme.

## Responsive and platform

- `LayoutBuilder` / `MediaQuery` for responsive layout.
- `core/utils/platform_utils.dart` for platform branches (desktop vs mobile).
- Don't branch on `Platform.isIOS` inside widgets — most visual differences are already encoded in `Theme`.

## Icons and images

- Material icons: `Icons.*`.
- Static assets: `AssetImage(...)` with the path declared under `flutter.assets` in `pubspec.yaml`.
- Remote images: `cached_network_image` (already in deps). Always supply `errorBuilder` and `placeholder`.

  ```dart
  CachedNetworkImage(
    imageUrl: url,
    placeholder: (_, __) => const SkeletonLoader(),
    errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
  )
  ```

## Forms

`AppTextField` sets sensible defaults. When you add a new field:

- `textCapitalization: TextCapitalization.sentences` for free-text.
- `keyboardType: TextInputType.emailAddress` / `.number` / `.phone` as appropriate.
- `textInputAction: TextInputAction.next` for non-terminal fields, `.done` for the last one.

Don't use HTML-style `Form` + `FormField` unless the page genuinely needs per-field `Validator`s. Most forms here drive validation from the ViewModel, with the UI just rendering `Failure?`.

## What to AVOID

- `Widget _buildXxx()` helper methods.
- Inline `TextStyle(fontSize: 16, color: Colors.red)` — use theme.
- SnackBars for errors — use `AppDialog.showError` or `SelectableText.rich`.
- `print()` — use `ref.read(appLoggerProvider).info/debug/warning/error(...)`.
- `MediaQuery.of(context).size` without a `LayoutBuilder` / `OrientationBuilder` — it rebuilds the whole widget on any metric change. Use `context.size` or a builder.
- Manually managing `TextEditingController` in a StatefulWidget just to hold a string — put the value in the ViewModel state and use `initialValue` on the field.
