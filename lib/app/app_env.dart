/// 应用环境类型。
enum AppFlavor {
  dev,
  prod,
}

/// 应用环境配置。
class AppEnv {
  AppEnv._({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
    required this.enableLog,
  });

  final AppFlavor flavor;
  final String appName;
  final String baseUrl;
  final bool enableLog;

  static late AppEnv current;

  /// 根据环境初始化配置。
  static void setup({required AppFlavor flavor}) {
    switch (flavor) {
      case AppFlavor.dev:
        current = AppEnv._(
          flavor: flavor,
          appName: 'Flutter Arms Dev',
          baseUrl: 'https://example.dev.api',
          enableLog: true,
        );
      case AppFlavor.prod:
        current = AppEnv._(
          flavor: flavor,
          appName: 'Flutter Arms',
          baseUrl: 'https://example.prod.api',
          enableLog: false,
        );
    }
  }
}
