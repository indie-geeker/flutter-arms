# 状态管理：Riverpod 3 + ViewModel 模式

## 命名约定

| 种类 | 命名 | 生命周期 | 注解 | 位置 |
|---|---|---|---|---|
| 页面级 Notifier | `<Feature>ViewModel` | 绑路由，自动销毁 | `@riverpod` | `presentation/view_models/<f>_view_model.dart` |
| 全局 Notifier | `<Feature>Notifier` | 跨页面存活 | `@Riverpod(keepAlive: true)` | `presentation/view_models/<f>_notifier.dart` 或 `core/<area>/<f>_notifier.dart` |
| 仅 DI provider | `<f>Provider`（函数式） | 单例 | `@Riverpod(keepAlive: true)` | 与实现同一文件 |

页面级 ViewModel 是默认。只有当状态确实需要跨页面存活（auth、theme、locale，或全应用级）时才用全局 Notifier。

## Class Notifier 模板（页面级 ViewModel）

```dart
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/core/error/failure_code.dart';
import 'package:flutter_arms/core/result/result.dart';
import 'package:flutter_arms/features/%feature%/data/repositories/%feature%_repository_impl.dart';
import 'package:flutter_arms/features/%feature%/presentation/states/%feature%_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '%feature%_view_model.g.dart';

/// %Feature% 页面 ViewModel。
@riverpod
class %Feature%ViewModel extends _$%Feature%ViewModel {
  @override
  %Feature%State build() => const %Feature%State();

  /// 执行业务动作。
  Future<void> doSomething() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await ref.read(doSomethingUseCaseProvider)(/* params */);

    switch (result) {
      case Success(:final data):
        state = state.copyWith(isLoading: false, data: data);
      case FailureResult(:final failure):
        state = state.copyWith(isLoading: false, error: failure);
    }
  }
}
```

要点：

- `build()` 必须**纯净** —— 不做异步、不做副作用。只返回初始 state。
- 所有异步工作都在被 UI（`onPressed` 等）调用的方法里。
- 每次尝试新动作时都把 `error: null` 清掉，避免旧错误重复触发。
- 用模式匹配（对 sealed `Result<T>` 做 `switch`），不用 `if (result.isSuccess)`。
- 客户端校验：设 `error: Failure(code: FailureCode.validation)` 并提前返回。

## 函数式 provider 模板（DI）

repository、datasource、mapper、use case 优先用这种形态：

```dart
@Riverpod(keepAlive: true)
%Feature%Repository %feature%Repository(Ref ref) {
  return %Feature%RepositoryImpl(
    ref.read(%feature%RemoteDataSourceProvider),
    ref.read(%feature%LocalDataSourceProvider),
    ref.read(appLoggerProvider),
  );
}
```

和具体类放在一起（比如把 `%feature%Repository` provider 放进 `%feature%_repository_impl.dart`）。这让组合根保持小——参考 `auth_repository_impl.dart` 里一个文件声明 repository + 3 个 UseCase 的做法。

## 用 Freezed 写 State 类

```dart
import 'package:flutter_arms/core/error/failure.dart';
import 'package:flutter_arms/features/%feature%/domain/entities/%feature%.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '%feature%_state.freezed.dart';

/// %Feature% 页面状态。
@freezed
abstract class %Feature%State with _$%Feature%State {
  const factory %Feature%State({
    @Default(false) bool isLoading,
    @Default(<%Feature%>[]) List<%Feature%> items,
    Failure? error,
  }) = _%Feature%State;
}
```

规则：

- error 字段始终是 `Failure? error`，绝不是 `String?` —— UI 通过 `context.failureMessage(failure)` 本地化。
- 布尔字段带助动词：`isLoading`、`hasMore`、`canSubmit`、`isSubmitSuccess`。
- 用 `@Default(...)` 指定默认值，让 `const %Feature%State()` 可用。
- State 里不要放 `List<DTO>` 或 `DioException` —— 只放 domain 实体和 `Failure`。

## ConsumerWidget 模式

```dart
class %Feature%View extends ConsumerWidget {
  const %Feature%View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 副作用（对话框、导航）：ref.listen
    ref.listen(%feature%ViewModelProvider, (previous, next) {
      final failure = next.error;
      if (failure != null && failure != previous?.error) {
        AppDialog.showError(context, context.failureMessage(failure));
      }
      if (next.isSubmitSuccess && previous?.isSubmitSuccess != true) {
        context.router.replace(const NextRoute());
      }
    });

    // 触发 rebuild：ref.watch
    final state = ref.watch(%feature%ViewModelProvider);
    final notifier = ref.read(%feature%ViewModelProvider.notifier);

    // ... 用 state 渲染，把动作接到 notifier.xxx
  }
}
```

规则：

- 副作用（对话框/导航/snackbar）用 `ref.listen`。永远不要在 listener 里触发 rebuild。
- 驱动渲染的值用 `ref.watch`。
- 每次 build 里 `ref.read(provider.notifier)` 只读一次，缓存 handle，不要在循环里反复读。
- 副作用触发用 `previous != next` / `previous?.flag != true` 做守卫，避免相同 rebuild 二次触发对话框。

## 监听派生状态

widget 只关心 state 的一部分时，用 `select` 最小化 rebuild：

```dart
final isLoading = ref.watch(
  %feature%ViewModelProvider.select((s) => s.isLoading),
);
```

## 避免清单

- `StateProvider`、`StateNotifierProvider`、`ChangeNotifierProvider` —— 老 API。改用 `@riverpod class`。
- `.family` provider —— 本项目不用 family；参数传给方法即可。
- 手动 `new` Notifier 实例（`MyNotifier()`）—— 始终走 Riverpod。
- `build()` 里放业务逻辑 —— 它只能综合 state，不该做别的。
- 在一个 provider 的 `build()` 里读另一个 provider 只是为了"串联" —— 响应式就用 `ref.watch`，`ref.read` 只在事件处理器里用。

## 覆盖 provider（测试 / bootstrap）

基本形态：`provider.overrideWithValue(x)` 或 `provider.overrideWith((ref) => ...)`。生产中基础设施 provider（`appEnvProvider`、`appLoggerProvider`）在 `bootstrap.dart` 的 `ProviderScope(overrides: [...])` 里覆盖。测试里覆盖 UseCase provider 以注入 mock —— 见 `flutter-arms-testing` skill。
