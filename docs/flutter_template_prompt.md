# Flutter 通用代码模板 — AI 生成提示词（Prompt）

---

## 角色设定

你是一位拥有 5 年以上 Flutter 开发经验的高级架构师，擅长 Clean Architecture 设计、Riverpod 状态管理以及大型项目工程化搭建。请根据以下详细需求，生成一个**完整、可直接运行**的 Flutter 通用代码模板项目。

---

## 一、项目基础信息

- **项目名称**：`flutter_template`（可自行替换）
- **目标平台**：全平台（Android、iOS、Web、macOS、Windows、Linux）
- **用途定位**：个人项目快速启动模板，架构精炼但不臃肿，开箱即用
- **Flutter SDK 版本**：最新稳定版（>=3.24）
- **Dart 版本**：>=3.5
- **代码注释语言**：中文

---

## 二、架构设计

### 2.1 架构模式：Clean Architecture（严格分层）

采用经典三层分层架构，按 Feature-first 组织模块：

```
lib/
├── app/                          # 应用入口与全局配置
│   ├── app.dart                  # MaterialApp 根组件
│   ├── app_env.dart              # 环境配置（dev/staging/prod）
│   └── app_router.dart           # AutoRoute 路由配置
│
├── core/                         # 跨模块共享的基础设施
│   ├── constants/                # 全局常量（API 地址、颜色、尺寸等）
│   ├── error/                    # 统一异常定义与错误处理
│   │   ├── exceptions.dart       # 自定义异常类
│   │   ├── failures.dart         # Failure 封装
│   │   └── error_handler.dart    # 全局错误拦截器
│   ├── extensions/               # Dart Extension Methods（String、DateTime、BuildContext 等）
│   ├── network/                  # Dio 封装、拦截器、Retrofit 配置
│   │   ├── dio_client.dart       # Dio 实例与拦截器链
│   │   ├── api_interceptor.dart  # Token 注入、日志、错误拦截
│   │   └── token_interceptor.dart# Token 自动刷新拦截器
│   ├── storage/                  # 本地存储封装
│   │   ├── kv_storage.dart       # 轻量级 KV 存储（SharedPreferences 封装）
│   │   └── db_storage.dart       # 本地数据库（Drift/Isar）
│   ├── theme/                    # 主题系统
│   │   ├── app_theme.dart        # Light/Dark 主题定义
│   │   ├── app_colors.dart       # 颜色常量
│   │   └── theme_provider.dart   # 主题切换（含自定义主题色）
│   ├── utils/                    # 工具类（日期处理、权限、平台判断等）
│   ├── logger/                   # 日志系统（基于 Talker 封装）
│   └── result/                   # Result<T> 类型封装（Success / Failure）
│
├── features/                     # 业务功能模块（Feature-first）
│   ├── auth/                     # 鉴权模块（示例 Feature）
│   │   ├── data/
│   │   │   ├── datasources/      # 远程 & 本地数据源
│   │   │   ├── models/           # 数据模型（freezed + json_serializable）
│   │   │   └── repositories/     # Repository 实现
│   │   ├── domain/
│   │   │   ├── entities/         # 领域实体
│   │   │   ├── repositories/     # Repository 抽象接口
│   │   │   └── usecases/        # 用例
│   │   └── presentation/
│   │       ├── pages/            # 页面（登录页骨架）
│   │       ├── providers/        # Riverpod Providers
│   │       └── widgets/          # 模块内组件
│   │
│   ├── onboarding/               # 引导页模块
│   │   └── presentation/
│   │       └── pages/
│   │
│   └── home/                     # 主页模块（含底部导航布局）
│       └── presentation/
│           ├── pages/
│           └── widgets/
│
├── shared/                       # 共享 UI 组件
│   ├── widgets/
│   │   ├── app_button.dart       # 通用按钮
│   │   ├── app_text_field.dart   # 通用输入框
│   │   ├── loading_widget.dart   # 加载组件（支持自定义内容替换）
│   │   ├── empty_state.dart      # 空状态页（支持自定义内容替换）
│   │   ├── error_widget.dart     # 错误状态页
│   │   └── skeleton_loader.dart  # 骨架屏加载
│   └── dialogs/
│       └── app_dialog.dart       # 统一弹窗 / Toast
│
├── gen/                          # flutter_gen 自动生成的资源引用
│
└── main_dev.dart                 # 开发环境入口
    main_staging.dart             # Staging 环境入口
    main_prod.dart                # 生产环境入口
```

