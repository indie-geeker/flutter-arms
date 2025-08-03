/// 应用信息接口
///
/// 提供应用的元数据信息，如版本号、构建号、包名等，
/// 方便在应用内展示或用于API调用时传递客户端信息。
abstract class IAppInfo {
  /// 获取应用名称
  String get appName;

  /// 获取应用包名/Bundle ID
  ///
  /// 例如：com.example.myapp
  String get packageName;

  /// 获取应用版本号
  ///
  /// 例如：1.0.0
  String get version;

  /// 获取应用构建号
  ///
  /// 例如：18
  String get buildNumber;

  /// 获取设备唯一标识符
  ///
  /// 注意：使用此ID时应遵循隐私法规
  Future<String> get deviceId;

  /// 获取应用安装渠道
  ///
  /// 例如：appStore, googlePlay, testflight, website等
  String get channel;

  /// 获取首次安装时间
  DateTime get firstInstallTime;

  /// 获取最后更新时间
  DateTime get lastUpdateTime;

  /// 获取应用完整版本字符串
  ///
  /// 通常格式为：{版本号}+{构建号}，例如 1.0.0+42
  String get fullVersion;

  /// 检查当前版本是否需要更新
  ///
  /// [minimumRequiredVersion] 服务端要求的最低版本
  ///
  /// 返回 true 表示需要更新
  bool isUpdateRequired(String minimumRequiredVersion);

  /// 获取应用签名信息，用于验证应用完整性
  ///
  /// 返回签名的十六进制或Base64字符串
  Future<String> get signatureHash;

  /// 获取用户代理字符串，用于网络请求
  ///
  /// 例如：MyApp/1.0.0 (iOS 15.0; iPhone12,1)
  String get userAgent;
}
