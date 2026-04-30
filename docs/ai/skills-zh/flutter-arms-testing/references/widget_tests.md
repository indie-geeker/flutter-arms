# Widget 测试

Widget 测试验证 UI 行为：渲染、点击、导航、与 provider 的接线。它们比单元测试多两层包装：

- `TranslationProvider` —— 否则 `context.t.xxx` 会抛异常。
- `ProviderScope` —— 否则任何 Riverpod 读取都会失败。

## 文件位置

`test/features/<f>/presentation/pages/<f>_page_test.dart` —— 镜像 `lib/`。

## 骨架

```dart
import 'package:flutter/material.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:flutter_arms/features/<f>/presentation/pages/<f>_page.dart';
import 'package:flutter_arms/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockKvStorage extends Mock implements KvStorage {}
// 按需加其它 mock（UseCase、Repository 等）

/// 以必要的 provider 接线方式 pump <F>Page。
Future<void> _pump<F>Page(
  WidgetTester tester, {
  required _MockKvStorage storage,
  // 依赖按具名参数继续加
}) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          kvStorageProvider.overrideWithValue(storage),
          // + 其它 override
        ],
        child: const MaterialApp(home: <F>Page()),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    // 在这里注册非原始类型的 fallback。
  });

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  group('<F>Page', () {
    testWidgets('renders initial state', (tester) async {
      final storage = _MockKvStorage();
      // stub 页面在 initState / build 里会读的内容。
      when(() => storage.getAccessToken()).thenReturn(null);

      await _pump<F>Page(tester, storage: storage);
      await tester.pumpAndSettle();

      expect(find.text('Expected text'), findsOneWidget);
    });
  });
}
```

要点：

- **`TranslationProvider` 包 `ProviderScope`**（不是反过来）。slang 需要在最外层，内部任何 page 才能访问 `context.t`。
- **`LocaleSettings.setLocaleSync(AppLocale.en)` 放 `setUp` 里**，让文本断言有确定性。如果测中文特定行为，设 `AppLocale.zh` 并断言中文字符串。
- **`MaterialApp(home: ...)`** 提供默认的 Material 主题和 MediaQuery，很多 widget 依赖。
- **`_pump<F>Page` 是 helper** —— 把样板抽出来，让每个测试专注场景。

## 常用套路

### 按文本查找

```dart
expect(find.text('Logout'), findsOneWidget);
expect(find.textContaining('error'), findsWidgets);
```

文本断言依赖当前 locale。`setUp` 里设了 `AppLocale.zh` 就断言中文。

### 按图标 / widget 类型查找

```dart
expect(find.byIcon(Icons.person), findsOneWidget);
expect(find.byType(AppButton), findsOneWidget);
```

### 按 predicate 查找（自定义绘制 widget）

取自 `profile_page_test.dart`：

```dart
final purpleCircle = find.byWidgetPredicate((widget) {
  if (widget is Container) {
    final decoration = widget.decoration;
    if (decoration is BoxDecoration) {
      return decoration.color == const Color(0xFF7C3AED);
    }
  }
  return false;
});
expect(purpleCircle, findsOneWidget);
```

当 widget 没有可访问的文本/语义标签时使用。

### 点击并 pump

```dart
await tester.tap(find.byIcon(Icons.add));
await tester.pumpAndSettle();  // 清空动画 + 微任务

expect(find.byType(AlertDialog), findsOneWidget);
```

动作之后都要 `await tester.pump()`（单帧）或 `pumpAndSettle()`（直到空闲）。否则 widget 还没 rebuild，断言会竞态。

### 验证动作派发到 provider

```dart
Color? capturedColor;
when(() => storage.setThemeSeedColor(any())).thenAnswer((inv) async {
  capturedColor = inv.positionalArguments.first as Color;
});

await _pump<F>Page(tester, storage: storage);
await tester.tap(find.byWidgetPredicate(/* 匹配紫色 */));
await tester.pump();

expect(capturedColor, equals(const Color(0xFF7C3AED)));
```

