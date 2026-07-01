---
name: flutter-arms-testing
description: Write and debug tests for a flutter_arms project using flutter_test + mocktail + ProviderContainer + TranslationProvider. Use this skill whenever the task involves tests in a flutter_arms project — writing a unit test, widget test, repository test, ViewModel test, debugging a failing test, understanding an architecture_test failure, adding a test-helper, setting up fixtures with mocktail, or overriding Riverpod providers for tests. Also triggered by: "write a test for this", "this test is failing", "mock the repository", "ProviderContainer", "testWidgets", "给这个加个测试", "架构测试报错", "the architecture test is red". Do NOT use mockito (not on the deps list), do NOT hand-roll fake notifiers, do NOT instantiate Notifiers with `new` outside a ProviderContainer. Apply proactively when the user shows test code or mentions any testing concept, even if they don't explicitly say "skill".
---

# flutter-arms-testing

flutter_arms 的测试用一套特定组合：`flutter_test`（内置）+ `mocktail`（mock）+ `flutter_riverpod` 的 `ProviderContainer`（覆盖 provider）+ `TranslationProvider`（支撑 slang 的 widget 测试）。再加上一条始终开启的架构测试，静态强制层级边界。

## 四种测试形态

| 形态 | 验证什么 | 工具 | Reference |
|---|---|---|---|
| **Repository 测试** | Data → Domain 转换：远/本地调用、`on AppException catch` | mocktail 的 `Mock` 打在 DataSource 上 | `references/repository_tests.md` |
| **ViewModel 测试** | 用户动作引起的状态迁移、Result 分支 | `ProviderContainer` + `overrideWithValue` 覆盖 UseCase | `references/viewmodel_tests.md` |
| **Widget 测试** | 页面渲染正确、点击派发正确动作 | `TranslationProvider` + `ProviderScope.overrides` | `references/widget_tests.md` |
| **架构测试** | 静态层级边界规则 | 文本扫描 `lib/`，不做 DI | `references/architecture_test.md` |

按你要测的东西选对应形态。Repository 测试不需要 widget，widget 测试也不该去摸 Riverpod 内部。

## 关键规则

1. **用 mocktail，不是 mockito。** mockito 不在依赖清单里。mocktail 使用 `when(() => ...)` 的 lambda 形式，对非原始参数用 `registerFallbackValue`。不要混用。

2. **创建 `ProviderContainer` 后务必 `addTearDown(container.dispose)`**。否则 Riverpod 会在测试之间漏状态。

3. **ViewModel 测试 override UseCase provider**，不是 Repository。ViewModel 读的是 UseCase；那才是"缝"。override 得更深会让测试脆弱。

4. **Widget 测试需要 `TranslationProvider`** 包住 `ProviderScope`，否则 `context.t.xxx` 抛异常。`setUp` 里还要 `LocaleSettings.setLocaleSync(AppLocale.en)`，断言才有确定性。

5. **mocktail 严格模式会调用的方法都要 stub。** 如果 Mock 抛 "MissingStubError"，就是忘了 `when(...)`。只 stub 测试真正用到的——过度 stub 会掩盖回归。

6. **测试文件镜像 `lib/` 结构。** `lib/features/auth/data/repositories/auth_repository_impl.dart` → `test/features/auth/data/repositories/auth_repository_impl_test.dart`。没有例外。

7. **宣布完成前先跑 `tool/test.sh`。** 它会跑 `flutter analyze`（very_good_analysis）+ `flutter test`（含架构测试）。单个测试通过不代表整套通过。

## 测试命名

- 文件：`<source_file_name>_test.dart`。
- 顶层 `group('ClassName')` 或 `group('methodName')`。
- `test('should <期望结果> when <前提>')` —— "should" 形式使断言易读。
- 内部变量：`input*`、`mock*`、`actual*`、`expected*`（Arrange-Act-Assert）。

## 快速示例

### Repository（happy path + 错误）

