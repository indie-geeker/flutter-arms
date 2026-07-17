---
name: flutter-arms-error-handling
description: Apply the flutter_arms error-handling contract — Result<T> (sealed class) + AppException (sealed, Data layer) + Failure/FailureCode (Domain/Presentation), with DataSource adapters as the transport conversion boundary and `context.failureMessage(failure)` as the UI sink. Use this skill whenever the task touches error handling in a flutter_arms project — including catching DioException, mapping HTTP errors, adding a new FailureCode, adding a new AppException subclass, wiring try/catch in a Repository, deciding whether to throw or return Result, displaying an error in the UI, writing retry logic, handling 401/refresh, or debugging "why is my error message not localized". Also use when the user says: "how do I handle errors here", "why is this throwing DioException", "add a new error type", "the error message shows a stack trace", "refresh token failed", "请求失败时弹什么", "这个 retrofit 报错没被 catch 住". Do NOT use Dartz Either, do NOT let DioException leak above DataSource adapters, do NOT use try/catch in UI. This skill is mandatory reading for any error-related change because flutter_arms has a specific two-layer error model that generic Flutter advice gets wrong.
---

# flutter-arms-error-handling

flutter_arms 采用**双层错误模型**，并在层间设定严格的转换边界。写错会导致 `DioException` 外泄或 i18n 失效；写对则意味着 UI 永远不接触原始异常，并始终显示本地化文案。

## 三种类型

| 类型 | 所在层 | 用途 |
|---|---|---|
| **`AppException`**（sealed） | 仅 Data 层 | DataSource / Repository 内部抛出的规范化异常。共 7 个子类：`NetworkException`、`TimeoutException`、`BadResponseException`、`AuthException`、`ValidationException`、`CancelledException`、`UnknownException`。domain/presentation 绝不 import。 |
| **`Failure`**（值对象） | Domain + Presentation | UI 能见到的形态。字段：`code: FailureCode`、可选 `detail: String?`、可选 `cause` / `stackTrace`。Domain 通过 `Result.failure(...)` 返回它。 |
| **`Result<T>`**（sealed） | Domain + Presentation | 要么 `Success<T>`，要么 `FailureResult<T>`。凡可能失败的 Repository 方法都返回 `Future<Result<T>>`。 |

## 端到端流程

```
┌────────────┐   DioException  ┌─────────────────┐  AppException  ┌──────────────┐  Result<T>  ┌────────────┐
│  Retrofit  │────────────────▶│  DataSource     │───────────────▶│  Repository  │────────────▶│  ViewModel │
│ /ApiClient │                 │ adapter boundary│                │  (on         │             │  (switch   │
│   (Dio)    │                 │ .asApi()/send() │                │  AppException│             │   Result)  │
│            │                 │ → AppException  │                │  catch →     │             │            │
│            │                 │                 │                │  Failure)    │             │            │
└────────────┘                 └─────────────────┘                └──────────────┘             └────────────┘
                                                                                                    │
                                                                                                    ▼
                                                                                            ┌──────────────┐
                                                                                            │   UI: show   │
                                                                                            │  failure via │
                                                                                            │context.failure│
                                                                                            │  Message(f)  │
                                                                                            └──────────────┘
```

## 关键规则（CRITICAL）

1. **DataSource adapter 是传输异常转换边界。** Retrofit adapter 在 `_api.xxx().asApi()` 处拆 `DioException`；ApiClient adapter 通过 `DioApiClient.send(...)` 得到已规范化的 `AppException`。Repository 不 import `dio_ext.dart`，也不调用 `.asApi()`。

2. **Repository 返回 `Future<Result<T>>`，永远不向上抛。** 始终使用 `try { ... } on AppException catch (e) { return Result.failure(Failure.fromException(e)); }`。

3. **Domain 和 Presentation 永远不 import `AppException`。** 否则架构测试会失败。它们只认 `Failure` + `FailureCode`。

4. **UI 通过 `context.failureMessage(failure)` 渲染错误。** 禁止 `failure.toString()`、禁止硬编码字符串、禁止裸用 `failure.detail`。

5. **每个 `FailureCode` 都必须在 `en.i18n.json` 和 `zh.i18n.json` 中有对应的 `errors.<code>` i18n key。** 缺了 slang 代码生成会失败。