用 `thenAnswer` 的副作用捕获调用再断言。适合难以直接观察 provider 状态变化的场景。

### 断言 SegmentedButton 的选中项

```dart
final segmented = tester.widget<SegmentedButton<ThemeMode>>(
  find.byType(SegmentedButton<ThemeMode>),
);
expect(segmented.selected, equals({ThemeMode.system}));
```

`tester.widget<T>(finder)` 可取出 widget 实例以直接访问属性。

## Stub KvStorage（高频，建议抽出来）

```dart
_MockKvStorage _stubStorage() {
  final s = _MockKvStorage();
  when(s.getThemeMode).thenReturn(ThemeMode.system);
  when(s.getThemeSeedColor).thenReturn(const Color(0xFF1D4ED8));
  when(s.getLocale).thenReturn(null);
  when(s.getAccessToken).thenReturn(null);
  when(s.getUserMap).thenReturn(null);
  return s;
}
```

写在测试文件顶部作为私有 helper（`_stubStorage`），或者当多个测试文件都要用时提升到共享 fixture。

### 为 ViewModel 驱动的页面 mock UseCase

如果页面读的 ViewModel 会走网络，像 ViewModel 测试一样 override UseCase provider：

```dart
class _MockGet<F>UseCase extends Mock implements Get<F>UseCase {}

Future<void> _pump<F>Page(
  WidgetTester tester, {
  required _MockGet<F>UseCase useCase,
}) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          get<F>UseCaseProvider.overrideWithValue(useCase),
        ],
        child: const MaterialApp(home: <F>Page()),
      ),
    ),
  );
}
```

页面读 ViewModel，ViewModel 读 UseCase（现在是 mock），最终页面由 stub 数据驱动。

## AutoRoute 导航测试

AutoRoute 默认用 `context.router.push(...)`。想验证点击触发导航：

- 最简：用 `MaterialApp(home: ...)`，断言目标页（若它是子 widget）出现，或者某个 dialog/bottom sheet 出现。
- 更彻底：测试里用 `RootStackRouter` 加 stub，验证 push。通常过度了——大多数 widget 测试聚焦单页面。

顶层导航（Login → Home）更适合在 ViewModel 测试里看 `isLoginSuccess` 标志。

## 避免清单

- `testWidgets` 没包 `TranslationProvider` —— `context.t.xxx` 会立刻因类型错误抛。
- `setUp` 漏了 `LocaleSettings.setLocaleSync` —— 断言对环境敏感，会飞。
- 断中文时 locale 设成了 English（反之亦然）—— 检查 `setUp` 配置。
- 动作后没 `await pump` / `pumpAndSettle` —— 状态还没传播就断言。
- 为了让 widget 测试通过就 override `dioProvider` —— 应该 override 页面真正读取的 UseCase 或 Repository。
- 到处用 `find.byKey` —— 优先语义查询（`find.text`、`find.byIcon`、`find.byType`）。只有在无法避免时（比如区分同型 list item）才用 Key。
- 让页面真实的 `initState` 自动触发网络 —— 如果页面用 `WidgetsBinding.instance.addPostFrameCallback` 调 `load()`，**必须** stub UseCase，否则测试会挂在真实 Future 上。

## 页面覆盖率清单

- [ ] 初始渲染：预期文本/图标存在，错误/空状态不显示。
- [ ] 关键交互：按钮点击派发正确动作（通过 mock 副作用或 state 变化验证）。
- [ ] Loading：异步动作挂起时加载指示器可见。
- [ ] Error：state.error 被设置时 `AppDialog.showError` 或内联错误渲染。
- [ ] Empty：列表为空且不在 loading 时，`EmptyStateWidget` 出现。
- [ ] 本地化：至少一个测试断言某个翻译字符串，防 i18n 回归。
