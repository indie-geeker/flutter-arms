# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- 重新接入 `screen_size_adapter 1.0.0`：启动阶段安装 config-first binding，默认设计尺寸为 `360 × 690`，桌面保持原生逻辑像素。
- 升级到 `super_overlay 0.3.0`：应用根节点改为显式持有并释放 `SuperOverlayIntegration`，全局反馈门面改用 command service 与 typed `OverlayHandle`。
- 删除所有已失效的历史 SuperOverlay fluent API 用法，并同步测试与架构文档。
- 默认导航收敛为 Home + Profile，移除产品语义不明确的全局 Search 占位页；Showcase 只在 dev 路由表暴露。
- Profile 自定义主题色弹窗迁移到 typed `AppDialog.showCustom<T>`；Showcase 请求在页面离开后也会通过 `finally` 清理全局 loading。

### Added
- 新增默认启用的 Feedback Center 完整纵向切片：FAQ 搜索、反馈提交、历史、详情、英中本地化与受保护路由。
- dev Mock API 新增 `/feedback/*` 确定性响应，同时保留 Retrofit/Dio、Repository、UseCase 与 ViewModel 的真实调用链。
- dev Mock API 使用实例级内存工单库和确定递增 ID，提交后的工单可立即从历史与详情接口读取。
- 反馈提交确认、loading、success/error toast 全部经 `AppDialog` → `super_overlay`，并覆盖页面离开后的 loading 清理。

## [0.1.0] - 2026-04-15

### Added
- 初始化 Flutter Arms 模板基础架构（Clean Architecture + MVVM）
- 引入 Riverpod 3.x、AutoRoute、Dio/Retrofit、Hive_ce、Talker、slang、flutter_localizations 等核心依赖
- 完成 `dev/prod` 双环境入口与启动流程
- 实现核心模块：`Result`、网络拦截器、主题管理、加密存储
- 恢复 Auth 分层边界，`auth_providers.dart` 作为 feature 级组合入口
- 实现 Auth 示例链路（Domain/Data/Presentation）
- 新增 Splash / Onboarding / Home（3 Tabs）页面骨架
- 将 Onboarding 升级为可滑动的 `PageView` 引导流程，支持 skip / start
- 接入运行时 i18n，App shell 通过 `TranslationProvider` 提供 locale
- 本地化登录、首页、启动页等关键页面文案
- 新增共享组件：按钮、输入框、加载/空态/错误态、骨架屏、统一提示
- 补充测试用例（core/auth/onboarding/i18n/shared）
