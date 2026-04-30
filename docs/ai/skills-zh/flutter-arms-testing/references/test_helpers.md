# 测试 helper 与 fixture

跨测试复现的模式。每个测试文件内抽一次，或提升到 `test/helpers/` 下作为共享 fixture。

## Mock KvStorage stub

许多 widget 测试和 AuthNotifier 测试都需要 `KvStorage` stub。把下面的代码复制到测试文件里（或若多个文件都要用，放到 `test/helpers/mock_kv_storage.dart`）：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_arms/core/storage/kv_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockKvStorage extends Mock implements KvStorage {}

MockKvStorage stubKvStorage({
  ThemeMode themeMode = ThemeMode.system,
  Color seedColor = const Color(0xFF1D4ED8),
  String? locale,
  String? accessToken,
  String? refreshToken,
  Map<String, dynamic>? userMap,
  bool onboardingDone = false,
}) {
  final s = MockKvStorage();
  when(s.getThemeMode).thenReturn(themeMode);
  when(s.getThemeSeedColor).thenReturn(seedColor);
  when(s.getLocale).thenReturn(locale);
  when(s.getAccessToken).thenReturn(accessToken);
  when(s.getRefreshToken).thenReturn(refreshToken);
  when(s.getUserMap).thenReturn(userMap);
  when(s.isOnboardingDone).thenReturn(onboardingDone);
  return s;
}
```

用法：

```dart
final storage = stubKvStorage(accessToken: 'token-123');
// 接着用 storage...
```

## ProviderContainer builder

减少 ViewModel 测试里的样板：

```dart
ProviderContainer buildContainer(List<Override> overrides) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

// 用法：
final container = buildContainer([
  loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
]);
```

`addTearDown` 放在 helper 内部，测试主体更干净。

## Widget 测试封装器

带标准包装的通用 pump helper：

```dart
Future<void> pumpWithProviders(
  WidgetTester tester, {
  required Widget child,
  List<Override> overrides = const [],
}) {
  return tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: overrides,
        child: MaterialApp(home: child),
      ),
    ),
  );
}

// 用法：
await pumpWithProviders(
  tester,
  child: const FeaturePage(),
  overrides: [
    kvStorageProvider.overrideWithValue(storage),
  ],
);
```

## mocktail registerFallbackValue 清单

只要对非原始类型用了 `any()`，就要在 `setUpAll` 里注册 fallback。常见：

```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

class _FakeRequestOptions extends Fake implements RequestOptions {}
class _FakeResponse extends Fake implements Response<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRequestOptions());
    registerFallbackValue(_FakeResponse());
    registerFallbackValue(Colors.transparent);           // Color 参数
    registerFallbackValue(const Duration(seconds: 1));   // Duration 参数
    registerFallbackValue(<String, dynamic>{});          // Map<String, dynamic> 参数
  });

  // tests...
}
```

缺 fallback 的症状：`type 'Null' is not a subtype of type 'RequestOptions'`。

## setUp 里固定 locale

```dart
import 'package:flutter_arms/i18n/strings.g.dart';

setUp(() {
  LocaleSettings.setLocaleSync(AppLocale.en);
});
```

不设的话，测试会继承宿主 locale 或上一个测试遗留的设置。对 locale 特定的测试，内联覆盖：

```dart
testWidgets('renders Chinese labels', (tester) async {
  LocaleSettings.setLocaleSync(AppLocale.zh);
  // ...
});
```

## 精细控制异步的测试

需要精细控制异步完成时：

```dart
import 'dart:async';

test('loading stays true until UseCase resolves', () async {
  final completer = Completer<Result<List<Post>>>();
  when(() => mockUseCase()).thenAnswer((_) => completer.future);

  final container = buildContainer([
    getPostUseCaseProvider.overrideWithValue(mockUseCase),
  ]);

  // 启动动作 —— 不 await。
  final future = container.read(postViewModelProvider.notifier).load();

  // 此时应处于 loading。
  expect(container.read(postViewModelProvider).isLoading, isTrue);

  // 完成并 settle。
  completer.complete(const Result.success(<Post>[]));
  await future;

  expect(container.read(postViewModelProvider).isLoading, isFalse);
});
```

## 静默 Talker

Repository 测试注入真实但禁用的 `Talker`，避免日志噪音：

```dart
import 'package:talker/talker.dart';

late Talker logger;
setUp(() {
  logger = Talker(settings: TalkerSettings(enabled: false));
});
```

比 mock Talker 便宜，日志调用变成空操作。

## 共享 fixture 目录

如果某个 helper 被 3+ 个测试文件用到，迁到 `test/helpers/<name>.dart`：

```
test/
├── helpers/
│   ├── mock_kv_storage.dart
│   ├── pump_with_providers.dart
│   └── fallback_values.dart
├── core/
├── features/
└── ...
```

在测试文件里用相对路径 import：

```dart
import '../../../helpers/mock_kv_storage.dart';
```

Helper 要瘦 —— 每个只做一件事。把太多东西藏进 helper 会让测试主体看不懂。

## 避免清单

- 在测试主体里 `late` 字段，却在 helper 里访问 —— 顺序易错。
- 全局状态（测试文件里的顶层 `var`）—— 顺序敏感。
- `setUpAll` 做非幂等初始化（比如开 Hive box）—— 改用每个测试的 `setUp`。
- "以防万一"一上来全部 stub —— 测试可读性崩坏。只 stub 会走到的。
- 用 `sleep` 或 `Future.delayed(Duration.zero)` 等待异步 —— widget 用 `tester.pumpAndSettle()`，普通代码用 `await future`。
