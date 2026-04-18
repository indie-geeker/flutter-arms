import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_env.g.dart';

/// 应用环境类型。
enum AppFlavor {
  /// 开发环境。
  dev,

  /// 生产环境。
  prod,
}

/// 应用环境配置。
///
/// 字段优先使用 `--dart-define` / `--dart-define-from-file` 注入的值，
/// 未注入时回落到 flavor 默认值。推荐使用 `env/*.json` 配合
/// `--dart-define-from-file=env/dev.json` 管理多环境。
@immutable
class AppEnv {
  /// 构造函数。
  const AppEnv({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
    required this.enableLog,
    required this.useMockApi,
  });

  /// 根据 flavor 构造默认配置（带 `String.fromEnvironment` 回退）。
  factory AppEnv.fromFlavor(AppFlavor flavor) {
    const envAppName = String.fromEnvironment('APP_NAME');
    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    const envEnableLog = bool.fromEnvironment(
      'ENABLE_LOG',
      defaultValue: false,
    );
    const hasEnableLog = bool.hasEnvironment('ENABLE_LOG');
    const envUseMockApi = bool.fromEnvironment(
      'USE_MOCK_API',
      defaultValue: false,
    );
    const hasUseMockApi = bool.hasEnvironment('USE_MOCK_API');

    switch (flavor) {
      case AppFlavor.dev:
        return AppEnv(
          flavor: AppFlavor.dev,
          appName: envAppName.isNotEmpty ? envAppName : 'Flutter Arms Dev',
          baseUrl: envBaseUrl.isNotEmpty ? envBaseUrl : 'https://example.dev.api',
          enableLog: !hasEnableLog || envEnableLog,
          // dev 默认开启 mock，无需后端即可演示登录/登出。
          useMockApi: !hasUseMockApi || envUseMockApi,
        );
      case AppFlavor.prod:
        return AppEnv(
          flavor: AppFlavor.prod,
          appName: envAppName.isNotEmpty ? envAppName : 'Flutter Arms',
          baseUrl: envBaseUrl.isNotEmpty
              ? envBaseUrl
              : 'https://example.prod.api',
          enableLog: hasEnableLog && envEnableLog,
          // prod 强制走真实后端；即便 --dart-define 打开也一律拒绝。
          useMockApi: false,
        );
    }
  }

  /// 当前 flavor。
  final AppFlavor flavor;

  /// 应用名称。
  final String appName;

  /// API 根地址。
  final String baseUrl;

  /// 是否启用日志。
  final bool enableLog;

  /// 是否启用 Mock API（仅 dev flavor 生效）。
  ///
  /// 启用后 `MockApiInterceptor` 会短路 `/auth/*` 请求，返回预置响应，
  /// 使派生项目无需真实后端也能跑通登录/登出流程。
  final bool useMockApi;
}

/// 应用环境 Provider。bootstrap 时通过 override 注入。
@Riverpod(keepAlive: true)
AppEnv appEnv(Ref ref) {
  throw UnimplementedError(
    'appEnvProvider 必须在 ProviderScope 的 overrides 中注入。 '
    '请在 bootstrap(flavor:) 中完成初始化。',
  );
}