```dart
test('should return user on successful remote login', () async {
  when(() => remote.login(any())).thenAnswer((_) async => token);
  when(() => local.saveToken(token)).thenAnswer((_) async {});
  when(() => remote.me()).thenAnswer((_) async => userModel);
  when(() => local.saveUser(userModel)).thenAnswer((_) async {});

  final result = await repository.login(
    username: 'alice',
    password: 'secret',
  );

  expect(result.isSuccess, isTrue);
  expect(result.data, expectedUser);
});
```

### ViewModel（通过 ProviderContainer）

```dart
test('should set typed failure when login fails', () async {
  when(() => mockLoginUseCase(username: 'tester', password: 'wrong'))
      .thenAnswer((_) async => const Result.failure(
            Failure(code: FailureCode.auth, detail: 'invalid credentials'),
          ));

  final container = ProviderContainer(
    overrides: [loginUseCaseProvider.overrideWithValue(mockLoginUseCase)],
  );
  addTearDown(container.dispose);

  final notifier = container.read(loginViewModelProvider.notifier);
  notifier.updateUsername('tester');
  notifier.updatePassword('wrong');
  await notifier.login();

  final state = container.read(loginViewModelProvider);
  expect(state.error?.code, FailureCode.auth);
  expect(state.error?.detail, 'invalid credentials');
});
```

### Widget（通过 TranslationProvider + ProviderScope）

```dart
testWidgets('renders guest header when not authenticated', (tester) async {
  final storage = _stubStorage();
  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [kvStorageProvider.overrideWithValue(storage)],
        child: const MaterialApp(home: ProfilePage()),
      ),
    ),
  );

  expect(find.text('Guest'), findsOneWidget);
});
```

### 架构测试（自动运行）

无需写代码——`test/core/architecture_test.dart` 会扫描 `lib/`，违反规则则失败。合理的跨层调用可以用 `// arch-exempt: <reason>` 单独豁免。

## 遇到不同问题时查阅哪份 reference

- **`references/repository_tests.md`** —— mocktail 配置、stub DataSource 抛 `AppException`、测试 `on AppException catch` 分支、测试部分失败方法（logout 式）。
- **`references/viewmodel_tests.md`** —— `ProviderContainer` 模式、覆盖 UseCase provider、测试状态迁移、测试未触达 Repository 的校验路径。
- **`references/widget_tests.md`** —— `TranslationProvider` 配置、Profile 式测试中 override storage、`testWidgets` 与 `pumpAndSettle` 的区别、通过 predicate 查找自定义绘制控件。
- **`references/architecture_test.md`** —— 四条规则各自在查什么、如何解读失败、何时添加 `// arch-exempt`、何时在 test 文件里扩新规则。
- **`references/test_helpers.md`** —— 可复用的 fixture 和 helper（mock storage、container builder、locale 设置）、mocktail `registerFallbackValue` 清单。

## 运行测试

- `tool/test.sh` —— analyze + 全量测试（CI 跑的就是它）。发布前必须过。
- `flutter test test/features/<f>/` —— 单 feature。
- `flutter test test/features/auth/data/repositories/auth_repository_impl_test.dart -r expanded` —— 单文件详细输出。
- `flutter test --name 'should return user'` —— 按测试名子串（调试单个失败时方便）。

## 覆盖率

本项目不强制阈值，但建议目标：

- **Repository**：100% 分支（success + 每种 AppException → Failure 映射）。
- **ViewModel**：每个 public 动作，以及校验前置分支。
- **Page**：至少"renders" + 关键交互（点击 → 动作被派发）。
- **架构**：自动 —— 不违反规则即可。

## 避免清单

- `mockito` —— 不在依赖里。
- 手动 `new` 出 Notifier 实例（`MyViewModel()`）—— 始终走 `container.read(provider.notifier)`。
- 覆盖过深（真实目标是 UseCase 却 mock `dioProvider`）。在正确的"缝"上 mock。
- `testWidgets` 没包 `TranslationProvider` —— slang 调用会因为 `context.t` 类型错误而失败。
- 异步 widget 测试在每个动作后都不 `await tester.pump()` 或 `pumpAndSettle()`。
- 单元测试依赖真实网络 / 真实 Hive —— 都要 override。
- 漏掉 `addTearDown(container.dispose)` —— 泄漏会造成鬼畜的测试串扰。
