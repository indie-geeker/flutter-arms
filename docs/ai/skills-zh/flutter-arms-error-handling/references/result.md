# Result<T> sealed 类型

位置：`lib/core/result/result.dart`。

## 结构

```dart
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess;
  bool get isFailure;

  T? get data;          // failure 时为 null
  Failure? get failure; // success 时为 null
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  @override final T data;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  @override final Failure failure;
}
```

## 模式匹配（优先用 `switch`）

标准写法——对 sealed 层级做 Dart 3 模式匹配：

```dart
switch (result) {
  case Success(:final data):
    state = state.copyWith(isLoading: false, value: data);
  case FailureResult(:final failure):
    state = state.copyWith(isLoading: false, error: failure);
}
```

分析器知道 `Result` 是 sealed，若漏写分支会报错。不要用 `if (result.isSuccess)` + cast——这会破坏穷尽性检查。

## 扩展方法（`ResultX`）

```dart
extension ResultX<T> on Result<T> { ... }
```

可用方法：

### `when<R>({required success, required failure})`

折叠成单一值：

```dart
final message = result.when(
  success: (post) => 'Loaded: ${post.title}',
  failure: (f) => context.failureMessage(f),
);
```

适合渲染期的值计算。在 Notifier 里做 state 更新时优先用 `switch`——更清晰，并且编译器会强制穷尽。

### `map<R>(R Function(T) transform)`

变换 success 分支，failure 原样透传：

```dart
final Result<List<String>> titles = postsResult.map(
  (posts) => posts.map((p) => p.title).toList(),
);
```

### `mapFailure(Failure Function(Failure) transform)`

变换 failure 分支，success 原样透传。UseCase 想给错误附加上下文时很有用：

```dart
return repoResult.mapFailure(
  (f) => Failure(code: f.code, detail: 'During post creation: ${f.detail}'),
);
```

### `getOrElse(T fallback)`

"成功就用 data，否则返回默认值"的简写：

```dart
final items = result.getOrElse(const <Post>[]);
```

### `getOrNull()`

同上，但返回 `T?`。用于写默认值：

```dart
final post = result.getOrNull() ?? Post.empty();
```

## 链式调用

`Result` **不是**带完整 `flatMap` 的 functor/monad——不要试图用 `.flatMap(...)` 串联多个 Repository 调用。标准写法是：

```dart
final a = await repo.stepOne();
if (a case FailureResult(:final failure)) {
  return Result.failure(failure);
}
final b = await repo.stepTwo((a as Success).data);
// ...
```

或用 helper 写得更干净：

```dart
Future<Result<C>> compose() async {
  final a = await repo.stepOne();
  switch (a) {
    case FailureResult(:final failure):
      return Result.failure(failure);
    case Success(:final data):
      return repo.stepTwo(data);
  }
}
```

这类组合逻辑放在 UseCase 层，不要放进 ViewModel。

## 禁用清单

- `Dartz` 的 `Either<L, R>` —— 不在依赖列表里，不要加。
- 其它包的 `Result<T>`（`result_type`、`fpdart` 等）—— 本项目使用自定义的 sealed 类。
- 在声明返回 `Result` 的函数里 throw —— 必须用 `try/catch` 包起来并返回 `Result.failure`。
- `result.isSuccess ? (result as Success<T>).data : null` —— 用 `getOrNull()` 或模式匹配。
- 静默吞错：`result.getOrElse(null)` 而没有日志 —— 如果你要吞错，至少 `_logger.warning(...)` 一下。
- 对可能在业务上失败的方法声明为 `Future<T>` —— 用 `Future<Result<T>>`。
