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

    switch (flavor) {
      case AppFlavor.dev:
        return AppEnv(
          flavor: AppFlavor.dev,
          appName: envAppName.isNotEmpty ? envAppName : 'Flutter Arms Dev',
          baseUrl: envBaseUrl.isNotEmpty ? envBaseUrl : 'https://example.dev.api',
          enableLog: !hasEnableLog || envEnableLog,
        );
      case AppFlavor.prod:
        return AppEnv(
          flavor: AppFlavor.prod,
          appName: envAppName.isNotEmpty ? envAppName : 'Flutter Arms',
          baseUrl: envBaseUrl.isNotEmpty
              ? envBaseUrl
              : 'https://example.prod.api',
          enableLog: hasEnableLog && envEnableLog,
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
}

/// 应用环境 Provider。bootstrap 时通过 override 注入。
@Riverpod(keepAlive: true)
AppEnv appEnv(Ref ref) {
  throw UnimplementedError(
    'appEnvProvider 必须在 ProviderScope 的 overrides 中注入。 '
    '请在 bootstrap(flavor:) 中完成初始化。',
  );
}
