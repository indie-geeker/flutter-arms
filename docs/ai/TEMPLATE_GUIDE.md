# Flutter Arms 模板派生指南

> 目的：从本模板衍生一个新 Flutter 项目的最短路径。
> 最后更新：2026-04-17

## 1. 一次性改名（派生时）

### 1.1 替换包名

假设新项目叫 `my_app`：

1. `pubspec.yaml`：`name: flutter_arms` → `name: my_app`，`description` 同步更新。
2. 全局替换 `package:flutter_arms/` → `package:my_app/`（IDE 或 `grep -rl`）。
3. Android：`android/app/build.gradle.kts` 的 `applicationId` 和 `android/app/src/main/AndroidManifest.xml` 的 label / kotlin 包路径。
4. iOS：Xcode 里改 `PRODUCT_BUNDLE_IDENTIFIER`、`Display Name`。
5. `flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs && dart run slang`。

### 1.2 替换品牌资源

- `assets/icon/app_icon.png` → 你的图标（1024×1024 PNG）。
- `assets/splash/logo.png` → 启动屏 Logo（透明背景 PNG）。
- 生成：
  ```bash
  dart run flutter_launcher_icons
  dart run flutter_native_splash:create
  ```

### 1.3 配置环境

```bash
cp env/dev.example.json env/dev.json
cp env/prod.example.json env/prod.json
# 编辑 env/*.json 填真实 API_BASE_URL / APP_NAME / ENABLE_LOG
```

`env/*.json` 已在 `.gitignore`，不会误提交。

### 1.4 安全短板处理（见 SECURITY.md §2.1）

上线前必须评估 Hive cipher key 存储方案（`flutter_secure_storage` 或鸿蒙兼容方案）。

## 2. 日常命令

```bash
# 运行
tool/run_dev.sh                           # dev flavor，带 --dart-define-from-file
tool/run_prod.sh                          # prod flavor，release 构建

# 代码生成
tool/gen.sh                               # build_runner + slang

# 清理 + 重新生成
tool/clean.sh && tool/gen.sh

# 本地 CI
tool/test.sh                              # analyze + test
tool/format.sh                            # dart format + --set-exit-if-changed
```

## 3. 新增 Feature 的 Checklist

新增一个 `xxx` feature，例如 `settings`：

### 3.1 目录结构

```
lib/features/xxx/
├── data/
│   ├── datasources/
│   │   └── xxx_remote_datasource.dart    # @RestApi(Retrofit)
│   ├── models/
│   │   └── xxx_dto.dart                  # Freezed + json_serializable
│   └── repositories/
│       └── xxx_repository_impl.dart      # try/catch AppException → Failure
├── domain/
│   ├── entities/
│   │   └── xxx.dart
│   ├── repositories/
│   │   └── xxx_repository.dart
│   └── usecases/
│       └── get_xxx_usecase.dart
└── presentation/
    ├── pages/
    │   └── xxx_page.dart                  # @RoutePage()
    ├── view_models/
    │   └── xxx_notifier.dart              # @Riverpod
    ├── states/
    │   └── xxx_state.dart                 # Freezed
    └── widgets/
```

### 3.2 Data 层要点
- Retrofit 接口加 `@RestApi(baseUrl: '')`，baseUrl 走 `dioProvider`。
- Repository 包裹 `Future<T>.asApi()`（见 `core/network/dio_ext.dart`）：
  ```dart
  try {
    final dto = await _remote.get().asApi();
    return Result.success(dto.toEntity());
  } on AppException catch (e) {
    return Result.failure(Failure.fromException(e));
  }
  ```
- DTO → Entity 的 mapper 写在 DTO 文件的扩展里（不要反向污染）。

### 3.3 Domain 层要点
- **不能 import** `dio` / `hive` / `retrofit` / `app_exception*.dart`（架构测试强制）。
- Repository 接口返回 `Future<Result<T>>` 或 `Stream<T>`。
- UseCase 仅做编排 + 业务规则。

### 3.4 Presentation 层要点
- 页面加 `@RoutePage()`，运行 `dart run build_runner build --delete-conflicting-outputs` 后路由自动生成。
- 在 `lib/app/app_router.dart` 的 `routes` 列表里添加新路由（如需守卫，加 `guards: [authGuard]`）。
- ViewModel 使用 `@riverpod` 注解。
- State 使用 `@freezed`。
- 错误展示：`context.failureMessage(failure)` 直接拿到本地化文案；badResponse/validation 会优先使用 `detail`。

### 3.5 i18n
- 在 `lib/i18n/en.i18n.json` 与 `zh.i18n.json` 对称添加文案。
- 跑 `dart run slang` 生成 `strings.g.dart`。
- UI 层通过 `context.t.<path>` 访问。

### 3.6 测试
每个新 feature 至少补齐：
- Repository 单测（mocktail mock DataSource，覆盖成功 / 404 / 401 / 超时）。
- ViewModel 单测（`ProviderContainer` + override）。
- Page widget 测（`TranslationProvider` + `ProviderScope.overrides`）。

参考：
- `test/features/auth/data/repositories/auth_repository_impl_test.dart`
- `test/features/auth/presentation/view_models/login_view_model_test.dart`
- `test/features/home/presentation/pages/profile_page_test.dart`

### 3.7 架构测试
无需手动维护。每次 `flutter test` 会自动跑 `test/core/architecture_test.dart`：
- 若新 feature 跨 feature 引用，会立即红线。如确实无法解耦，在 import 行上一行加 `// arch-exempt: <理由>`。
- 若 domain 误 import 了 dio/hive/retrofit，会立即红线。

## 4. 常用扩展点

- **接入第三方 API**：在 `features/<f>/data/datasources/` 新建 Retrofit 接口，复用 `dioProvider`。
- **离线缓存**：Hive box（`core/storage/kv_storage.dart` 已示范；新增时请遵循同一 cipher 策略）。
- **推送/埋点**：不进入模板内核。在 `app/bootstrap.dart` 里初始化，并通过 Provider 暴露。
- **自定义主题**：`core/theme/theme_notifier.dart` + `app_colors.dart`，seedColor 已持久化到 storage。

## 5. 发布前 Checklist

- [ ] `docs/ai/SECURITY.md` §3 Checklist 逐项过一遍。
- [ ] `env/prod.json` 通过 CI Secret 注入，不进 git。
- [ ] `flutter analyze` 零告警。
- [ ] `flutter test` 全绿，包含 `test/core/architecture_test.dart`。
- [ ] `flutter build appbundle --flavor prod --dart-define-from-file=env/prod.json --obfuscate --split-debug-info=build/symbols`。
- [ ] 自测：无网 / 断网 / 弱网 / 401 刷新成功 / 401 刷新失败 / 连续 401。
- [ ] Profile → 长按头像（dev flavor）可打开 `TalkerScreen`（release 构建里入口被 flavor 判断关闭）。
