# Flutter Arms 安全说明

> 最后更新：2026-04-17

本文档梳理 Flutter Arms 模板的威胁模型与已知安全短板，派生真实产品前请按 checklist 逐项消化。

## 1. 威胁模型

| 威胁 | 影响面 | 当前状态 |
|------|--------|----------|
| T1 | 本地设备被篡改 / 越狱 / Root | 高 |
| T2 | Token 被盗 | 高 |
| T3 | 抓包 / 证书劫持 | 中 |
| T4 | 日志泄漏敏感字段 | 中 |
| T5 | 构建产物携带密钥 / 调试入口 | 高 |
| T6 | Git 仓库泄露敏感环境变量 | 高 |

## 2. 已知风险与对策

### 2.1 🚨 Hive cipher key 明文落盘（S1，**模板已知短板**）

**现状**：`HiveKvStorage` 启用了 AES cipher，但 cipher key 生成后以**明文形式**存储在 `SharedPreferences` / `NSUserDefaults`。

**等价于**：
- iOS → `NSUserDefaults`（plist 可读）。
- Android → `SharedPreferences`（`/data/data/<pkg>/shared_prefs/*.xml`，root 可读）。

**为什么未修复**：
- iOS/Android 推荐走 Keychain / Keystore（`flutter_secure_storage`）。
- 鸿蒙（HarmonyOS）对 `flutter_secure_storage` 尚无稳定方案，贸然引入会丢失平台覆盖。
- 故本模板**搁置**，等待上线前 / 接鸿蒙时统一决策（决策编号 D1）。

**派生新项目前必做**：
1. 若不需要鸿蒙 → 接入 `flutter_secure_storage`，将 cipher key 存到 Keychain/Keystore。
2. 若需要鸿蒙 → 参考 `@ohos/security` 或原生 HUKS，自行封装一层 `SecureKeyStorage` 抽象。
3. 修改 `lib/core/storage/hive_kv_storage.dart` 的 key 获取路径。

### 2.2 Token 存储

**现状**：Access/Refresh Token 存在 Hive（AES 加密），受 2.1 cipher key 泄露风险影响。

**加固建议**：
- 迁移到 `flutter_secure_storage`（同 2.1）。
- 生产构建启用代码混淆：`--obfuscate --split-debug-info=build/symbols`。
- 仅在必要时把 Token 带入日志（Talker 已默认过滤，但接入三方埋点时要复核）。

### 2.3 Token 刷新链

**现状**：
- 主 Dio（`dioProvider`）带 `TokenInterceptor`，拦截 401 自动刷新。
- 刷新专用 Dio（`authRefreshDioProvider`）**不带** `TokenInterceptor`，避免刷新请求自身 401 导致递归。
- 刷新失败 → `TokenInterceptor` 清除 Token、`AuthNotifier.logout()`，`AuthGuard` 自动跳 `LoginRoute`。

**风险点**：并发 401 时靠 `TokenInterceptor` 内部队列保证只刷一次；注意不要在业务层另行捕获 401 后重试。

### 2.4 HTTPS & 证书钉扎

**现状**：Dio 使用系统信任链（默认）。

**深入阅读**：[docs/ai/HTTPS_GUIDE.md](./HTTPS_GUIDE.md) —— 系统信任链 / 自签名 / Pinning 三种方式的原理、优缺点、使用场景、前后端交互流程、Flutter 代码示例、轮换策略、常见坑。

**最小加固建议**（如涉及金融/医疗/IM）：
- 生产 BaseUrl 必须 HTTPS，`env/prod.json` 里不要放 http 端点。
- 按 HTTPS_GUIDE §3 接入 SPKI Pinning；pin 走 `--dart-define`，至少维护 2 把 key 支持轮换。
- 在 CI 中 grep 生产代码不得包含 `badCertificateCallback = (...) => true` 这类全放行语句。

### 2.5 日志

**现状**：`AppLogger`（Talker）在 `env.enableLog=true` 时启用，dev 默认开、prod 默认关（可经 `ENABLE_LOG` 打开用于线上问题排查）。

**加固建议**：
- Profile 页长按头像打开 `TalkerScreen`（仅 `dev` flavor 启用），生产构建入口已被 flavor 判断关闭，无暴露风险。
- 接入 Sentry/Bugsnag 时，请过滤掉 Authorization / Cookie / 用户手机号等字段。

### 2.6 `env/*.json` 泄露

**现状**：`.gitignore` 已排除 `env/*.json`，仅保留 `*.example.json`。

**加固建议**：
- CI 中通过 Secret 生成 `env/prod.json` 再进行 `flutter build`。
- 不要把真实 API Key / SecretKey 打包进 repo。
- 真实密钥尽量放服务端，由服务端接口下发短时凭证。

### 2.7 构建加固

**加固建议**（上线前必做）：
- Android
  ```
  flutter build appbundle --flavor prod \
    --dart-define-from-file=env/prod.json \
    --obfuscate --split-debug-info=build/symbols
  ```
  + `android/app/proguard-rules.pro` 检查是否误 keep 了敏感类。
- iOS：Archive → App Store Connect，Release 配置 Bitcode/Swift Symbol 默认处理。
- 禁用 `WebView.setWebContentsDebuggingEnabled(true)`（如引入）。

### 2.8 反调试 / Jailbreak / Root 检测

**现状**：未内置。
**建议**（金融/IM 类）：`flutter_jailbreak_detection` + 服务端配合降级策略。

## 3. 发布前安全 Checklist

- [ ] `env/prod.json` 不在 git 历史里。
- [ ] `dio.options.baseUrl` 为 HTTPS。
- [ ] 生产构建启用 `--obfuscate --split-debug-info`。
- [ ] 已按 2.1 接入 secure storage（或显式决定保留模板方案并记录风险）。
- [ ] 日志不打印 Token/密码/身份证号等敏感字段。
- [ ] 第三方埋点 / 崩溃上报（Firebase/Sentry/Bugly）接入时过滤敏感字段。
- [ ] iOS `Info.plist` / Android `AndroidManifest.xml` 的权限列表为实际所需。
- [ ] Proguard 规则不 keep 敏感类（例如含密钥常量的类）。
- [ ] 如涉及支付/金融：证书钉扎、Jailbreak/Root 检测、反重打包。
