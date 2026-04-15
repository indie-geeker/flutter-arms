# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
