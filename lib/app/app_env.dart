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
@immutable
class AppEnv {
  /// 构造函数。
  const AppEnv({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
    required this.enableLog,
  });

  /// 根据 flavor 构造默认配置。
  factory AppEnv.fromFlavor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.dev:
        return const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'Flutter Arms Dev',
          baseUrl: 'https://example.dev.api',
          enableLog: true,
        );
      case AppFlavor.prod:
        return const AppEnv(
          flavor: AppFlavor.prod,
          appName: 'Flutter Arms',
          baseUrl: 'https://example.prod.api',
          enableLog: false,
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