## 遇到不同问题时查阅哪份 reference

- **`references/result.md`** —— `Result<T>` sealed 类型、`switch` 模式匹配、`ResultX` 扩展方法（`when`、`map`、`mapFailure`、`getOrElse`、`getOrNull`）、禁用清单。
- **`references/exceptions.md`** —— `AppException` sealed 层级、`AppExceptionMapper`（DioException → 子类映射）、`.asApi()` / `DioApiClient.send` 如何在 DataSource 边界规范化异常。
- **`references/failure.md`** —— `Failure` 结构、`FailureCode` 枚举、`Failure.fromException`、`context.failureMessage`、badResponse/validation 的 detail 优先级规则。
- **`references/repository_flow.md`** —— Repository 的标准 try/catch 模式、新增方法的写法、部分失败场景（如 logout：远端失败但本地成功）的处理。
- **`references/ui_display.md`** —— `AppDialog.showError`、`ErrorStateWidget`、`SelectableText.rich`，各自的适用场景，以及触发全局错误提示的 `ref.listen` 模式。

## 快速决策树

**"我在 DataSource adapter 以外的地方 catch 了 DioException"** → 不对。DataSource adapter 把它转成 `AppException`；Repository 只 `on AppException catch`。

**"我的错误消息显示 'Instance of DioException'"** → Retrofit adapter 可能漏了 `.asApi()`，或 ApiClient 实现没有把 Dio 异常转成 `AppException`，导致 Repository 收到未规范化异常。

**"现有 `FailureCode` 枚举覆盖不到我要的错误类别"** → 新增一个 `FailureCode`、一个对应的 `AppException` 子类；如果是 Dio 侧的，更新 `AppExceptionMapper`；`Failure.fromException` 会自动透传 `code`；更新 `context.failureMessage` 的 switch；在两份 i18n 文件都加上 `errors.<newCode>`。

**"我想对特定失败进行重试"** → 在 ViewModel 里检查 `failure.code` 然后重新调动作。不要在 Repository 里自动重试（用户应该看到错误后自己选择）。401 是例外——`TokenInterceptor` 会透明完成 refresh-and-retry。

**"UI 要展示服务端返回的准确文案"** → 对 `badResponse` 和 `validation`，`context.failureMessage` 已经会在有值时优先返回 `failure.detail`。确保你的 API 层真的把 `detail` 填上了——`AppExceptionMapper._extractMsg` 会从 JSON body 中读 `message` / `msg` / `error`。如果后端用了别的 key，去改 `_extractMsg`。

**"我想让 ViewModel 抛异常而不是返回 Result"** → 不行。ViewModel 用 `error: failure` 更新 state，UI 通过 `ref.listen` 读取。

## 示例：新增一个端点并做好错误处理

```dart
// data/datasources/post_remote_datasource.dart
abstract interface class PostRemoteDataSource {
  Future<PostDto> detail(String id);
}

// data/datasources/retrofit_post_remote_datasource.dart
@GET('/posts/{id}')
Future<PostDto> detail(@Path('id') String id);

@override
Future<PostDto> detail(String id) {
  return _api.detail(id).asApi();
}

// data/repositories/post_repository_impl.dart
@override
Future<Result<Post>> detail(String id) async {
  try {
    final dto = await _remote.detail(id);
    return Result.success(dto.toEntity());
  } on AppException catch (e) {
    return Result.failure(Failure.fromException(e));
  }
}

// presentation/view_models/post_view_model.dart
Future<void> openDetail(String id) async {
  state = state.copyWith(isLoading: true, error: null);
  final result = await ref.read(getPostDetailUseCaseProvider)(id);
  switch (result) {
    case Success(:final data):
      state = state.copyWith(isLoading: false, detail: data);
    case FailureResult(:final failure):
      state = state.copyWith(isLoading: false, error: failure);
  }
}

// presentation/pages/post_page.dart
ref.listen(postViewModelProvider, (prev, next) {
  final failure = next.error;
  if (failure != null && failure != prev?.error) {
    AppDialog.showError(context.failureMessage(failure));
  }
});
```

完整往返链路就是这样。UI 层没有任何 `try/catch`、Repository 之上没有任何裸 `DioException`，错误文案由 `FailureCode` + 可选的服务端 detail 派生出来。