### 2.2 分层规则（必须严格遵守）

1. **Data 层**：只依赖 Domain 层的 Repository 接口，负责网络请求（Retrofit）、本地缓存（Drift/SharedPreferences）、数据模型转换
2. **Domain 层**：纯 Dart，零外部依赖，定义 Entity、Repository 接口、UseCase
3. **Presentation 层**：依赖 Domain 层，通过 Riverpod Provider 管理状态，页面只关心 UI 渲染
4. **core/ 和 shared/** 可被任意 Feature 依赖，但 Feature 之间不可直接互相依赖

---

## 三、技术栈与依赖

### 3.1 核心框架

| 类别 | 选型 | 说明 |
|------|------|------|
| 状态管理 | **Riverpod（flutter_riverpod + riverpod_annotation）** | 同时承担依赖注入职责，不额外引入 get_it |
| 路由 | **AutoRoute（auto_route + auto_route_generator）** | 声明式路由，支持嵌套导航、路由守卫 |
| 网络请求 | **Dio + Retrofit（retrofit + retrofit_generator）** | Dio 负责拦截器链，Retrofit 负责 API 接口声明 |
| 序列化 | **freezed + json_serializable** | 不可变模型 + 自动 JSON 序列化 |
| 代码生成 | **build_runner** | 统一管理 freezed / json_serializable / retrofit / auto_route 的代码生成 |

### 3.2 存储

| 类别 | 选型 | 说明 |
|------|------|------|
| 轻量 KV | **SharedPreferences** | Token、用户偏好、主题设置等 |
| 本地数据库 | **Drift（drift + drift_dev）** 或 **Isar** | 结构化数据持久化（二选一，请给出推荐理由） |

### 3.3 UI 与资源

| 类别 | 选型 | 说明 |
|------|------|------|
| 设计风格 | **Material 3** | 全平台统一视觉，局部场景按需平台适配 |
| 主题 | **Dark / Light + 自定义主题色** | 通过 Riverpod 管理主题切换，支持动态修改主题色 |
| 屏幕适配 | **flutter_screenutil** | 统一设计稿尺寸适配 |
| 国际化 | **slang（slang + slang_build_runner）** | 类型安全的 i18n 方案，编译期检查缺失翻译 |
| 资源管理 | **flutter_gen（flutter_gen_runner）** | 自动生成图片、字体、颜色等资源引用，类型安全 |
| 图片加载 | **cached_network_image** | 网络图片缓存 |
| 图片压缩 | **flutter_image_compress** | 上传前图片压缩处理 |

### 3.4 工程化

| 类别 | 选型 | 说明 |
|------|------|------|
| Lint | **flutter_lints + custom_lint（严格规则）** | 自定义严格 lint 规则集 |
| 日志 | **Talker（talker + talker_flutter + talker_dio_logger）** | 统一日志系统，集成 Dio 请求日志 |
| 测试 | **flutter_test + mocktail** | 预置单元测试和 Widget 测试骨架与示例 |

---

## 四、核心功能实现要求

### 4.1 网络层封装

- Dio 单例通过 Riverpod Provider 管理
- 拦截器链：日志拦截器（Talker）→ Token 注入拦截器 → 错误拦截器 → 重试拦截器
- Token 自动刷新：当 401 时自动调用刷新接口，排队等待，刷新成功后自动重放失败请求
- 提供一个示例 Retrofit API 接口文件作为模板

### 4.2 鉴权模块（Auth Feature 骨架）

- 完整的 Clean Architecture 分层示例
- 包含：登录/登出/Token 刷新的 UseCase
- Token 存储在 SharedPreferences（加密存储优先考虑 flutter_secure_storage）
- 路由守卫（AuthGuard）：未登录重定向到登录页

### 4.3 错误处理（三层体系）

1. **网络层**：Dio 拦截器统一捕获 DioException，转为自定义 AppException
2. **业务层**：UseCase / Repository 返回 `Result<T>`（sealed class，包含 Success 和 Failure）
3. **UI 层**：全局错误拦截（ProviderObserver 或 Zone），统一 Toast / Dialog 展示

### 4.4 主题系统

- 定义 `AppTheme` 类，包含完整的 Material 3 ColorScheme（Light & Dark）
- 支持运行时动态切换主题色（seed color）
- 主题偏好持久化到本地存储
- 通过 Riverpod 管理主题状态

### 4.5 环境配置

- 三套环境：`dev` / `staging` / `prod`
- 每套环境独立配置：API Base URL、App Name、日志开关等
- 通过不同 `main_xxx.dart` 入口启动，配合 `--dart-define` 或 Flavor 实现
- 提供环境配置的抽象类和各环境的实现

### 4.6 页面骨架

- **Splash 页**：启动页，检查登录状态后自动跳转
- **引导页（Onboarding）**：首次安装展示，支持多页滑动 + 跳过
- **登录页**：基础表单骨架（账号 + 密码 + 登录按钮）
- **主页**：底部导航栏布局（BottomNavigationBar），至少 3 个 Tab 页面占位

### 4.7 通用组件

所有通用组件需支持**内容可替换**（通过参数传入自定义 Widget）：

- `LoadingWidget`：加载状态组件，默认转圈，可自定义加载内容
- `EmptyStateWidget`：空状态页，可自定义图标、文案、操作按钮
- `ErrorStateWidget`：错误状态页，带重试按钮
- `SkeletonLoader`：骨架屏加载效果
- `AppButton`：通用按钮（支持 loading 状态、禁用状态）
- `AppTextField`：通用输入框（支持校验、密码切换显示）

---

## 五、测试要求

### 5.1 目录结构

```
test/
├── core/
│   ├── network/
│   │   └── dio_client_test.dart       # Dio 封装单元测试示例
│   └── result/
│       └── result_test.dart           # Result 类型单元测试
├── features/
│   └── auth/
│       ├── data/
│       │   └── repositories/
│       │       └── auth_repository_impl_test.dart  # Repository 测试示例
│       ├── domain/
│       │   └── usecases/
│       │       └── login_usecase_test.dart          # UseCase 测试示例
│       └── presentation/
│           └── pages/
│               └── login_page_test.dart             # Widget 测试示例
└── shared/
    └── widgets/
        └── app_button_test.dart                     # 通用组件测试示例
```

### 5.2 测试规范

- 使用 **mocktail** 作为 Mock 框架
- 每个测试文件提供至少 2-3 个测试用例作为示例
- 测试命名规范：`should [expected behavior] when [condition]`

---

## 六、文档要求

### 6.1 README.md

包含以下内容：
- 项目简介与架构概述
- 技术栈清单（表格形式）
- 快速开始（环境要求、安装步骤、运行命令）
- 目录结构说明
- 开发规范（分层规则、命名约定、代码生成命令）
- 新增 Feature 模块的步骤指南

### 6.2 CHANGELOG.md

初始版本记录，格式遵循 Keep a Changelog 规范。

### 6.3 架构图

在 README 中使用 Mermaid 语法绘制：
- 整体分层架构图（Data → Domain → Presentation）
- 数据流向图（UI → Provider → UseCase → Repository → DataSource）

---

## 七、代码风格与约定

1. **命名规范**：严格遵循 Dart 官方命名规范（lowerCamelCase 变量/方法、UpperCamelCase 类名、snake_case 文件名）
2. **文件组织**：每个文件只包含一个公开类
3. **注释**：所有公开类和方法必须有中文文档注释（`///` 格式）
4. **Import 排序**：dart → package → 相对路径，各组之间空行分隔
5. **const 优先**：Widget 构造函数尽可能使用 const
6. **代码生成命令**：在 README 中说明 `dart run build_runner build --delete-conflicting-outputs` 的使用时机

---

## 八、输出要求

1. **输出完整、可运行的项目代码**，包括所有文件内容
2. 确保 `pubspec.yaml` 中的依赖版本使用最新稳定版（截至你的知识范围）
3. 所有代码生成文件（`.g.dart`、`.freezed.dart`、`.gr.dart`）标注 `// 需要运行 build_runner 生成` 注释，不输出其内容
4. 如果单次回复无法输出全部代码，请按模块分批输出，并在每批结尾说明下一批将输出什么
5. 对于本地数据库选型（Drift vs Isar），请在代码中做出选择并在 README 中说明理由
